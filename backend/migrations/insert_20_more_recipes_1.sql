-- insert_20_more_recipes.sql
-- Adds 20 additional recipes (idempotent).
-- Designed to be compatible with your existing schema and the style of insert_20_recipes_safe.sql. 
-- Run after your schema + previous sample inserts.

-- Ensure common units exist (try minimal insert similarly to the other file)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='gram') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('gram');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, display_name) VALUES ('gram','gram');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='ml') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('ml');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, display_name) VALUES ('ml','milliliter');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='cup') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('cup');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, display_name) VALUES ('cup','cup');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='tbsp') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('tbsp');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, display_name) VALUES ('tbsp','tablespoon');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='tsp') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('tsp');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, display_name) VALUES ('tsp','teaspoon');
      END;
    END;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='piece') THEN
    BEGIN
      BEGIN
        INSERT INTO units (key) VALUES ('piece');
      EXCEPTION WHEN undefined_column THEN
        INSERT INTO units (key, display_name) VALUES ('piece','piece');
      END;
    END;
  END IF;
END$$;

-- New ingredients required by these 20 recipes.
-- Insert only if missing to be safe/idempotent.
INSERT INTO ingredients (name)
SELECT 'sweet potato'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='sweet potato');

INSERT INTO ingredients (name)
SELECT 'avocado'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='avocado');

INSERT INTO ingredients (name)
SELECT 'black beans'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='black beans');

INSERT INTO ingredients (name)
SELECT 'coriander'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='coriander');

INSERT INTO ingredients (name)
SELECT 'cinnamon'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='cinnamon');

INSERT INTO ingredients (name)
SELECT 'halloumi'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='halloumi');

INSERT INTO ingredients (name)
SELECT 'yogurt'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='yogurt');

INSERT INTO ingredients (name)
SELECT 'ground beef'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='ground beef');

INSERT INTO ingredients (name)
SELECT 'eggplant'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='eggplant');

INSERT INTO ingredients (name)
SELECT 'sesame oil'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='sesame oil');

INSERT INTO ingredients (name)
SELECT 'soba noodles'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='soba noodles');

INSERT INTO ingredients (name)
SELECT 'shiitake mushroom'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='shiitake mushroom');

INSERT INTO ingredients (name)
SELECT 'bok choy'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='bok choy');

INSERT INTO ingredients (name)
SELECT 'pita'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='pita');

INSERT INTO ingredients (name)
SELECT 'rosemary'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='rosemary');

INSERT INTO ingredients (name)
SELECT 'shrimp'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='shrimp');

INSERT INTO ingredients (name)
SELECT 'arborio rice'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='arborio rice');

INSERT INTO ingredients (name)
SELECT 'pumpkin'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='pumpkin');

INSERT INTO ingredients (name)
SELECT 'cocoa powder'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='cocoa powder');

INSERT INTO ingredients (name)
SELECT 'sesame seeds'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='sesame seeds');

INSERT INTO ingredients (name)
SELECT 'beet'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='beet');

INSERT INTO ingredients (name)
SELECT 'goat cheese'
WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='goat cheese');

-- NOTE: many basic ingredients (rice, pasta, lemon, chickpeas, quinoa, tofu, etc.)
-- are already present in your earlier insert file (see existing file). Reference: :contentReference[oaicite:1]{index=1}

-- Now add 20 recipes (idempotent inserts) + recipe_ingredients + recipe_steps.

