// backend/lib/recommend_vector.js
// Uses existing `db` module (expects db.query(sql, params)).
// Provides recommendForEmbedding(embedding, options)

const db = require('../db'); // must export query(sql, params)
const { vectorLiteral } = require('./vector_utils');

// simple reranker combining distance + popularity
function rerank(rows, idToDistance) {
  if (!rows || rows.length === 0) return [];
  const pops = rows.map(r => r.popularity || 0);
  const maxp = Math.max(...pops, 1);
  return rows.map(r => {
    const dist = idToDistance[r.id] ?? 1e6;
    const sim = 1.0 / (1.0 + dist);
    const pop = (r.popularity || 0) / maxp;
    const score = 0.75 * sim + 0.25 * pop;
    return Object.assign({}, r, { score });
  }).sort((a, b) => b.score - a.score);
}

/**
 * Recommend by embedding
 * @param {number[]} embedding - normalized array
 * @param {object} options - { limit, filters, userCluster, overfetch }
 * @returns {Promise<Array>} rows (with extra score field)
 */
async function recommendForEmbedding(embedding, options = {}) {
  const limit = options.limit || 12;
  const filters = options.filters || {};
  const userCluster = options.userCluster ?? null;
  const overfetch = options.overfetch || Math.max(limit * 10, 200);

  if (!Array.isArray(embedding) || embedding.length === 0) {
    return [];
  }

  const vecLit = vectorLiteral(embedding);

  // build filter SQL
  const filterClauses = [];
  if (filters.vegan) filterClauses.push('r.vegan = true');
  if (filters.vegetarian) filterClauses.push('r.vegetarian = true');
  if (filters.gluten_free) filterClauses.push('r.gluten_free = true');
  if (filters.dairy_free) filterClauses.push('r.dairy_free = true');
  if (filters.halal) filterClauses.push('r.halal = true');
  if (filters.kosher) filterClauses.push('r.kosher = true');
  const filterSql = filterClauses.length ? ' AND ' + filterClauses.join(' AND ') : '';

  // Use r.* to preserve original recipe columns
  const sql = `
    SELECT r.*, (r.cluster_id = $3) AS same_cluster, r.embedding <-> $1::vector AS distance
    FROM recipes r
    WHERE r.embedding IS NOT NULL
    ${filterSql}
    ORDER BY same_cluster DESC, r.embedding <-> $1::vector
    LIMIT $2;
  `;

  // Use db.query directly (your db module must export query)
  const params = [vecLit, overfetch, userCluster];
  const res = await db.query(sql, params);
  const rows = res.rows || [];

  const idToDistance = {};
  rows.forEach(r => { idToDistance[r.id] = Number(r.distance ?? 1e6); });

  const reranked = rerank(rows, idToDistance).slice(0, limit);
  return reranked;
}

module.exports = { recommendForEmbedding, rerank };
