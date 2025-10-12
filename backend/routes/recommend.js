// backend/routes/recommend.js
const express = require('express');
const jwt = require('jsonwebtoken');
const db = require('../db');
const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'please_set_jwt_secret';
const USER_SCORE_BOOST = 2.0;

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
IMPORTANT: search ALWAYS uses tsvector (recipes.search_vector). Filters in request are ignored server-side;
they are returned as recipe fields so the frontend can filter client-side.
*/
router.post('/', async (req, res) => {
  const { ingredients = [], filters = {}, limit = 10 } = req.body;
  if (!Array.isArray(ingredients)) {
    return res.status(400).json({ error: 'ingredients must be array' });
  }

  const cleaned = ingredients.map(s => s.toLowerCase().trim()).filter(Boolean);
  if (cleaned.length === 0) {
    // No ingredients — return some top recipes
    const { rows } = await db.query(`SELECT * FROM recipes ORDER BY created_at DESC LIMIT $1;`, [limit]);
    return res.json(rows);
  }

  // Handle filters (vegan, halal, etc.)
  const filterClauses = [];
  for (const key of ['vegan','vegetarian','gluten_free','dairy_free','halal','kosher']) {
    if (filters[key] === true) filterClauses.push(`r.${key} = true`);
  }
  const filterSql = filterClauses.length ? ' AND ' + filterClauses.join(' AND ') : '';

  try {
    // ---------- 1️⃣ Try fuzzy (trigram) match ----------
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

    // ---------- 2️⃣ Fallback: ILIKE partial match ----------
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
  } catch (err) {
    console.error('Recommend error:', err);
    return res.status(500).json({ error: 'Server error' });
  }
});
/*
GET /api/recommend/user
Same as before: personalized recommendations based on liked ingredients.
Returns recipe boolean flags so frontend can filter client-side.
*/
router.get('/user', requireAuth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit || '8', 10);
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
    const { rows } = await db.query(sql, [req.userId, limit]);
    return res.json(rows);
  } catch (err) {
    console.error('Recommend user error', err);
    return res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/recommend/feedback
router.post('/feedback', requireAuth, async (req, res) => {
  const { recipe_id, action, rating } = req.body;
  if (!recipe_id || !action) return res.status(400).json({ error: 'recipe_id and action required' });
  const q = `INSERT INTO user_recipe_actions (user_id, recipe_id, action, rating, created_at)
             VALUES ($1,$2,$3,$4, NOW()) RETURNING *;`;
  const { rows } = await db.query(q, [req.userId, recipe_id, action, rating || null]);
  res.json(rows[0]);
});


module.exports = router;
