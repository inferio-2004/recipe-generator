-- add_pgvector_and_columns.sql
-- run as superuser if you need to install the extension
CREATE EXTENSION IF NOT EXISTS vector;

ALTER TABLE recipes
  ADD COLUMN IF NOT EXISTS embedding vector(384),
  ADD COLUMN IF NOT EXISTS cluster_id integer;

CREATE TABLE IF NOT EXISTS recipe_clusters (
  cluster_id integer PRIMARY KEY,
  centroid vector(384)
);

-- Create ANN index (ivfflat). Tune lists for performance (nlist).
CREATE INDEX IF NOT EXISTS idx_recipes_embedding_ivfflat
  ON recipes USING ivfflat (embedding vector_l2_ops) WITH (lists = 100);

VACUUM ANALYZE recipes;
