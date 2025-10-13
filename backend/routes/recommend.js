// backend/routes/recommend.js
// Vector-first recommender with trigram/ILIKE fallbacks.
// Minimal-change integration: preserves original API shapes.

const express = require('express');
const jwt = require('jsonwebtoken');
const db = require('../db');
const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'please_set_jwt_secret';

// vector helpers (must exist in backend/lib)
const { getEmbeddingLocal: getEmbeddingOpenAI, vectorLiteral } = require('../lib/vector_utils');
const { recommendForEmbedding } = require('../lib/recommend_vector');

// maybeAuth - parse token if present (non-fatal)
function maybeAuth(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth) return next();
  const m = auth.match(/^Bearer\s+(.+)$/i);
  if (!m) return next();
  try {
    const payload = jwt.verify(m[1], JWT_SECRET);
    req.userId = payload.userId || payload.user_id || payload.sub || null;
  } catch (e) {
    req.userId = null;
  }
  return next();
}

// requireAuth
function requireAuth(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth) return res.status(401).json({ error: 'Unauthorized' });
  const m = auth.match(/^Bearer\s+(.+)$/i);
  if (!m) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const payload = jwt.verify(m[1], JWT_SECRET);
    req.userId = payload.userId || payload.user_id || payload.sub || null;
    if (!req.userId) return res.status(401).json({ error: 'Unauthorized' });
    return next();
  } catch (e) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

/*
POST /api/recommend
Body:
{ ingredients: ["tomato","basil"], filters: {...}, limit: 10 }

Flow:
1) Vector search (primary):
   - compute embedding for joined ingredients
   - find nearest cluster (optional) and call recommendForEmbedding
   - if results found -> return them
2) Trigram fallback (existing trigram query)
3) ILIKE fallback (existing like/ILIKE query)
*/
router.post('/', async (req, res) => {
  const { ingredients = [], filters = {}, limit = 10 } = req.body;
  if (!Array.isArray(ingredients)) {
    return res.status(400).json({ error: 'ingredients must be array' });
  }

  const cleaned = ingredients.map(s => (s || '').toLowerCase().trim()).filter(Boolean);
  if (cleaned.length === 0) {
    // No ingredients — return some top recipes
    try {
      const { rows } = await db.query(`SELECT * FROM recipes ORDER BY created_at DESC LIMIT $1;`, [limit]);
      return res.json(rows);
    } catch (e) {
      console.error('Recommend error (no-ingredients):', e);
      return res.status(500).json({ error: 'Server error' });
    }
  }

  // Build server-side filter SQL (same keys you used previously)
  const filterClauses = [];
  for (const key of ['vegan','vegetarian','gluten_free','dairy_free','halal','kosher']) {
    if (filters[key] === true) filterClauses.push(`r.${key} = true`);
  }
  const filterSql = filterClauses.length ? ' AND ' + filterClauses.join(' AND ') : '';

  // ---------- 1️⃣ VECTOR primary ----------
  try {
    const queryText = cleaned.join(' ');
    // compute query embedding (OpenAI or local embed service)
    const emb = await getEmbeddingOpenAI(queryText);

    // compute nearest cluster via centroid table (if exists)
    let userCluster = null;
    try {
      const vecLit = vectorLiteral(emb);
      const clusterQ = `SELECT cluster_id FROM recipe_clusters ORDER BY centroid <-> $1::vector LIMIT 1;`;
      const { rows: clusterRows } = await db.query(clusterQ, [vecLit]);
      if (clusterRows && clusterRows.length > 0) {
        userCluster = clusterRows[0].cluster_id;
      }
    } catch (cErr) {
      // If recipe_clusters missing or any error, continue without cluster bias
      console.warn('Cluster lookup failed, continuing without cluster bias:', cErr && cErr.message);
      userCluster = null;
    }

    // call vector recommender (overfetching/rerank handled in helper)
    const vectorRecs = await recommendForEmbedding(emb, { limit, filters, userCluster });

    if (vectorRecs && vectorRecs.length > 0) {
      // strip internal fields to preserve exact API shape
      const cleanedOut = vectorRecs.map(({ score, same_cluster, distance, embedding, ...rest }) => rest);
      return res.json(cleanedOut);
    }
    // else fall through to trigram fallback
  } catch (vecErr) {
    // Log but continue to fallbacks
    console.warn('Vector recommend failed, falling back to trigram/ILIKE:', vecErr && (vecErr.message || vecErr));
  }

  // ---------- 2️⃣ Trigram fallback ----------
  try {
    const trigramQuery = `
      WITH input_terms AS (
        SELECT unnest($1::text[]) AS term
      ),
      matched_ings AS (
        SELECT DISTINCT i.id, i.name, t.term,
               similarity(lower(i.name), lower(t.term)) AS sim
        FROM ingredients i
        JOIN input_terms t ON similarity(lower(i.name), lower(t.term)) >= 0.35
      )
      SELECT r.*, COUNT(DISTINCT mi.id) AS match_count, AVG(mi.sim) AS avg_similarity
      FROM recipes r
      JOIN recipe_ingredients ri ON ri.recipe_id = r.id
      JOIN matched_ings mi ON mi.id = ri.ingredient_id
      WHERE 1=1 ${filterSql}
      GROUP BY r.id
      ORDER BY match_count DESC, AVG(mi.sim) DESC
      LIMIT $2;
    `;
    const { rows: trigramRows } = await db.query(trigramQuery, [cleaned, limit]);
    if (trigramRows && trigramRows.length > 0) {
      return res.json(trigramRows);
    }
  } catch (tErr) {
    console.error('Trigram fallback error:', tErr);
    // continue to ILIKE fallback
  }

  // ---------- 3️⃣ ILIKE fallback ----------
  try {
    const likePatterns = cleaned.map(t => `%${t}%`);
    const likeQuery = `
      WITH input_terms AS (SELECT unnest($1::text[]) AS pattern)
      SELECT r.*, COUNT(DISTINCT i.id) AS match_count
      FROM recipes r
      JOIN recipe_ingredients ri ON ri.recipe_id = r.id
      JOIN ingredients i ON i.id = ri.ingredient_id
      JOIN input_terms t ON i.name ILIKE t.pattern
      WHERE 1=1 ${filterSql}
      GROUP BY r.id
      ORDER BY match_count DESC
      LIMIT $2;
    `;
    const { rows: likeRows } = await db.query(likeQuery, [likePatterns, limit]);
    return res.json(likeRows);
  } catch (lErr) {
    console.error('ILIKE fallback error:', lErr);
    return res.status(500).json({ error: 'Server error' });
  }
});

