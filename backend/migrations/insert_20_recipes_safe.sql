
-- Safe idempotent insertion of 20 sample recipes.
-- This file only inserts data (units, ingredients, recipes, recipe_ingredients, recipe_steps)
-- It uses WHERE NOT EXISTS checks so it won't rely on ON CONFLICT or table structure beyond column names used.
-- Run this after ensuring your schema (tables) exist.

-- Ensure common units exist (insert only 'key' column if 'name' doesn't exist)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='gram') THEN
    BEGIN
      -- try insert with key only
      BEGIN
        INSERT INTO units (key) VALUES ('gram');
      EXCEPTION WHEN undefined_column THEN
        -- try with name column too
        INSERT INTO units (key, name) VALUES ('gram','gram');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='ml') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('ml');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, name) VALUES ('ml','milliliter');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='cup') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('cup');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, name) VALUES ('cup','cup');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='tbsp') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('tbsp');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, name) VALUES ('tbsp','tablespoon');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='tsp') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('tsp');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, name) VALUES ('tsp','teaspoon');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='piece') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('piece');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, name) VALUES ('piece','piece');
      END;
    END;
  END IF;
END$$;

-- Helper: Insert ingredient if missing
-- Using simple INSERT ... SELECT ... WHERE NOT EXISTS to avoid ON CONFLICT requirement

-- Ingredients list (collectively)
-- We'll insert each ingredient if missing


INSERT INTO ingredients (name)
SELECT 'chickpeas'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'chickpeas');

INSERT INTO ingredients (name)
SELECT 'sunflower seeds'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'sunflower seeds');

INSERT INTO ingredients (name)
SELECT 'lemon'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'lemon');

INSERT INTO ingredients (name)
SELECT 'celery'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'celery');

INSERT INTO ingredients (name)
SELECT 'vegan mayo'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'vegan mayo');

INSERT INTO ingredients (name)
SELECT 'paprika'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'paprika');

INSERT INTO ingredients (name)
SELECT 'cucumber'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'cucumber');

INSERT INTO ingredients (name)
SELECT 'tomato'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'tomato');

INSERT INTO ingredients (name)
SELECT 'garlic'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'garlic');

INSERT INTO ingredients (name)
SELECT 'dill'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'dill');

INSERT INTO ingredients (name)
SELECT 'red lentils'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'red lentils');

INSERT INTO ingredients (name)
SELECT 'carrot'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'carrot');

INSERT INTO ingredients (name)
SELECT 'leek'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'leek');

INSERT INTO ingredients (name)
SELECT 'onion'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'onion');

INSERT INTO ingredients (name)
SELECT 'vegetable stock'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'vegetable stock');

INSERT INTO ingredients (name)
SELECT 'quinoa'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'quinoa');

INSERT INTO ingredients (name)
SELECT 'cherry tomato'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'cherry tomato');

INSERT INTO ingredients (name)
SELECT 'olives'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'olives');

INSERT INTO ingredients (name)
SELECT 'parsley'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'parsley');

INSERT INTO ingredients (name)
SELECT 'tofu'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'tofu');

INSERT INTO ingredients (name)
SELECT 'broccoli'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'broccoli');

INSERT INTO ingredients (name)
SELECT 'soy sauce'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'soy sauce');

INSERT INTO ingredients (name)
SELECT 'scallion'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'scallion');

INSERT INTO ingredients (name)
SELECT 'banana'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'banana');

INSERT INTO ingredients (name)
SELECT 'rolled oats'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'rolled oats');

INSERT INTO ingredients (name)
SELECT 'baking powder'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'baking powder');

INSERT INTO ingredients (name)
SELECT 'almond milk'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'almond milk');

INSERT INTO ingredients (name)
SELECT 'vanilla'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'vanilla');

INSERT INTO ingredients (name)
SELECT 'pasta'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'pasta');

INSERT INTO ingredients (name)
SELECT 'zucchini'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'zucchini');

INSERT INTO ingredients (name)
SELECT 'peas'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'peas');

INSERT INTO ingredients (name)
SELECT 'parmesan'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'parmesan');

INSERT INTO ingredients (name)
SELECT 'cherry tomatoes'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'cherry tomatoes');

