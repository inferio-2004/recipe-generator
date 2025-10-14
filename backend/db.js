// backend/db.js
const { Pool } = require('pg');
require('dotenv').config({path: '../.env'});
console.log('db.js loaded — DATABASE_URL:', !!process.env.DATABASE_URL);
console.log('db.js loaded — PGSSLMODE:', process.env.PGSSLMODE);
const poolConfig = {
  connectionString: process.env.DATABASE_URL,
};
// Enable SSL for non-local DBs (safe default for cloud DBs).
// NOTE: rejectUnauthorized: false is pragmatic for many managed DBs that use self-signed certs.
// For production with a real CA, set rejectUnauthorized: true and provide ca if needed.
if (process.env.DATABASE_URL && !process.env.DATABASE_URL.includes('localhost') && !process.env.DATABASE_URL.includes('127.0.0.1')) {
  poolConfig.ssl = { rejectUnauthorized: false };
}
if (!poolConfig.ssl) {
  poolConfig.ssl = { require: true, rejectUnauthorized: false };
}
const pool = new Pool(poolConfig);

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};