-- 1) Vegan Buddha Bowl (vegan, vegetarian, gluten_free, dairy_free, halal, kosher)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Vegan Buddha Bowl', 'Roasted sweet potato, quinoa, avocado, chickpeas and greens with tahini dressing.', 'Roast sweet potato; cook quinoa; assemble with greens, chickpeas and a drizzle of tahini dressing.', '', 15, 30, 2, true, true, true, true, true, true, 'quinoa, sweet potato, avocado, chickpeas, spinach, tahini', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Vegan Buddha Bowl');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 150, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Vegan Buddha Bowl' AND i.name IN ('quinoa','sweet potato','avocado','chickpeas','spinach','tahini')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Roast sweet potato with a little oil and salt until tender.' FROM recipes r WHERE r.title='Vegan Buddha Bowl' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Cook quinoa, warm chickpeas; assemble with spinach, sliced avocado and tahini dressing.' FROM recipes r WHERE r.title='Vegan Buddha Bowl' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 2) Sweet Potato & Red Lentil Dahl (vegan, GF)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Sweet Potato & Red Lentil Dahl', 'Comforting spiced dahl with sweet potato.', 'Sauté aromatics, add red lentils and diced sweet potato with stock; simmer until soft and spiced.', '', 10, 30, 4, true, true, true, true, true, true, 'red lentils, sweet potato, curry powder, coconut milk, garlic', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Sweet Potato & Red Lentil Dahl');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 200, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Sweet Potato & Red Lentil Dahl' AND i.name IN ('red lentils','sweet potato','curry paste','coconut milk','garlic')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Sauté garlic and curry paste; add lentils, sweet potato and stock; simmer until lentils break down.' FROM recipes r WHERE r.title='Sweet Potato & Red Lentil Dahl' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Stir in coconut milk; simmer to desired consistency and serve with rice.' FROM recipes r WHERE r.title='Sweet Potato & Red Lentil Dahl' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 3) Black Bean Tacos (vegan; GF if corn tortillas)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Black Bean Tacos', 'Smoky black beans in corn tortillas with avocado and lime.', 'Warm beans with spices; assemble in tortillas with avocado, cilantro and lime.', '', 10, 10, 4, true, true, true, true, true, true, 'black beans, corn tortillas, avocado, lime, cilantro', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Black Bean Tacos');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 120, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Black Bean Tacos' AND i.name IN ('black beans','corn tortillas','avocado','lime','cilantro')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Heat black beans with cumin and paprika; mash slightly.' FROM recipes r WHERE r.title='Black Bean Tacos' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Warm tortillas; fill with beans, sliced avocado, cilantro and lime.' FROM recipes r WHERE r.title='Black Bean Tacos' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 4) Moroccan Chickpea Stew (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Moroccan Chickpea Stew', 'A fragrant chickpea stew with warming spices.', 'Sauté onion and garlic, add spices, tomatoes and chickpeas; simmer and finish with coriander and lemon.', '', 10, 25, 4, true, true, true, true, true, true, 'chickpeas, tomato, coriander, cinnamon, cumin', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Moroccan Chickpea Stew');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 200, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Moroccan Chickpea Stew' AND i.name IN ('chickpeas','tomato','coriander','cinnamon','cumin')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Sauté onion and spices; add tomatoes and chickpeas; simmer until thick.' FROM recipes r WHERE r.title='Moroccan Chickpea Stew' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Finish with chopped coriander and lemon juice.' FROM recipes r WHERE r.title='Moroccan Chickpea Stew' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 5) Grilled Halloumi & Watermelon Salad (vegetarian)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Grilled Halloumi & Watermelon Salad', 'Slightly salty halloumi with sweet watermelon and mint.', 'Grill slices of halloumi; combine with cubed watermelon, mint and a drizzle of lime.', '', 10, 5, 2, true, false, true, false, true, false, 'halloumi, watermelon, mint, lime', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Grilled Halloumi & Watermelon Salad');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 80, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Grilled Halloumi & Watermelon Salad' AND i.name IN ('halloumi','watermelon','mint','lime')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Slice and grill halloumi until golden.' FROM recipes r WHERE r.title='Grilled Halloumi & Watermelon Salad' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Toss watermelon and mint; top with halloumi and a squeeze of lime.' FROM recipes r WHERE r.title='Grilled Halloumi & Watermelon Salad' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 6) Salmon with Dill Yogurt Sauce (gluten_free)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Salmon with Dill Yogurt Sauce', 'Baked salmon served with a tangy dill-yogurt sauce.', 'Bake salmon; mix yogurt with dill and lemon; serve over salmon.', '', 10, 15, 2, false, false, true, false, true, true, 'salmon, yogurt, dill, lemon, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Salmon with Dill Yogurt Sauce');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 180, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Salmon with Dill Yogurt Sauce' AND i.name IN ('salmon','yogurt','dill','lemon','olive oil')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Season salmon and bake until just cooked.' FROM recipes r WHERE r.title='Salmon with Dill Yogurt Sauce' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Whisk yogurt with dill and lemon; spoon over salmon.' FROM recipes r WHERE r.title='Salmon with Dill Yogurt Sauce' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 7) Beef Kofta with Tahini (halal)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Beef Kofta with Tahini', 'Spiced beef kofta skewers served with tahini sauce.', 'Mix beef with spices and parsley; form onto skewers and grill; serve with tahini.', '', 20, 12, 4, false, false, true, true, true, false, 'ground beef, cumin, parsley, tahini, garlic', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Beef Kofta with Tahini');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 120, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Beef Kofta with Tahini' AND i.name IN ('ground beef','cumin','parsley','tahini','garlic')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Combine ground beef with chopped parsley, cumin and garlic; form onto skewers.' FROM recipes r WHERE r.title='Beef Kofta with Tahini' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Grill until cooked and serve with tahini sauce.' FROM recipes r WHERE r.title='Beef Kofta with Tahini' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 8) Miso-Glazed Eggplant (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Miso-Glazed Eggplant', 'Umami-rich roasted eggplant topped with miso glaze.', 'Roast halved eggplant; brush with miso-sesame glaze and broil to caramelize; garnish with scallion.', '', 10, 25, 2, true, true, true, true, true, true, 'eggplant, miso paste, sesame oil, scallion', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Miso-Glazed Eggplant');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 200, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Miso-Glazed Eggplant' AND i.name IN ('eggplant','miso paste','sesame oil','scallion')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Halve eggplants and roast until tender.' FROM recipes r WHERE r.title='Miso-Glazed Eggplant' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Brush with miso-sesame glaze and broil to caramelize; garnish with scallions.' FROM recipes r WHERE r.title='Miso-Glazed Eggplant' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 9) Chickpea & Spinach Curry (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Chickpea & Spinach Curry', 'Quick chickpea curry with spinach and coconut milk.', 'Sauté spices, add chickpeas and coconut milk; stir in spinach until wilted.', '', 8, 15, 4, true, true, true, true, true, true, 'chickpeas, spinach, coconut milk, curry paste, garlic', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Chickpea & Spinach Curry');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 180, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Chickpea & Spinach Curry' AND i.name IN ('chickpeas','spinach','coconut milk','curry paste','garlic')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Fry curry paste and garlic; add chickpeas and coconut milk; simmer.' FROM recipes r WHERE r.title='Chickpea & Spinach Curry' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Stir in spinach until just wilted; serve with rice or flatbread.' FROM recipes r WHERE r.title='Chickpea & Spinach Curry' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 10) Vegetable Soba Noodle Bowl (vegan or vegetarian)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Vegetable Soba Noodle Bowl', 'Soba noodles with shiitake, bok choy and a sesame-soy dressing.', 'Cook soba; sauté shiitake and bok choy; toss with sesame-soy dressing and scallions.', '', 10, 10, 2, true, true, false, true, true, true, 'soba noodles, shiitake mushroom, bok choy, soy sauce, sesame seeds', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Vegetable Soba Noodle Bowl');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 120, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Vegetable Soba Noodle Bowl' AND i.name IN ('soba noodles','shiitake mushroom','bok choy','soy sauce','sesame seeds')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Cook soba according to package; drain and rinse.' FROM recipes r WHERE r.title='Vegetable Soba Noodle Bowl' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Sauté mushrooms and bok choy; toss everything with dressing and sprinkle sesame seeds.' FROM recipes r WHERE r.title='Vegetable Soba Noodle Bowl' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 11) Shoyu Tofu Rice Bowl (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Shoyu Tofu Rice Bowl', 'Marinated tofu with soy glaze served over rice and scallions.', 'Marinate tofu in soy sauce mix; pan-fry until glazed; serve over rice with scallions.', '', 10, 15, 2, true, true, false, true, true, true, 'tofu, soy sauce, rice, scallion, sesame oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Shoyu Tofu Rice Bowl');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 140, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Shoyu Tofu Rice Bowl' AND i.name IN ('tofu','soy sauce','rice','scallion','sesame oil')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Marinate tofu, then pan-fry until caramelized.' FROM recipes r WHERE r.title='Shoyu Tofu Rice Bowl' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Serve over rice and top with sliced scallions.' FROM recipes r WHERE r.title='Shoyu Tofu Rice Bowl' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 12) Roasted Beet & Goat Cheese Salad (vegetarian)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Roasted Beet & Goat Cheese Salad', 'Earthy roasted beets with creamy goat cheese and walnuts.', 'Roast beets; toss with vinaigrette and top with crumbled goat cheese and nuts.', '', 10, 45, 4, true, false, true, false, true, true, 'beet, goat cheese, olive oil, walnuts, arugula', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Roasted Beet & Goat Cheese Salad');