INSERT INTO ingredients (name)
SELECT 'red onion'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'red onion');

INSERT INTO ingredients (name)
SELECT 'feta'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'feta');

INSERT INTO ingredients (name)
SELECT 'salmon'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'salmon');

INSERT INTO ingredients (name)
SELECT 'olive oil'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'olive oil');

INSERT INTO ingredients (name)
SELECT 'chicken breast'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'chicken breast');

INSERT INTO ingredients (name)
SELECT 'shawarma spice'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'shawarma spice');

INSERT INTO ingredients (name)
SELECT 'rice'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'rice');

INSERT INTO ingredients (name)
SELECT 'hummus'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'hummus');

INSERT INTO ingredients (name)
SELECT 'cilantro'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'cilantro');

INSERT INTO ingredients (name)
SELECT 'cumin'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'cumin');

INSERT INTO ingredients (name)
SELECT 'eggs'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'eggs');

INSERT INTO ingredients (name)
SELECT 'bell pepper'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'bell pepper');

INSERT INTO ingredients (name)
SELECT 'miso paste'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'miso paste');

INSERT INTO ingredients (name)
SELECT 'wakame'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'wakame');

INSERT INTO ingredients (name)
SELECT 'dashi/kombu'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'dashi/kombu');

INSERT INTO ingredients (name)
SELECT 'mint'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'mint');

INSERT INTO ingredients (name)
SELECT 'almond flour'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'almond flour');

INSERT INTO ingredients (name)
SELECT 'chocolate chips'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'chocolate chips');

INSERT INTO ingredients (name)
SELECT 'baking soda'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'baking soda');

INSERT INTO ingredients (name)
SELECT 'coconut milk'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'coconut milk');

INSERT INTO ingredients (name)
SELECT 'peanut'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'peanut');

INSERT INTO ingredients (name)
SELECT 'curry paste'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'curry paste');

INSERT INTO ingredients (name)
SELECT 'spinach'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'spinach');

INSERT INTO ingredients (name)
SELECT 'tahini'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'tahini');

INSERT INTO ingredients (name)
SELECT 'cauliflower'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'cauliflower');

INSERT INTO ingredients (name)
SELECT 'corn tortillas'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'corn tortillas');

INSERT INTO ingredients (name)
SELECT 'chipotle'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'chipotle');

INSERT INTO ingredients (name)
SELECT 'lime'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'lime');

INSERT INTO ingredients (name)
SELECT 'cashew'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'cashew');

INSERT INTO ingredients (name)
SELECT 'berries'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'berries');

INSERT INTO ingredients (name)
SELECT 'chia seed'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'chia seed');

INSERT INTO ingredients (name)
SELECT 'maple syrup'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name = 'maple syrup');

