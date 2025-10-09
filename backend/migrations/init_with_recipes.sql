-- migrations/init.sql
-- Smart Recipe Generator: schema for recipe-related tables (users left out / commented)
-- Safe to run multiple times: uses IF NOT EXISTS where appropriate.

-- Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS unaccent;  -- optional but useful for search normalization

-- =========================
-- Recipe-related tables
-- =========================

-- RECIPES
CREATE TABLE IF NOT EXISTS recipes (
  id              serial PRIMARY KEY,
  title           text NOT NULL,
  summary         text,
  instructions    text,
  image_url       text,
  prep_minutes    int,
  cook_minutes    int,
  servings        numeric DEFAULT 1,
  vegetarian      boolean DEFAULT false,
  vegan           boolean DEFAULT false,
  gluten_free     boolean DEFAULT false,
  dairy_free      boolean DEFAULT false,
  halal           boolean DEFAULT false,
  kosher          boolean DEFAULT false,
  ingredients_text text,   -- denormalized list of ingredient names for search & display
  search_vector   tsvector,
  created_at      timestamptz DEFAULT now()
);

-- RECIPE STEPS (ordered)
CREATE TABLE IF NOT EXISTS recipe_steps (
  id serial PRIMARY KEY,
  recipe_id int REFERENCES recipes(id) ON DELETE CASCADE,
  step_index int NOT NULL,
  step_text text NOT NULL
);

-- INGREDIENTS (normalized)
CREATE TABLE IF NOT EXISTS ingredients (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE,
  common_names text[],
  created_at timestamptz DEFAULT now()
);

-- UNITS (for quantity conversions)
CREATE TABLE IF NOT EXISTS units (
  id serial PRIMARY KEY,
  key text NOT NULL UNIQUE,        -- e.g., 'gram','kg','ml','cup','tbsp','tsp','piece'
  display_name text,
  grams_equivalent numeric         -- approximate grams equivalent per unit (NULL when unknown)
);

-- PIVOT: recipe contains ingredient
CREATE TABLE IF NOT EXISTS recipe_ingredients (
  recipe_id int REFERENCES recipes(id) ON DELETE CASCADE,
  ingredient_id int REFERENCES ingredients(id) ON DELETE CASCADE,
  quantity numeric,
  unit_id int REFERENCES units(id),
  note text,
  PRIMARY KEY (recipe_id, ingredient_id)
);

-- INGREDIENT TAGS (allergens / categories)
CREATE TABLE IF NOT EXISTS ingredient_tags (
  id serial PRIMARY KEY,
  key text UNIQUE NOT NULL,     -- e.g., 'nut','dairy','gluten','fruit'
  display_name text
);

CREATE TABLE IF NOT EXISTS ingredient_tag_map (
  ingredient_id int REFERENCES ingredients(id) ON DELETE CASCADE,
  tag_id int REFERENCES ingredient_tags(id) ON DELETE CASCADE,
  PRIMARY KEY (ingredient_id, tag_id)
);

-- PER-INGREDIENT NUTRITION (per 100g basis)
CREATE TABLE IF NOT EXISTS ingredient_nutrition_100g (
  ingredient_id int PRIMARY KEY REFERENCES ingredients(id) ON DELETE CASCADE,
  calories numeric,
  protein_g numeric,
  fat_g numeric,
  carbs_g numeric,
  fiber_g numeric,
  sugar_g numeric,
  sodium_mg numeric,
  updated_at timestamptz DEFAULT now()
);

-- RECIPE NUTRITION CACHE (precomputed per recipe)
CREATE TABLE IF NOT EXISTS recipe_nutrition_cache (
  recipe_id int PRIMARY KEY REFERENCES recipes(id) ON DELETE CASCADE,
  calories numeric,
  protein_g numeric,
  fat_g numeric,
  carbs_g numeric,
  fiber_g numeric,
  sugar_g numeric,
  sodium_mg numeric,
  computed_at timestamptz DEFAULT now()
);

-- USER_RECIPE_ACTIONS (history/ratings/favorites) - keep for recommender; user table not defined here
CREATE TABLE IF NOT EXISTS user_recipe_actions (
  id serial PRIMARY KEY,
  user_id uuid,  -- will reference users(id) once users table is added
  recipe_id int REFERENCES recipes(id) ON DELETE CASCADE,
  action text NOT NULL,  -- 'view','favorite','cook','rating'
  rating smallint,       -- nullable 1..5 when action='rating'
  created_at timestamptz DEFAULT now()
);

-- Convenience view: aggregated ingredient list per recipe
CREATE OR REPLACE VIEW recipe_with_ings AS
SELECT r.*,
       coalesce(string_agg(i.name, ', ' ORDER BY i.name), '') AS ingredients_list
FROM recipes r
LEFT JOIN recipe_ingredients ri ON ri.recipe_id = r.id
LEFT JOIN ingredients i ON i.id = ri.ingredient_id
GROUP BY r.id;