INSERT INTO ingredients (name)
SELECT 'walnuts' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='walnuts');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Roasted Beet & Goat Cheese Salad' AND i.name IN ('beet','goat cheese','olive oil','walnuts','arugula')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Roast beets wrapped in foil until tender; peel and slice.' FROM recipes r WHERE r.title='Roasted Beet & Goat Cheese Salad' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Assemble on arugula and top with goat cheese and a drizzle of olive oil.' FROM recipes r WHERE r.title='Roasted Beet & Goat Cheese Salad' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 13) Turkish Red Lentil Patties (Mercimek Köftesi) (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Turkish Red Lentil Patties', 'Spiced red lentil and bulgur patties - classic mezze.', 'Cook lentils, mix with soaked bulgur and spices; shape and chill to set.', '', 25, 10, 6, true, true, false, true, true, true, 'red lentils, bulgur, tomato paste, parsley, mint', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Turkish Red Lentil Patties');

INSERT INTO ingredients (name)
SELECT 'bulgur' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='bulgur');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 150, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Turkish Red Lentil Patties' AND i.name IN ('red lentils','bulgur','tomato paste','parsley','mint')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Cook red lentils until soft; mix with bulgur and seasonings; chill.' FROM recipes r WHERE r.title='Turkish Red Lentil Patties' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Form into patties and serve with lemon and parsley.' FROM recipes r WHERE r.title='Turkish Red Lentil Patties' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 14) Baked Falafel Wrap (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Baked Falafel Wrap', 'Crispy baked falafel tucked into pita with tahini and salad.', 'Form falafel from chickpeas and bake; stuff into pita with tahini and salad.', '', 30, 20, 4, true, true, false, true, true, true, 'chickpeas, tahini, pita, parsley, garlic', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Baked Falafel Wrap');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 80, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Baked Falafel Wrap' AND i.name IN ('chickpeas','tahini','pita','parsley','garlic')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Pulse soaked chickpeas with herbs and spices; form balls and bake.' FROM recipes r WHERE r.title='Baked Falafel Wrap' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Warm pita; fill with falafel, salad and tahini.' FROM recipes r WHERE r.title='Baked Falafel Wrap' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 15) Lemon Herb Chicken (halal)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Lemon Herb Chicken', 'Simple roast chicken with lemon and fresh rosemary.', 'Marinate chicken in lemon, garlic and rosemary; roast until juices run clear.', '', 15, 35, 4, false, false, true, true, true, false, 'chicken breast, lemon, rosemary, garlic, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Lemon Herb Chicken');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 180, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Lemon Herb Chicken' AND i.name IN ('chicken breast','lemon','rosemary','garlic','olive oil')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Marinate chicken with lemon, garlic and rosemary; roast until cooked through.' FROM recipes r WHERE r.title='Lemon Herb Chicken' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Rest for a few minutes then slice and serve.' FROM recipes r WHERE r.title='Lemon Herb Chicken' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 16) Shrimp & Garlic Linguine
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Shrimp & Garlic Linguine', 'Quick garlic shrimp with toss of linguine and parsley.', 'Cook pasta; sauté garlic and shrimp; toss with pasta, lemon and parsley.', '', 10, 10, 2, false, false, false, false, false, false, 'shrimp, garlic, pasta, parsley, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Shrimp & Garlic Linguine');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 140, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Shrimp & Garlic Linguine' AND i.name IN ('shrimp','garlic','pasta','parsley','olive oil')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Cook linguine until al dente.' FROM recipes r WHERE r.title='Shrimp & Garlic Linguine' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Sauté garlic and shrimp; add pasta and toss with parsley and olive oil.' FROM recipes r WHERE r.title='Shrimp & Garlic Linguine' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 17) Vegan Mushroom Risotto (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Vegan Mushroom Risotto', 'Creamy risotto made without dairy using olive oil and mushroom stock.', 'Sauté mushrooms; toast arborio rice; add stock gradually until creamy; finish with herbs.', '', 10, 30, 4, true, true, false, true, true, true, 'arborio rice, shiitake mushroom, vegetable stock, olive oil, parsley', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Vegan Mushroom Risotto');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 200, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Vegan Mushroom Risotto' AND i.name IN ('arborio rice','shiitake mushroom','vegetable stock','olive oil','parsley')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Sauté mushrooms and set aside.' FROM recipes r WHERE r.title='Vegan Mushroom Risotto' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Cook arborio rice slowly adding stock until creamy; stir in mushrooms and herbs.' FROM recipes r WHERE r.title='Vegan Mushroom Risotto' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 18) Spiced Pumpkin Soup (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Spiced Pumpkin Soup', 'Velvety pumpkin soup with warming spices and coconut milk.', 'Sauté onions and spices; add pumpkin and stock; puree and finish with coconut milk.', '', 15, 25, 4, true, true, true, true, true, true, 'pumpkin, coconut milk, vegetable stock, cumin, cinnamon', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Spiced Pumpkin Soup');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 400, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Spiced Pumpkin Soup' AND i.name IN ('pumpkin','coconut milk','vegetable stock','cumin','cinnamon')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Sauté aromatics and spices; add pumpkin and stock and simmer.' FROM recipes r WHERE r.title='Spiced Pumpkin Soup' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Blend until smooth and stir in coconut milk; reheat and serve.' FROM recipes r WHERE r.title='Spiced Pumpkin Soup' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 19) Avocado Chocolate Mousse (vegan, GF)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Avocado Chocolate Mousse', 'Rich chocolate mousse made from avocado and cocoa; naturally sweetened.', 'Blend ripe avocado with cocoa powder and maple syrup until silky; chill and serve.', '', 10, 0, 4, true, true, true, true, true, true, 'avocado, cocoa powder, maple syrup, vanilla', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Avocado Chocolate Mousse');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 120, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Avocado Chocolate Mousse' AND i.name IN ('avocado','cocoa powder','maple syrup','vanilla')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Blend avocado, cocoa, maple syrup and vanilla until smooth; chill.' FROM recipes r WHERE r.title='Avocado Chocolate Mousse' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1);

-- 20) Smashed Cucumber Salad with Sesame (vegan)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Smashed Cucumber Salad with Sesame', 'Bright, crunchy cucumber salad dressed with sesame and soy.', 'Smash cucumbers, toss with soy, rice vinegar, sesame oil and seeds; chill and serve.', '', 8, 0, 2, true, true, true, true, true, true, 'cucumber, soy sauce, rice vinegar, sesame oil, sesame seeds', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Smashed Cucumber Salad with Sesame');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 100, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Smashed Cucumber Salad with Sesame' AND i.name IN ('cucumber','soy sauce','sesame oil','sesame seeds','rice vinegar')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id, 1, 'Smash cucumbers to open their flesh; drain excess water.' FROM recipes r WHERE r.title='Smashed Cucumber Salad with Sesame' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id, 2, 'Toss with soy, rice vinegar, sesame oil and seeds; chill before serving.' FROM recipes r WHERE r.title='Smashed Cucumber Salad with Sesame' AND NOT EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- End of insert_20_more_recipes.sql
