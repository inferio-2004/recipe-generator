const express = require('express');
const db = require('../db');
const requireAuth = require('../middleware/auth');
const router = express.Router();

// Create recipe (protected)
router.post('/', requireAuth, async (req, res) => {
  try {
    const { title, summary, instructions, prep_minutes, cook_minutes, servings, vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, image_url } = req.body;

    const q = `INSERT INTO recipes
      (title, summary, instructions, prep_minutes, cook_minutes, servings,
       vegetarian, vegan, gluten_free, dairy_free, halal, kosher, ingredients_text, image_url)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
     RETURNING *;`;

    const { rows } = await db.query(q, [title, summary, instructions, prep_minutes, cook_minutes, servings || 1, vegetarian || false, vegan || false, gluten_free || false, dairy_free || false, halal || false, kosher || false, ingredients_text || '', image_url || null]);
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

router.get('/getIngredients',async(req,res)=>{
  try{
    const { rows } = await db.query("SELECT DISTINCT UNNEST(STRING_TO_ARRAY(ingredients_text, ',')) AS ingredient FROM recipes");
    res.status(200).json(rows);
  }catch(err){
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Read (list / search)
router.get('/', async (req, res) => {
  const { q, limit = 50, offset = 0 } = req.query;
  try {
    if (q) {
      const { rows } = await db.query("SELECT * FROM recipes WHERE title ILIKE $1 OR ingredients_text ILIKE $1 LIMIT $2 OFFSET $3", [`%${q}%`, limit, offset]);
      return res.json(rows);
    }
    const { rows } = await db.query("SELECT * FROM recipes LIMIT $1 OFFSET $2", [limit, offset]);
    res.json(rows);
  } catch (err) { console.error(err); res.status(500).json({ error: 'Server error' }); }
});

// Read single
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  const { rows } = await db.query("SELECT * FROM recipes WHERE id=$1", [id]);
  if (!rows.length) return res.status(404).json({ error: 'Not found' });
  res.json(rows[0]);
});

// Update (protected)
router.put('/:id', requireAuth, async (req, res) => {
  const { id } = req.params;
  const { title, summary } = req.body;
  const { rows } = await db.query("UPDATE recipes SET title=$1, summary=$2 WHERE id=$3 RETURNING *", [title, summary, id]);
  res.json(rows[0]);
});

// Delete (protected)
router.delete('/:id', requireAuth, async (req, res) => {
  const { id } = req.params;
  await db.query("DELETE FROM recipes WHERE id=$1", [id]);
  res.json({ success: true });
});

module.exports = router;
