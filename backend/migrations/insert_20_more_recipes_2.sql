-- insert_20_more_recipes_b2.sql
-- Adds another 20 recipes (idempotent). Run after your schema and previous sample inserts.

-- Ensure common units exist (defensive)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='gram') THEN INSERT INTO units (key) VALUES ('gram'); END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='ml') THEN INSERT INTO units (key) VALUES ('ml'); END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='cup') THEN INSERT INTO units (key) VALUES ('cup'); END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='tbsp') THEN INSERT INTO units (key) VALUES ('tbsp'); END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='tsp') THEN INSERT INTO units (key) VALUES ('tsp'); END IF;
  IF NOT EXISTS (SELECT 1 FROM units WHERE key='piece') THEN INSERT INTO units (key) VALUES ('piece'); END IF;
END$$;

-- New ingredients used in these 20 recipes
INSERT INTO ingredients(name) SELECT 'paneer' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='paneer');
INSERT INTO ingredients(name) SELECT 'sunflower seeds' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='sunflower seeds');
INSERT INTO ingredients(name) SELECT 'arugula' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='arugula');
INSERT INTO ingredients(name) SELECT 'pesto' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='pesto');
INSERT INTO ingredients(name) SELECT 'almond flour' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='almond flour');
INSERT INTO ingredients(name) SELECT 'banana' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='banana');
INSERT INTO ingredients(name) SELECT 'spinach' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='spinach');
INSERT INTO ingredients(name) SELECT 'edamame' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='edamame');
INSERT INTO ingredients(name) SELECT 'sesame paste' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='sesame paste');
INSERT INTO ingredients(name) SELECT 'nori' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='nori');
INSERT INTO ingredients(name) SELECT 'smoked mackerel' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='smoked mackerel');
INSERT INTO ingredients(name) SELECT 'feta' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='feta');
INSERT INTO ingredients(name) SELECT 'red pepper flakes' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='red pepper flakes');
INSERT INTO ingredients(name) SELECT 'turmeric' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='turmeric');
INSERT INTO ingredients(name) SELECT 'cardamom' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='cardamom');
INSERT INTO ingredients(name) SELECT 'filo pastry' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='filo pastry');
INSERT INTO ingredients(name) SELECT 'ricotta' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='ricotta');
INSERT INTO ingredients(name) SELECT 'sun-dried tomatoes' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='sun-dried tomatoes');
INSERT INTO ingredients(name) SELECT 'radicchio' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='radicchio');
INSERT INTO ingredients(name) SELECT 'polenta' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='polenta');
INSERT INTO ingredients(name) SELECT 'anchovy' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='anchovy');

-- 1) Mediterranean Lentil Salad (vegan, vegetarian, gluten_free, dairy_free, halal, kosher)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings,
  vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Mediterranean Lentil Salad',
  'Cooked lentils tossed with tomatoes, cucumber, arugula, and lemon-olive oil dressing.',
  'Cook lentils; chop vegetables; toss with lemon, olive oil and herbs.',
  '', 15, 20, 4, true, true, true, true, true, true,
  'lentils, tomato, cucumber, arugula, lemon, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Mediterranean Lentil Salad');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id, i.id, 200, (SELECT id FROM units WHERE key='gram' LIMIT 1), NULL
FROM recipes r, ingredients i
WHERE r.title='Mediterranean Lentil Salad' AND i.name IN ('red lentils','tomato','cucumber','arugula','lemon','olive oil')
  AND NOT EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id, step_index, step_text)
SELECT r.id,1,'Cook lentils until tender; drain and cool.' FROM recipes r WHERE r.title='Mediterranean Lentil Salad' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Chop vegetables and toss with lemon, olive oil, lentils and herbs.' FROM recipes r WHERE r.title='Mediterranean Lentil Salad' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 2) Paneer Tikka Skewers (vegetarian, halal if paneer acceptable)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings,
  vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Paneer Tikka Skewers',
  'Marinated paneer cubes grilled with peppers and onions.',
  'Marinate paneer and veggies; skewer and grill until charred.', '', 20, 12, 4, true, false, true, false, true, false,
  'paneer, bell pepper, onion, yogurt, spices', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Paneer Tikka Skewers');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id, note)
