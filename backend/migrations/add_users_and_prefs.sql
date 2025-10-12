-- migrations/add_users_and_prefs.sql
-- Idempotent creation of users and related preference tables.
-- Safe to run multiple times.

-- Ensure pgcrypto exists (for gen_random_uuid)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- USERS table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE,
  password_hash text,
  display_name text,
  created_at timestamptz DEFAULT now()
);

-- Dietary preferences (e.g., vegan, gluten_free, halal, kosher)
CREATE TABLE IF NOT EXISTS dietary_preferences (
  id serial PRIMARY KEY,
  key text UNIQUE NOT NULL,   -- e.g., 'vegan','vegetarian','gluten_free','dairy_free','halal','kosher'
  display_name text
);

-- Seed common dietary_preferences if not present
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM dietary_preferences WHERE key='vegan') THEN
    INSERT INTO dietary_preferences (key, display_name) VALUES
      ('vegan','Vegan'),
      ('vegetarian','Vegetarian'),
      ('gluten_free','Gluten Free'),
      ('dairy_free','Dairy Free'),
      ('halal','Halal'),
      ('kosher','Kosher')
    ON CONFLICT (key) DO NOTHING;
  END IF;
END$$;

-- User preferences pivot: links users to dietary_preferences
CREATE TABLE IF NOT EXISTS user_preferences (
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  preference_id int REFERENCES dietary_preferences(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, preference_id)
);

-- Add foreign key from user_recipe_actions.user_id -> users.id if possible
-- This block checks for existence of the constraint before creating it.
DO $$
BEGIN
  -- only attempt if table user_recipe_actions exists and users exists
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='user_recipe_actions' AND table_schema='public')
     AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='users' AND table_schema='public') THEN

    -- check if constraint already exists
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
      WHERE tc.table_name = 'user_recipe_actions' AND tc.constraint_type = 'FOREIGN KEY' AND kcu.column_name = 'user_id'
    ) THEN
      BEGIN
        -- ensure user_id column is uuid type; if not, try to cast
        PERFORM 1 FROM information_schema.columns WHERE table_name='user_recipe_actions' AND column_name='user_id' AND data_type='uuid';
        IF NOT FOUND THEN
          -- attempt to alter type to uuid using text cast if column exists
          BEGIN
            EXECUTE 'ALTER TABLE user_recipe_actions ALTER COLUMN user_id TYPE uuid USING (user_id::uuid)';
          EXCEPTION WHEN others THEN
            -- ignore if cannot cast
            RAISE NOTICE 'Could not alter user_recipe_actions.user_id to uuid - leaving as-is.';
          END;
        END IF;

        -- add foreign key constraint now that types align
        EXECUTE 'ALTER TABLE user_recipe_actions ADD CONSTRAINT fk_user_recipe_actions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL';
      EXCEPTION WHEN others THEN
        RAISE NOTICE 'Could not add foreign key constraint to user_recipe_actions.user_id: %', SQLERRM;
      END;
    END IF;
  END IF;
END$$;

-- Optional: create a simple user_recipe_actions_view for joined view
CREATE OR REPLACE VIEW user_recipe_actions_view AS
SELECT ura.id, ura.user_id, u.email AS user_email, ura.recipe_id, r.title AS recipe_title, ura.action, ura.rating, ura.created_at
FROM user_recipe_actions ura
LEFT JOIN users u ON u.id = ura.user_id
LEFT JOIN recipes r ON r.id = ura.recipe_id;

-- Indexes to speed lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_user_preferences_user ON user_preferences (user_id);

-- Done.