/*
GET /api/recommend/user
Personalized recommendations:
- Primary: vector-based user embedding (avg of liked recipe embeddings) + cluster bias.
- Fallback: existing liked_ings SQL if no liked embeddings.
*/
router.get('/user', requireAuth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit || '8', 10);
    const userId = req.userId;

    // inside router.get('/user', requireAuth, ...)
    const EXPECTED_DIM = 384; // set to your embedding model dim

    // fetch embeddings for recipes the user liked/saved
    const embQ = `
      SELECT r.id, r.embedding
      FROM user_recipe_actions ura
      JOIN recipes r ON r.id = ura.recipe_id
      WHERE ura.user_id = $1
        AND (ura.action ILIKE ANY (ARRAY['like','liked','favorite','save','love']))
        AND r.embedding IS NOT NULL
      LIMIT 500;
    `;
    const embRes = await db.query(embQ, [userId]);

    // filter out rows with wrong embedding dimension or non-arrays
    const validRows = (embRes.rows || []).filter(r => Array.isArray(r.embedding) && r.embedding.length === EXPECTED_DIM);

    if (validRows.length > 0) {
      // compute avg embedding using only validRows
      const dim = EXPECTED_DIM;
      const sum = new Array(dim).fill(0.0);
      for (const r of validRows) {
        const vec = r.embedding;
        for (let i = 0; i < dim; ++i) sum[i] += Number(vec[i] || 0);
      }
      const avg = sum.map(v => v / validRows.length);
      // normalize
      const norm = Math.sqrt(avg.reduce((s, x) => s + x * x, 0));
      const userEmbedding = norm > 0 ? avg.map(x => x / norm) : avg;

      // cluster lookup (only if cluster table exists)
      let userCluster = null;
      try {
        const vecLit = vectorLiteral(userEmbedding);
        const clusterQ = `SELECT cluster_id FROM recipe_clusters ORDER BY centroid <-> $1::vector LIMIT 1;`;
        const { rows: clusterRows } = await db.query(clusterQ, [vecLit]);
        if (clusterRows && clusterRows[0]) userCluster = clusterRows[0].cluster_id;
      } catch (cErr) {
        console.warn('User cluster lookup failed, continuing without cluster bias:', cErr && cErr.message);
        userCluster = null;
      }

      // get recommendations
      const recs = await recommendForEmbedding(userEmbedding, { limit, filters: {}, userCluster });
      const cleanedOut = recs.map(({ score, same_cluster, distance, embedding, ...rest }) => rest);
      return res.json(cleanedOut);
    }
    // fallback: existing liked_ings logic (unchanged)
    const sql = `
      WITH liked_ings AS (
        SELECT ri.ingredient_id, COUNT(*) AS cnt
        FROM user_recipe_actions ura
        JOIN recipe_ingredients ri ON ri.recipe_id = ura.recipe_id
        WHERE ura.user_id = $1
          AND (ura.action ILIKE ANY (ARRAY['like','liked','favorite','save','love']))
        GROUP BY ri.ingredient_id
      ),
      recipe_scores AS (
        SELECT r.id AS recipe_id, r.title, r.summary, r.instructions, r.image_url, r.vegan, r.vegetarian, r.gluten_free, r.dairy_free, r.halal, r.kosher,
               COALESCE(SUM(l.cnt),0) AS match_score
        FROM recipes r
        JOIN recipe_ingredients ri ON ri.recipe_id = r.id
        LEFT JOIN liked_ings l ON l.ingredient_id = ri.ingredient_id
        WHERE r.id NOT IN (
          SELECT recipe_id FROM user_recipe_actions ura2 WHERE ura2.user_id = $1 AND (ura2.action ILIKE ANY (ARRAY['like','liked','favorite','save','love']))
        )
        GROUP BY r.id
      )
      SELECT *
      FROM recipe_scores
      WHERE match_score > 0
      ORDER BY match_score DESC
      LIMIT $2;
    `;
    const { rows } = await db.query(sql, [userId, limit]);
    return res.json(rows);

  } catch (err) {
    console.error('Recommend user error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/recommend/feedback (unchanged)
router.post('/feedback', requireAuth, async (req, res) => {
  const { recipe_id, action, rating } = req.body;
  if (!recipe_id || !action) return res.status(400).json({ error: 'recipe_id and action required' });
  const q = `INSERT INTO user_recipe_actions (user_id, recipe_id, action, rating, created_at)
             VALUES ($1,$2,$3,$4, NOW()) RETURNING *;`;
  try {
    const { rows } = await db.query(q, [req.userId, recipe_id, action, rating || null]);
    return res.json(rows[0]);
  } catch (err) {
    console.error('Feedback insert error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