SELECT r.id,i.id,200,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Paneer Tikka Skewers' AND i.name IN ('paneer','bell pepper','onion','yogurt','garam masala')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Cube paneer and marinate in spiced yogurt.' FROM recipes r WHERE r.title='Paneer Tikka Skewers' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Skewer with peppers and onions and grill until golden.' FROM recipes r WHERE r.title='Paneer Tikka Skewers' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 3) Shakshuka (vegetarian, halal, kosher)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings,
  vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Shakshuka',
  'Poached eggs in a spiced tomato and pepper sauce.',
  'Sauté peppers and onions with spices; add tomatoes and simmer; crack eggs and poach in the sauce.',
  '', 10, 15, 2, true, false, true, false, true, true,
  'eggs, tomato, bell pepper, onion, cumin, paprika', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Shakshuka');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,3,(SELECT id FROM units WHERE key='piece' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Shakshuka' AND i.name IN ('eggs','tomato','bell pepper','onion','cumin','paprika')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Sauté onion and pepper with spices.' FROM recipes r WHERE r.title='Shakshuka' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Add tomatoes; simmer then crack eggs and cook until set.' FROM recipes r WHERE r.title='Shakshuka' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 4) Greek Salad with Feta (vegetarian, gluten_free)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings,
  vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Greek Salad with Feta',
  'Cucumber, tomato, olives and feta with oregano and olive oil.',
  'Toss chopped veg with olives, feta, oregano and olive oil.',
  '', 10, 0, 4, true, false, true, false, true, true,
  'cucumber, tomato, olives, feta, oregano, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Greek Salad with Feta');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,80,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Greek Salad with Feta' AND i.name IN ('cucumber','tomato','olives','feta','oregano','olive oil')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Chop vegetables and toss with olives, crumbled feta and olive oil.' FROM recipes r WHERE r.title='Greek Salad with Feta' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1);

-- 5) Hearty Lentil Soup (vegan, gluten_free)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings,
  vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Hearty Lentil Soup',
  'Classic lentil soup with carrots, celery and tomato.',
  'Sauté base, add lentils and stock; simmer until tender and blend slightly if desired.',
  '', 15, 40, 6, true, true, true, true, true, true,
  'lentils, carrot, celery, tomato, vegetable stock, bay leaf', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Hearty Lentil Soup');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,250,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Hearty Lentil Soup' AND i.name IN ('red lentils','carrot','celery','tomato','vegetable stock','bay leaf')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Sauté carrot, celery and onion; add lentils, stock and bay leaf.' FROM recipes r WHERE r.title='Hearty Lentil Soup' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Simmer until lentils are tender; season and serve.' FROM recipes r WHERE r.title='Hearty Lentil Soup' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 6) Korean Bibimbap (vegetarian option included)
INSERT INTO recipes (title, summary, instructions, image_url, prep_minutes, cook_minutes, servings,
  vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, created_at)
SELECT 'Korean Bibimbap (Tofu)',
  'Rice bowl with sautéed veg, marinated tofu and spicy gochujang sauce.',
  'Prepare rice; sauté vegetables; marinate and pan-fry tofu; assemble with sauce and egg if desired.',
  '', 20, 15, 2, true, true, false, true, true, true,
  'rice, tofu, spinach, carrot, gochujang, sesame oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Korean Bibimbap (Tofu)');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,140,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Korean Bibimbap (Tofu)' AND i.name IN ('rice','tofu','spinach','carrot','gochujang','sesame oil')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Cook rice and prep vegetables.' FROM recipes r WHERE r.title='Korean Bibimbap (Tofu)' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Pan-fry marinated tofu; assemble bowl and drizzle with gochujang sauce.' FROM recipes r WHERE r.title='Korean Bibimbap (Tofu)' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 7) Tofu Stir-Fry with Edamame (vegan, dairy_free)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Tofu Stir-Fry with Edamame',
  'Quick stir-fry with tofu, edamame and mixed vegetables in a savory sauce.',
  'Stir-fry tofu and vegetables; add sauce and toss until coated; finish with sesame seeds.',
  '', 10, 8, 2, true, true, false, true, true, true,
  'tofu, edamame, bell pepper, soy sauce, sesame seeds', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Tofu Stir-Fry with Edamame');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,150,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Tofu Stir-Fry with Edamame' AND i.name IN ('tofu','edamame','bell pepper','soy sauce','sesame seeds')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Cube tofu and stir-fry until golden; remove.' FROM recipes r WHERE r.title='Tofu Stir-Fry with Edamame' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Stir-fry vegetables, return tofu and add sauce; garnish with sesame seeds.' FROM recipes r WHERE r.title='Tofu Stir-Fry with Edamame' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 8) Nori-Wrapped Smoked Mackerel Salad (pescatarian)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Nori-Wrapped Smoked Mackerel Salad',
  'Smoked mackerel flaked on greens, wrapped or served with nori strips and sesame.',
  'Combine flaked mackerel with greens and dressing; serve with toasted nori strips.',
  '', 10, 0, 2, false, false, true, true, false, false,
  'smoked mackerel, nori, arugula, sesame oil, lemon', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Nori-Wrapped Smoked Mackerel Salad');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,100,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Nori-Wrapped Smoked Mackerel Salad' AND i.name IN ('smoked mackerel','nori','arugula','sesame oil','lemon')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Flake smoked mackerel and toss with greens and lemon.' FROM recipes r WHERE r.title='Nori-Wrapped Smoked Mackerel Salad' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1);