-- =========================
-- Full-text search: tsvector + trigger
-- =========================

-- Function to update search_vector combining title and ingredients_text
CREATE OR REPLACE FUNCTION recipes_search_vector_update() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', coalesce(NEW.title,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.ingredients_text,'')), 'B');
  RETURN NEW;
END;
$$;

-- GIN index on search_vector for fast text search
CREATE INDEX IF NOT EXISTS recipes_search_idx ON recipes USING GIN (search_vector);

-- =========================
-- Helpful indexes
-- =========================
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient ON recipe_ingredients (ingredient_id);
CREATE INDEX IF NOT EXISTS idx_recipe_steps_recipe ON recipe_steps (recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_nutrition_recipe ON recipe_nutrition_cache (recipe_id);
CREATE INDEX IF NOT EXISTS idx_ingredient_name ON ingredients USING btree (name text_pattern_ops);

-- =========================
-- Sample reference data (small) - safe to keep for local testing
-- =========================

-- Units (approx grams equivalents for common units)
INSERT INTO units (key, display_name, grams_equivalent) VALUES
  ('gram', 'gram', 1),
  ('kg', 'kilogram', 1000),
  ('ml', 'milliliter', 1),
  ('cup', 'cup', 240),
  ('tbsp', 'tablespoon', 15),
  ('tsp', 'teaspoon', 5),
  ('piece', 'piece', NULL)
ON CONFLICT (key) DO NOTHING;

-- A few ingredients
INSERT INTO ingredients (name, common_names) VALUES
  ('banana', ARRAY['plantain']::text[]),
  ('milk', ARRAY['cow milk','dairy milk']::text[]),
  ('sugar', ARRAY['white sugar','granulated sugar']::text[]),
  ('apple', ARRAY['red apple']::text[]),
  ('flour', ARRAY['all-purpose flour']::text[])
ON CONFLICT (name) DO NOTHING;

-- Optional: per-100g nutrition for some ingredients (approx values)
-- (these numbers are illustrative — update if you want more accurate data)
INSERT INTO ingredient_nutrition_100g (ingredient_id, calories, protein_g, fat_g, carbs_g, fiber_g, sugar_g, sodium_mg)
SELECT id, t.cal, t.prot, t.fat, t.carbs, t.fiber, t.sugar, t.sodium FROM (
  VALUES
    ('banana', 89, 1.1, 0.3, 22.8, 2.6, 12.2, 1),
    ('milk', 60, 3.2, 3.3, 4.8, 0, 5.0, 44),
    ('sugar', 387, 0, 0, 100, 0, 100, 0),
    ('apple', 52, 0.3, 0.2, 14, 2.4, 10.4, 1),
    ('flour', 364, 10, 1, 76, 2.7, 0.3, 2)
) AS t(name, cal, prot, fat, carbs, fiber, sugar, sodium)
JOIN ingredients i ON i.name = t.name
ON CONFLICT (ingredient_id) DO UPDATE SET
  calories = EXCLUDED.calories,
  protein_g = EXCLUDED.protein_g,
  fat_g = EXCLUDED.fat_g,
  carbs_g = EXCLUDED.carbs_g,
  fiber_g = EXCLUDED.fiber_g,
  sugar_g = EXCLUDED.sugar_g,
  sodium_mg = EXCLUDED.sodium_mg,
  updated_at = now();

-- Insert a sample recipe (Banana Milkshake) to test search & nutrition pipeline
DO $$
DECLARE
  r_id int;
  banana_id int;
  milk_id int;
  sugar_id int;
  grams_unit int;
BEGIN
  SELECT id INTO banana_id FROM ingredients WHERE name='banana' LIMIT 1;
  SELECT id INTO milk_id FROM ingredients WHERE name='milk' LIMIT 1;
  SELECT id INTO sugar_id FROM ingredients WHERE name='sugar' LIMIT 1;
  SELECT id INTO grams_unit FROM units WHERE key='gram' LIMIT 1;

  -- create recipe if not exists
  INSERT INTO recipes (title, summary, instructions, prep_minutes, cook_minutes, servings, vegetarian, vegan, ingredients_text, image_url)
  SELECT 'Banana Milkshake',
         'Simple banana milkshake',
         'Peel bananas. Blend banana, milk and sugar with ice until smooth.',
         5, 0, 2, true, false, 'banana, milk, sugar',
         'https://example.com/images/banana_milkshake.jpg'
  WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Banana Milkshake')
  RETURNING id INTO r_id;

  IF r_id IS NULL THEN
    SELECT id INTO r_id FROM recipes WHERE title='Banana Milkshake' LIMIT 1;
  END IF;

  -- link ingredients (upsert in pivot)
  IF banana_id IS NOT NULL THEN
    INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id)
    VALUES (r_id, banana_id, 200, grams_unit) -- 200 grams banana approx
    ON CONFLICT (recipe_id, ingredient_id) DO NOTHING;
  END IF;

  IF milk_id IS NOT NULL THEN
    INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id)
    VALUES (r_id, milk_id, 300, grams_unit) -- 300 ml milk (grams_equivalent of ml=1)
    ON CONFLICT (recipe_id, ingredient_id) DO NOTHING;
  END IF;

  IF sugar_id IS NOT NULL THEN
    INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id)
    VALUES (r_id, sugar_id, 20, grams_unit) -- 20 g sugar
    ON CONFLICT (recipe_id, ingredient_id) DO NOTHING;
  END IF;

  -- compute basic nutrition via calling compute_and_upsert_recipe_nutrition if function exists
  -- We'll create this function below; if you prefer to call from app, you can skip this.
