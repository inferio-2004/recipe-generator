// backend/lib/vector_utils.js
// CommonJS wrapper for @xenova/transformers embedding pipeline with NaN-safety.
// Exports: getEmbeddingLocal(text) -> Promise<number[]>
//          vectorLiteral(vec) -> string (pgvector literal)

let embedder = null;
let loading = null;

async function ensureModel() {
  if (embedder) return embedder;
  if (loading) return loading;

  loading = (async () => {
    // dynamic import so this module works with CommonJS require()
    const mod = await import('@xenova/transformers');
    const pipeline = mod.pipeline || mod.default?.pipeline || mod;
    embedder = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
    return embedder;
  })();

  return loading;
}

function sanitizeVector(arr) {
  // convert to numbers, replace NaN with 0, and renormalize (L2)
  if (!Array.isArray(arr) || arr.length === 0) return [];
  const nums = arr.map(x => {
    const n = Number(x);
    return Number.isFinite(n) ? n : 0.0;
  });
  const norm = Math.sqrt(nums.reduce((s, v) => s + v * v, 0));
  if (norm > 0) {
    return nums.map(v => v / norm);
  }
  return nums;
}

/**
 * Returns a normalized embedding array (no NaNs)
 * @param {string} text
 * @returns {Promise<number[]>}
 */
async function getEmbeddingLocal(text) {
  if (!text || !String(text).trim()) return [];
  const model = await ensureModel();
  const result = await model(String(text), { pooling: 'mean', normalize: true });

  // result.data may be Float32Array or Array
  const raw = result?.data ? Array.from(result.data) : (Array.isArray(result) ? result : []);
  const clean = sanitizeVector(raw);
  return clean;
}

/**
 * Convert numeric array -> pgvector literal string '[0.123456, -0.2345, ...]'
 * Ensures no NaN present by sanitizing first.
 * @param {number[]} vec
 * @returns {string}
 */
function vectorLiteral(vec) {
  const safe = sanitizeVector(vec);
  if (!safe || safe.length === 0) return '[]';
  // limit precision to 8 decimals
  return '[' + safe.map(v => Number(v).toFixed(8)).join(',') + ']';
}

module.exports = { getEmbeddingLocal, vectorLiteral };