-- 9) Pesto Zucchini Noodles (vegetarian, gluten_free)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Pesto Zucchini Noodles',
  'Spiralized zucchini tossed with pesto, cherry tomatoes and pine nuts.',
  'Spiralize zucchini; toss with pesto and tomatoes; top with nuts or seeds.',
  '', 15, 5, 2, true, false, true, false, true, true,
  'zucchini, pesto, cherry tomato, pine nuts, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Pesto Zucchini Noodles');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,200,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Pesto Zucchini Noodles' AND i.name IN ('zucchini','pesto','sun-dried tomatoes','pine nuts','olive oil')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Spiralize zucchini and lightly sauté or serve raw.' FROM recipes r WHERE r.title='Pesto Zucchini Noodles' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Toss with pesto, tomatoes and pine nuts.' FROM recipes r WHERE r.title='Pesto Zucchini Noodles' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 10) Almond Flour Pancakes (gluten_free, vegetarian)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Almond Flour Pancakes',
  'Light, gluten-free pancakes made with almond flour and eggs.',
  'Mix almond flour with eggs and milk; cook like regular pancakes until golden.',
  '', 10, 10, 2, true, false, true, false, true, true,
  'almond flour, egg, milk, baking powder, vanilla', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Almond Flour Pancakes');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,120,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Almond Flour Pancakes' AND i.name IN ('almond flour','egg','milk','baking powder','vanilla')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Mix wet and dry ingredients to a batter.' FROM recipes r WHERE r.title='Almond Flour Pancakes' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Cook batter on a hot pan until golden.' FROM recipes r WHERE r.title='Almond Flour Pancakes' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 11) Quinoa Stuffed Peppers (vegan option)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Quinoa Stuffed Peppers',
  'Bell peppers stuffed with quinoa, vegetables and herbs; baked until tender.',
  'Cook quinoa, mix with sautéed vegetables and herbs, stuff peppers and bake.',
  '', 20, 30, 4, true, true, true, true, true, true,
  'quinoa, bell pepper, onion, tomato, feta (optional), parsley', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Quinoa Stuffed Peppers');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,180,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Quinoa Stuffed Peppers' AND i.name IN ('quinoa','bell pepper','onion','tomato','parsley','feta')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Cook quinoa and sauté vegetables.' FROM recipes r WHERE r.title='Quinoa Stuffed Peppers' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Stuff peppers with mixture and bake until peppers are tender.' FROM recipes r WHERE r.title='Quinoa Stuffed Peppers' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 12) Tuna Niçoise Salad (pescatarian; not halal/kosher marked)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Tuna Niçoise Salad',
  'Classic Niçoise with seared tuna, green beans, eggs and olives.',
  'Assemble cooked potatoes, beans, eggs and seared tuna on greens; dress with vinaigrette.',
  '', 20, 10, 2, false, false, true, true, false, false,
  'tuna, green beans, egg, olives, potato, anchovy (optional)', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Tuna Niçoise Salad');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,120,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Tuna Niçoise Salad' AND i.name IN ('tuna','green beans','egg','olives','potato','anchovy')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Poach eggs and sear tuna; blanch green beans and potatoes.' FROM recipes r WHERE r.title='Tuna Niçoise Salad' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Arrange on a platter and drizzle with vinaigrette.' FROM recipes r WHERE r.title='Tuna Niçoise Salad' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 13) Ricotta & Spinach Filo Parcels (vegetarian)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Ricotta & Spinach Filo Parcels',
  'Filo parcels filled with ricotta, spinach and lemon zest; baked until crisp.',
  'Mix ricotta with spinach and seasoning; fill filo and bake until golden.',
  '', 20, 18, 6, true, false, false, false, true, true,
  'ricotta, spinach, filo pastry, lemon, nutmeg', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Ricotta & Spinach Filo Parcels');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,120,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Ricotta & Spinach Filo Parcels' AND i.name IN ('ricotta','spinach','filo pastry','lemon','nutmeg')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Combine ricotta, chopped spinach and lemon zest.' FROM recipes r WHERE r.title='Ricotta & Spinach Filo Parcels' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Fill filo sheets, brush with oil and bake until crisp.' FROM recipes r WHERE r.title='Ricotta & Spinach Filo Parcels' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 14) Spiced Chickpea Flatbread (vegan)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Spiced Chickpea Flatbread',
  'Chickpea flour flatbreads spiced with cumin and served with chutney.',
  'Mix chickpea flour batter; cook on a griddle and serve warm.',
  '', 10, 10, 4, true, true, true, true, true, true,
  'chickpea flour, cumin, coriander, water, olive oil', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Spiced Chickpea Flatbread');