END$$;

-- =========================
-- Utility: function to compute recipe nutrition and store in cache
-- =========================
CREATE OR REPLACE FUNCTION compute_and_upsert_recipe_nutrition(p_recipe_id int) RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  rec RECORD;
  grams numeric;
  u_eq numeric;
  total_cal numeric := 0;
  total_protein numeric := 0;
  total_fat numeric := 0;
  total_carbs numeric := 0;
  total_fiber numeric := 0;
  total_sugar numeric := 0;
  total_sodium numeric := 0;
BEGIN
  FOR rec IN
    SELECT ri.quantity, u.grams_equivalent, inut.calories, inut.protein_g, inut.fat_g, inut.carbs_g, inut.fiber_g, inut.sugar_g, inut.sodium_mg
    FROM recipe_ingredients ri
    LEFT JOIN units u ON ri.unit_id = u.id
    LEFT JOIN ingredient_nutrition_100g inut ON inut.ingredient_id = ri.ingredient_id
    WHERE ri.recipe_id = p_recipe_id
  LOOP
    u_eq := rec.grams_equivalent;
    IF u_eq IS NULL THEN
      -- if unit grams conversion is unknown, assume quantity is grams
      grams := COALESCE(rec.quantity, 0);
    ELSE
      grams := COALESCE(rec.quantity, 0) * u_eq;
    END IF;

    IF rec.calories IS NOT NULL THEN
      total_cal := total_cal + (rec.calories * grams / 100.0);
      total_protein := total_protein + (COALESCE(rec.protein_g,0) * grams / 100.0);
      total_fat := total_fat + (COALESCE(rec.fat_g,0) * grams / 100.0);
      total_carbs := total_carbs + (COALESCE(rec.carbs_g,0) * grams / 100.0);
      total_fiber := total_fiber + (COALESCE(rec.fiber_g,0) * grams / 100.0);
      total_sugar := total_sugar + (COALESCE(rec.sugar_g,0) * grams / 100.0);
      total_sodium := total_sodium + (COALESCE(rec.sodium_mg,0) * grams / 100.0);
    END IF;
  END LOOP;

  INSERT INTO recipe_nutrition_cache (recipe_id, calories, protein_g, fat_g, carbs_g, fiber_g, sugar_g, sodium_mg, computed_at)
  VALUES (p_recipe_id, total_cal, total_protein, total_fat, total_carbs, total_fiber, total_sugar, total_sodium, now())
  ON CONFLICT (recipe_id) DO UPDATE SET
    calories = EXCLUDED.calories,
    protein_g = EXCLUDED.protein_g,
    fat_g = EXCLUDED.fat_g,
    carbs_g = EXCLUDED.carbs_g,
    fiber_g = EXCLUDED.fiber_g,
    sugar_g = EXCLUDED.sugar_g,
    sodium_mg = EXCLUDED.sodium_mg,
    computed_at = now();
END;
$$;

-- Optionally compute nutrition for sample recipes (if recipe exists)
DO $$
DECLARE
  rid int;
BEGIN
  SELECT id INTO rid FROM recipes WHERE title='Banana Milkshake' LIMIT 1;
  IF rid IS NOT NULL THEN
    PERFORM compute_and_upsert_recipe_nutrition(rid);
  END IF;
END$$;

-- =========================
-- Helpful example search query (use from app)
-- =========================
-- Example: search text "banana milk" (from Clarifai labels -> build query string)
-- SELECT id, title, ts_rank(search_vector, websearch_to_tsquery('banana milk')) AS rank
-- FROM recipes
-- WHERE search_vector @@ websearch_to_tsquery('banana milk')
-- ORDER BY rank DESC
-- LIMIT 20;

-- =========================
-- (Optional) Users-related tables placeholder
-- You said you'll keep user-related tables blank for now.
-- If you later want them, you can add standard users/auth tables:
-- CREATE TABLE users ( id uuid PRIMARY KEY DEFAULT gen_random_uuid(), email text UNIQUE, password_hash text, ... );
-- CREATE TABLE user_preferences ( user_id uuid REFERENCES users(id), preference_id int REFERENCES dietary_preferences(id), ... );
-- =========================

-- Done.

-- ========== ADDED SAMPLE RECIPES (20) ==========
-- Safe to run multiple times.

-- Helper: find unit ids once