-- Recipe: Chickpea Sunflower Sandwich
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Chickpea Sunflower Sandwich', 'Smashed chickpeas with roasted sunflower seeds in a dairy-free dressing.', 'Mash chickpeas with a creamy dressing, fold in roasted sunflower seeds and herbs. Serve between bread slices.', 'https://minimalistbaker.com/chickpea-sunflower-sandwich/', 10, 0, 2, true, true, false, true, true, true, 'chickpeas, sunflower seeds, lemon, celery, vegan mayo', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Chickpea Sunflower Sandwich');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Sunflower Sandwich' AND i.name = 'chickpeas'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Sunflower Sandwich' AND i.name = 'sunflower seeds'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Sunflower Sandwich' AND i.name = 'lemon'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Sunflower Sandwich' AND i.name = 'celery'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Sunflower Sandwich' AND i.name = 'vegan mayo'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Drain and roughly mash chickpeas; mix with diced celery and lemon.'
FROM recipes r
WHERE r.title = 'Chickpea Sunflower Sandwich'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Stir in sunflower seeds and vegan mayo; season and serve.'
FROM recipes r
WHERE r.title = 'Chickpea Sunflower Sandwich'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Chickpea Shawarma Salad
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Chickpea Shawarma Salad', 'Mediterranean-spiced baked chickpeas with salad greens and a garlic-dill dressing.', 'Toss spiced baked chickpeas with fresh salad greens and drizzle garlic-dill dressing.', 'https://minimalistbaker.com/chickpea-shawarma-salad/', 10, 20, 2, true, true, false, true, true, true, 'chickpeas, paprika, cucumber, tomato, garlic, dill', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Chickpea Shawarma Salad');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Shawarma Salad' AND i.name = 'chickpeas'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Shawarma Salad' AND i.name = 'paprika'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Shawarma Salad' AND i.name = 'cucumber'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Shawarma Salad' AND i.name = 'tomato'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Shawarma Salad' AND i.name = 'garlic'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chickpea Shawarma Salad' AND i.name = 'dill'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Toss chickpeas with shawarma spices and roast until crisp.'
FROM recipes r
WHERE r.title = 'Chickpea Shawarma Salad'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Assemble on salad greens and drizzle garlic-dill sauce.'
FROM recipes r
WHERE r.title = 'Chickpea Shawarma Salad'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Red Lentil Soup
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Red Lentil Soup', 'Hearty red lentil soup with carrot and leeks.', 'Sauté vegetables, add lentils and stock; simmer until tender and blend slightly to thicken.', 'https://www.bbcgoodfood.com/recipes/lentil-soup', 10, 35, 4, true, true, true, true, true, true, 'red lentils, carrot, leek, onion, vegetable stock', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Red Lentil Soup');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Red Lentil Soup' AND i.name = 'red lentils'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Red Lentil Soup' AND i.name = 'carrot'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Red Lentil Soup' AND i.name = 'leek'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Red Lentil Soup' AND i.name = 'onion'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Red Lentil Soup' AND i.name = 'vegetable stock'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Sauté finely chopped onion, leek and carrot; add lentils and stock and simmer 25–30 minutes.'
FROM recipes r
WHERE r.title = 'Red Lentil Soup'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Season to taste and serve hot.'
FROM recipes r
WHERE r.title = 'Red Lentil Soup'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Mediterranean Quinoa Salad
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Mediterranean Quinoa Salad', 'Quinoa with tomatoes, cucumbers, olives and herbs.', 'Cook quinoa, cool and toss with chopped vegetables, olives and lemon-herb dressing.', 'https://www.loveandlemons.com/quinoa-salad-recipe/', 15, 15, 4, true, true, true, true, true, true, 'quinoa, cherry tomato, cucumber, olives, parsley', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Mediterranean Quinoa Salad');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Mediterranean Quinoa Salad' AND i.name = 'quinoa'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Mediterranean Quinoa Salad' AND i.name = 'cherry tomato'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Mediterranean Quinoa Salad' AND i.name = 'cucumber'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Mediterranean Quinoa Salad' AND i.name = 'olives'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Mediterranean Quinoa Salad' AND i.name = 'parsley'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Cook quinoa; cool; chop vegetables and herbs.'
FROM recipes r
WHERE r.title = 'Mediterranean Quinoa Salad'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Toss with lemon-olive oil dressing and serve.'
FROM recipes r
WHERE r.title = 'Mediterranean Quinoa Salad'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Crispy Tofu Stir-Fry
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Crispy Tofu Stir-Fry', 'Crispy pan-fried tofu with vegetables and a savory sauce.', 'Press and cube tofu, pan-fry until golden; stir-fry vegetables and toss with soy/tamari-based sauce.', 'https://www.seriouseats.com/vegan-experience-crispy-tofu-broccoli-stir-fry', 15, 15, 2, true, true, false, true, true, true, 'tofu, broccoli, soy sauce, scallion, garlic', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Crispy Tofu Stir-Fry');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Crispy Tofu Stir-Fry' AND i.name = 'tofu'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Crispy Tofu Stir-Fry' AND i.name = 'broccoli'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Crispy Tofu Stir-Fry' AND i.name = 'soy sauce'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Crispy Tofu Stir-Fry' AND i.name = 'scallion'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Crispy Tofu Stir-Fry' AND i.name = 'garlic'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Press and cube tofu, toss in a little cornstarch and pan-fry until crisp.'
FROM recipes r
WHERE r.title = 'Crispy Tofu Stir-Fry'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Stir-fry vegetables and toss everything with sauce; serve over rice.'
FROM recipes r
WHERE r.title = 'Crispy Tofu Stir-Fry'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: 1-Bowl Vegan Banana Oat Pancakes
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT '1-Bowl Vegan Banana Oat Pancakes', 'Simple blender pancakes made with banana and oats.', 'Blend ripe banana and oats to a batter; cook pancakes on a griddle until set; serve with fruit or syrup.', 'https://minimalistbaker.com/1-bowl-vegan-banana-oat-pancakes/', 10, 10, 4, true, true, true, true, true, true, 'banana, rolled oats, baking powder, almond milk, vanilla', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = '1-Bowl Vegan Banana Oat Pancakes');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = '1-Bowl Vegan Banana Oat Pancakes' AND i.name = 'banana'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = '1-Bowl Vegan Banana Oat Pancakes' AND i.name = 'rolled oats'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = '1-Bowl Vegan Banana Oat Pancakes' AND i.name = 'baking powder'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = '1-Bowl Vegan Banana Oat Pancakes' AND i.name = 'almond milk'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = '1-Bowl Vegan Banana Oat Pancakes' AND i.name = 'vanilla'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Blend banana, oats, baking powder and milk into batter.'
FROM recipes r
WHERE r.title = '1-Bowl Vegan Banana Oat Pancakes'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Cook batter on a hot griddle and serve stacked.'
FROM recipes r
WHERE r.title = '1-Bowl Vegan Banana Oat Pancakes'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Pasta Primavera (Vegetarian - GF option)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Pasta Primavera (Vegetarian - GF option)', 'Colorful pasta with spring vegetables; use gluten-free pasta to make it GF.', 'Cook pasta; sauté mixed vegetables; toss with pasta, olive oil, lemon and herbs.', 'https://www.eatingwell.com/recipe/266498/chicken-pasta-primavera/', 15, 15, 4, true, false, false, false, true, true, 'pasta, zucchini, peas, parmesan, cherry tomatoes', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Pasta Primavera (Vegetarian - GF option)');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Pasta Primavera (Vegetarian - GF option)' AND i.name = 'pasta'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Pasta Primavera (Vegetarian - GF option)' AND i.name = 'zucchini'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Pasta Primavera (Vegetarian - GF option)' AND i.name = 'peas'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Pasta Primavera (Vegetarian - GF option)' AND i.name = 'parmesan'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Pasta Primavera (Vegetarian - GF option)' AND i.name = 'cherry tomatoes'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Cook pasta; reserve some cooking water.'
FROM recipes r
WHERE r.title = 'Pasta Primavera (Vegetarian - GF option)'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Sauté vegetables, toss with pasta and a splash of cooking water; finish with parmesan.'
FROM recipes r
WHERE r.title = 'Pasta Primavera (Vegetarian - GF option)'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Greek Salad
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Greek Salad', 'Simple Greek salad with tomatoes, cucumber, olives and feta.', 'Chop tomatoes and cucumber, toss with olives, red onion and feta; dress with olive oil and lemon.', 'https://www.bbcgoodfood.com/recipes/greek-salad', 10, 0, 4, true, false, true, false, true, true, 'tomato, cucumber, olives, feta, red onion', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Greek Salad');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Greek Salad' AND i.name = 'tomato'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Greek Salad' AND i.name = 'cucumber'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Greek Salad' AND i.name = 'olives'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Greek Salad' AND i.name = 'feta'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Greek Salad' AND i.name = 'red onion'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Chop vegetables and toss with dressing; sprinkle feta on top.'
FROM recipes r
WHERE r.title = 'Greek Salad'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