INSERT INTO ingredients(name) SELECT 'chickpea flour' WHERE NOT EXISTS (SELECT 1 FROM ingredients WHERE name='chickpea flour');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,120,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Spiced Chickpea Flatbread' AND i.name IN ('chickpea flour','cumin','coriander','olive oil','water')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Mix chickpea flour with water and spices into a batter.' FROM recipes r WHERE r.title='Spiced Chickpea Flatbread' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Cook on a hot griddle until set and golden.' FROM recipes r WHERE r.title='Spiced Chickpea Flatbread' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 15) Polenta with Mushroom Ragù (vegetarian, can be gluten_free)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Polenta with Mushroom Ragù',
  'Creamy polenta topped with a rich mushroom ragù and rosemary.',
  'Cook polenta until creamy; sauté mushrooms with garlic and rosemary then spoon over polenta.',
  '', 15, 20, 4, true, false, true, false, true, true,
  'polenta, shiitake mushroom, garlic, rosemary, parmesan (optional)', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Polenta with Mushroom Ragù');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,200,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Polenta with Mushroom Ragù' AND i.name IN ('polenta','shiitake mushroom','garlic','rosemary','parmesan')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Cook polenta according to package until creamy.' FROM recipes r WHERE r.title='Polenta with Mushroom Ragù' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Sauté mushrooms with garlic and rosemary; spoon over polenta.' FROM recipes r WHERE r.title='Polenta with Mushroom Ragù' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 16) Middle Eastern Labneh & Pita (vegetarian)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Middle Eastern Labneh & Pita',
  'Thick strained yogurt (labneh) served with olive oil, zaatar and warm pita.',
  'Serve labneh drizzled with olive oil and zaatar alongside warm pita and vegetables.',
  '', 10, 0, 4, true, false, false, false, true, true,
  'yogurt, olive oil, zaatar, pita, cucumber, tomato', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Middle Eastern Labneh & Pita');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,200,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Middle Eastern Labneh & Pita' AND i.name IN ('yogurt','olive oil','pita','cucumber','tomato','zaatar')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Strain yogurt to make labneh or use thick yogurt.' FROM recipes r WHERE r.title='Middle Eastern Labneh & Pita' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Serve with warm pita, olive oil and zaatar.' FROM recipes r WHERE r.title='Middle Eastern Labneh & Pita' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 17) Cardamom & Date Overnight Oats (vegetarian, dairy_free optional)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Cardamom & Date Overnight Oats',
  'Soaked oats with cardamom, dates and almond milk; great for breakfast.',
  'Mix oats with almond milk, chopped dates and cardamom; refrigerate overnight.',
  '', 10, 0, 2, true, false, false, true, true, true,
  'oats, almond milk, dates, cardamom, maple syrup', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Cardamom & Date Overnight Oats');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,80,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Cardamom & Date Overnight Oats' AND i.name IN ('oats','almond milk','dates','cardamom','maple syrup')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Combine oats, almond milk, chopped dates and cardamom in jar.' FROM recipes r WHERE r.title='Cardamom & Date Overnight Oats' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Refrigerate overnight and serve chilled.' FROM recipes r WHERE r.title='Cardamom & Date Overnight Oats' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 18) Spicy Pumpkin & Chickpea Stew (vegan)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Spicy Pumpkin & Chickpea Stew',
  'Comforting stew with pumpkin, chickpeas and warming spices.',
  'Sauté spices; add pumpkin, chickpeas and stock; simmer until soft.', '', 12, 25, 4, true, true, true, true, true, true,
  'pumpkin,chickpeas,turmeric,cumin,cardamom,coconut milk', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Spicy Pumpkin & Chickpea Stew');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,300,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Spicy Pumpkin & Chickpea Stew' AND i.name IN ('pumpkin','chickpeas','turmeric','cumin','cardamom','coconut milk')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Sauté spices, add pumpkin and chickpeas and simmer until tender.' FROM recipes r WHERE r.title='Spicy Pumpkin & Chickpea Stew' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Stir in coconut milk and finish with fresh herbs.' FROM recipes r WHERE r.title='Spicy Pumpkin & Chickpea Stew' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 19) Avocado & Sunflower Seed Toast (vegan)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Avocado & Sunflower Seed Toast',
  'Smashed avocado on toast topped with sunflower seeds and lemon.',
  'Toast bread, smash avocado with salt and lemon; top with seeds and pepper.', '', 5, 0, 1, true, true, false, true, true, true,
  'avocado, sunflower seeds, lemon, bread, pepper', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Avocado & Sunflower Seed Toast');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,1,(SELECT id FROM units WHERE key='piece' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Avocado & Sunflower Seed Toast' AND i.name IN ('avocado','sunflower seeds','lemon','bread','pepper')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Toast bread and mash avocado with lemon and salt.' FROM recipes r WHERE r.title='Avocado & Sunflower Seed Toast' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Top with sunflower seeds and serve.' FROM recipes r WHERE r.title='Avocado & Sunflower Seed Toast' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- 20) Chili Garlic Polenta Fries with Romesco (vegetarian)
INSERT INTO recipes (title,summary,instructions,image_url,prep_minutes,cook_minutes,servings,
  vegetarian,vegan,gluten_free,dairy_free,halal,kosher,ingredients_text,created_at)
SELECT 'Chili Garlic Polenta Fries with Romesco',
  'Baked polenta fries with a smoky romesco dipping sauce.',
  'Cook polenta, cool and cut into sticks; bake until crispy and serve with romesco.',
  '', 30, 25, 4, true, false, true, false, true, true,
  'polenta, chili, garlic, roasted red pepper, tomato, almonds', now()
WHERE NOT EXISTS (SELECT 1 FROM recipes WHERE title='Chili Garlic Polenta Fries with Romesco');

INSERT INTO recipe_ingredients (recipe_id,ingredient_id,quantity,unit_id,note)
SELECT r.id,i.id,250,(SELECT id FROM units WHERE key='gram' LIMIT 1),NULL
FROM recipes r, ingredients i
WHERE r.title='Chili Garlic Polenta Fries with Romesco' AND i.name IN ('polenta','red pepper','tomato','almonds','garlic','chili')
  AND NOT EXISTS(SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id=r.id AND ri.ingredient_id=i.id);

INSERT INTO recipe_steps (recipe_id,step_index,step_text)
SELECT r.id,1,'Cook polenta with stock and chill until firm.' FROM recipes r WHERE r.title='Chili Garlic Polenta Fries with Romesco' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=1)
UNION ALL
SELECT r.id,2,'Cut into sticks, bake until crisp and serve with romesco.' FROM recipes r WHERE r.title='Chili Garlic Polenta Fries with Romesco' AND NOT EXISTS(SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id=r.id AND rs.step_index=2);

-- End of file