-- Recipe: Herb Baked Salmon
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Herb Baked Salmon', 'Easy baked salmon with lemon and fresh herbs.', 'Spread herbs and lemon over salmon, bake until just cooked through. Serve with salad or rice.', 'https://www.epicurious.com/recipes/food/views/roasted-salmon-green-herbs-ina-garten', 10, 18, 2, false, false, true, true, true, true, 'salmon, lemon, dill, parsley, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Herb Baked Salmon');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Herb Baked Salmon' AND i.name = 'salmon'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Herb Baked Salmon' AND i.name = 'lemon'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Herb Baked Salmon' AND i.name = 'dill'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Herb Baked Salmon' AND i.name = 'parsley'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Herb Baked Salmon' AND i.name = 'olive oil'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Preheat oven, season salmon with herbs and lemon; bake until just opaque.'
FROM recipes r
WHERE r.title = 'Herb Baked Salmon'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

-- Recipe: Chicken Shawarma Bowl
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Chicken Shawarma Bowl', 'Skillet chicken shawarma served over rice with salad and hummus.', 'Marinate chicken in shawarma spice, cook quickly in skillet; serve over rice with salad and hummus.', 'https://www.themediterraneandish.com/chicken-shawarma-salad-bowls/', 20, 15, 4, false, false, true, true, true, false, 'chicken breast, shawarma spice, rice, cucumber, hummus', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Chicken Shawarma Bowl');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chicken Shawarma Bowl' AND i.name = 'chicken breast'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chicken Shawarma Bowl' AND i.name = 'shawarma spice'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chicken Shawarma Bowl' AND i.name = 'rice'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chicken Shawarma Bowl' AND i.name = 'cucumber'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Chicken Shawarma Bowl' AND i.name = 'hummus'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Marinate chicken in spice mix and pan-sear until cooked.'
FROM recipes r
WHERE r.title = 'Chicken Shawarma Bowl'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Assemble over rice with cucumber salad and hummus.'
FROM recipes r
WHERE r.title = 'Chicken Shawarma Bowl'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Classic Falafel
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Classic Falafel', 'Crispy herb-packed falafel.', 'Process soaked chickpeas with herbs and spices; shape into patties and fry or bake until crisp.', 'https://www.seriouseats.com/the-food-lab-vegan-experience-best-homemade-falafel-recipe', 30, 10, 4, true, true, false, true, true, true, 'chickpeas, parsley, cilantro, garlic, cumin', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Classic Falafel');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Falafel' AND i.name = 'chickpeas'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Falafel' AND i.name = 'parsley'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Falafel' AND i.name = 'cilantro'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Falafel' AND i.name = 'garlic'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Falafel' AND i.name = 'cumin'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Pulse chickpeas with herbs and spices until coarse; form into balls.'
FROM recipes r
WHERE r.title = 'Classic Falafel'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Fry or bake until crisp and serve with tahini.'
FROM recipes r
WHERE r.title = 'Classic Falafel'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Shakshuka
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Shakshuka', 'Eggs poached in a spiced tomato-pepper sauce.', 'Sauté onion and peppers, add tomatoes and spices; crack eggs on top and simmer until set.', 'https://www.bbcgoodfood.com/recipes/shakshuka', 10, 15, 2, true, false, true, true, true, true, 'eggs, tomatoes, bell pepper, onion, paprika', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Shakshuka');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Shakshuka' AND i.name = 'eggs'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Shakshuka' AND i.name = 'tomatoes'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Shakshuka' AND i.name = 'bell pepper'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Shakshuka' AND i.name = 'onion'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Shakshuka' AND i.name = 'paprika'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Sauté onion and pepper, add tomatoes and spices.'
FROM recipes r
WHERE r.title = 'Shakshuka'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Crack eggs into sauce and cook until whites set.'
FROM recipes r
WHERE r.title = 'Shakshuka'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Quinoa Stuffed Bell Peppers
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Quinoa Stuffed Bell Peppers', 'Bell peppers stuffed with quinoa, vegetables and herbs.', 'Sauté vegetables, combine with cooked quinoa, stuff into peppers and bake until tender.', 'https://www.eatingwell.com/recipe/8028357/stuffed-peppers/', 20, 30, 4, true, true, true, true, true, true, 'bell pepper, quinoa, tomato, onion, garlic', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Quinoa Stuffed Bell Peppers');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Stuffed Bell Peppers' AND i.name = 'bell pepper'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Stuffed Bell Peppers' AND i.name = 'quinoa'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Stuffed Bell Peppers' AND i.name = 'tomato'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Stuffed Bell Peppers' AND i.name = 'onion'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Stuffed Bell Peppers' AND i.name = 'garlic'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Prepare filling by sautéing onion, garlic and tomato; mix with cooked quinoa.'
FROM recipes r
WHERE r.title = 'Quinoa Stuffed Bell Peppers'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Stuff into peppers and bake until peppers are tender.'
FROM recipes r
WHERE r.title = 'Quinoa Stuffed Bell Peppers'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Easy Miso Soup with Tofu
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Easy Miso Soup with Tofu', 'Comforting miso soup with soft tofu and wakame.', 'Make dashi (or use kombu for vegan), dissolve miso, add tofu and wakame; heat gently and serve.', 'https://www.justonecookbook.com/homemade-miso-soup/', 5, 10, 4, true, true, true, true, true, true, 'miso paste, tofu, wakame, dashi/kombu, scallion', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Easy Miso Soup with Tofu');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Easy Miso Soup with Tofu' AND i.name = 'miso paste'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Easy Miso Soup with Tofu' AND i.name = 'tofu'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Easy Miso Soup with Tofu' AND i.name = 'wakame'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Easy Miso Soup with Tofu' AND i.name = 'dashi/kombu'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Easy Miso Soup with Tofu' AND i.name = 'scallion'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Prepare dashi (or kombu water) and dissolve miso off the heat.'
FROM recipes r
WHERE r.title = 'Easy Miso Soup with Tofu'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Add diced tofu and wakame; warm gently and serve.'
FROM recipes r
WHERE r.title = 'Easy Miso Soup with Tofu'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Quinoa Tabbouleh
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Quinoa Tabbouleh', 'A gluten-free tabbouleh using quinoa instead of bulgur.', 'Cook quinoa; combine with lots of parsley, mint, tomato, cucumber and lemon; chill and serve.', 'https://frommybowl.com/quinoa-tabbouleh/', 15, 15, 4, true, true, true, true, true, true, 'quinoa, parsley, mint, tomato, lemon', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Quinoa Tabbouleh');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Tabbouleh' AND i.name = 'quinoa'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Tabbouleh' AND i.name = 'parsley'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Tabbouleh' AND i.name = 'mint'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Tabbouleh' AND i.name = 'tomato'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Quinoa Tabbouleh' AND i.name = 'lemon'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Cook quinoa and cool completely.'
FROM recipes r
WHERE r.title = 'Quinoa Tabbouleh'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Mix with chopped herbs and veggies; dress with lemon and olive oil.'
FROM recipes r
WHERE r.title = 'Quinoa Tabbouleh'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Almond Flour Chocolate Chip Cookies (GF)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Almond Flour Chocolate Chip Cookies (GF)', 'Gluten-free almond flour cookies.', 'Combine almond flour, egg or substitute, sweetener and chocolate chips; scoop and bake until set.', 'https://www.kingarthurbaking.com/recipes/gluten-free-almond-flour-chocolate-chip-cookies-recipe', 10, 10, 12, true, false, true, false, true, true, 'almond flour, sugar, chocolate chips, baking soda, egg or flax egg', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Almond Flour Chocolate Chip Cookies (GF)');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Almond Flour Chocolate Chip Cookies (GF)' AND i.name = 'almond flour'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Almond Flour Chocolate Chip Cookies (GF)' AND i.name = 'sugar'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Almond Flour Chocolate Chip Cookies (GF)' AND i.name = 'chocolate chips'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Almond Flour Chocolate Chip Cookies (GF)' AND i.name = 'baking soda'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Almond Flour Chocolate Chip Cookies (GF)' AND i.name = 'egg or flax egg'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Mix wet and dry ingredients; fold in chips.'
FROM recipes r
WHERE r.title = 'Almond Flour Chocolate Chip Cookies (GF)'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Scoop onto a tray and bake until edges set.'
FROM recipes r
WHERE r.title = 'Almond Flour Chocolate Chip Cookies (GF)'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Coconut Peanut Vegetable Curry
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Coconut Peanut Vegetable Curry', 'A creamy vegetable curry with coconut milk and peanut.', 'Sauté veg paste, add curry paste, lentils or chickpeas, coconut milk and simmer until tender; finish with lime and peanuts.', 'https://www.bbcgoodfood.com/recipes/peanut-coconut-curry', 15, 20, 4, true, true, true, true, true, true, 'coconut milk, chickpeas, curry paste, spinach, peanut', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Coconut Peanut Vegetable Curry');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Coconut Peanut Vegetable Curry' AND i.name = 'coconut milk'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Coconut Peanut Vegetable Curry' AND i.name = 'chickpeas'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Coconut Peanut Vegetable Curry' AND i.name = 'curry paste'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Coconut Peanut Vegetable Curry' AND i.name = 'spinach'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Coconut Peanut Vegetable Curry' AND i.name = 'peanut'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Fry aromatics and curry paste; add coconut milk and chickpeas and simmer.'
FROM recipes r
WHERE r.title = 'Coconut Peanut Vegetable Curry'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Stir in spinach and peanuts; finish with lime.'
FROM recipes r
WHERE r.title = 'Coconut Peanut Vegetable Curry'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Classic Hummus
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Classic Hummus', 'Silky hummus made with chickpeas, tahini and lemon.', 'Blend cooked chickpeas with tahini, lemon, garlic and olive oil until smooth; adjust seasoning and consistency.', 'https://www.seriouseats.com/israeli-style-extra-smooth-hummus-recipe', 10, 0, 4, true, true, true, true, true, true, 'chickpeas, tahini, lemon, garlic, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Classic Hummus');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Hummus' AND i.name = 'chickpeas'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Hummus' AND i.name = 'tahini'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Hummus' AND i.name = 'lemon'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Hummus' AND i.name = 'garlic'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Classic Hummus' AND i.name = 'olive oil'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Blend chickpeas with tahini and lemon; adjust with reserved chickpea liquid for smoothness.'
FROM recipes r
WHERE r.title = 'Classic Hummus'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

-- Recipe: Roasted Cauliflower Tacos
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Roasted Cauliflower Tacos', 'Smoky roasted cauliflower with romesco/cashew crema and corn tortillas.', 'Roast spiced cauliflower until caramelized; assemble on corn tortillas with crema and slaw.', 'https://minimalistbaker.com/roasted-cauliflower-tacos-with-chipotle-romesco/', 15, 25, 4, true, true, true, true, true, true, 'cauliflower, corn tortillas, chipotle, lime, cashew', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Roasted Cauliflower Tacos');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Roasted Cauliflower Tacos' AND i.name = 'cauliflower'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Roasted Cauliflower Tacos' AND i.name = 'corn tortillas'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Roasted Cauliflower Tacos' AND i.name = 'chipotle'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Roasted Cauliflower Tacos' AND i.name = 'lime'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Roasted Cauliflower Tacos' AND i.name = 'cashew'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Toss cauliflower with spices and roast until browned.'
FROM recipes r
WHERE r.title = 'Roasted Cauliflower Tacos'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Warm tortillas and assemble with crema and slaw.'
FROM recipes r
WHERE r.title = 'Roasted Cauliflower Tacos'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- Recipe: Berry Oat Porridge
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Berry Oat Porridge', 'Creamy porridge topped with warm berry compote.', 'Cook oats in milk or water until creamy; top with stewed berries and seeds or nuts.', 'https://www.bbcgoodfood.com/recipes/collection/porridge-recipes', 5, 10, 2, true, true, false, true, true, true, 'rolled oats, berries, almond milk, chia seed, maple syrup', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title = 'Berry Oat Porridge');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Berry Oat Porridge' AND i.name = 'rolled oats'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Berry Oat Porridge' AND i.name = 'berries'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Berry Oat Porridge' AND i.name = 'almond milk'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Berry Oat Porridge' AND i.name = 'chia seed'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title = 'Berry Oat Porridge' AND i.name = 'maple syrup'
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id AND ri.ingredient_id = i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Cook oats in milk; stir until creamy.'
FROM recipes r
WHERE r.title = 'Berry Oat Porridge'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 1);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 2, 'Top with warm berries and a drizzle of maple syrup.'
FROM recipes r
WHERE r.title = 'Berry Oat Porridge'
  AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = r.id AND rs.step_index = 2);

-- End of safe insert script
