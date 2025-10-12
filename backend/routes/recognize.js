// backend/routes/recognize.js
const express = require('express');
const axios = require('axios');
const router = express.Router();

const CLARIFAI_KEY = process.env.CLARIFAI_API_KEY;
const CLARIFAI_USER_ID = process.env.CLARIFAI_USER_ID;
const CLARIFAI_APP_ID = process.env.CLARIFAI_APP_ID;
const MODEL_ID = process.env.CLARIFAI_MODEL_ID || 'food-item-recognition';
const MODEL_VERSION_ID = process.env.CLARIFAI_MODEL_VERSION_ID || '1d5fd481e0cf4826aa72ec3ff049e044';

if (!CLARIFAI_KEY) console.warn('⚠️ CLARIFAI_API_KEY missing in .env');
if (!CLARIFAI_USER_ID) console.warn('⚠️ CLARIFAI_USER_ID missing in .env');
if (!CLARIFAI_APP_ID) console.warn('⚠️ CLARIFAI_APP_ID missing in .env');

router.post('/', async (req, res) => {
  const { image_url, image_base64 } = req.body;
  if (!image_url && !image_base64) {
    return res.status(400).json({ error: 'image_url or image_base64 required' });
  }

  // require creds
  if (!CLARIFAI_KEY || !CLARIFAI_USER_ID || !CLARIFAI_APP_ID) {
    return res.status(400).json({
      error: 'Clarifai credentials missing',
      message: 'Set CLARIFAI_API_KEY, CLARIFAI_USER_ID, CLARIFAI_APP_ID in .env'
    });
  }

  try {
    // Build request body exactly like the working sample
    const body = {
      user_app_id: {
        user_id: CLARIFAI_USER_ID,
        app_id: CLARIFAI_APP_ID
      },
      model_id: MODEL_ID,
      version_id: MODEL_VERSION_ID,
      inputs: [
        {
          data: image_url
            ? { image: { url: image_url, allow_duplicate_url: true } }
            : { image: { base64: image_base64 } }
        }
      ]
    };

    const url = `https://api.clarifai.com/v2/models/${MODEL_ID}/versions/${MODEL_VERSION_ID}/outputs`;

    const resp = await axios.post(url, body, {
      headers: {
        Authorization: `Key ${CLARIFAI_KEY}`,
        'Content-Type': 'application/json'
      },
      timeout: 20000
    });

    // Parse concepts safely
    const outputs = resp.data?.outputs ?? [];
    const concepts = outputs[0]?.data?.concepts ?? [];

    const predictions = concepts.map(c => ({
      id: c.id,
      name: c.name,
      value: typeof c.value === 'number' ? c.value : Number(c.value) || 0
    }));

    // Return top-? (all for now) + raw for debugging
    res.json({
      success: true,
      model: MODEL_ID,
      model_version: MODEL_VERSION_ID,
      count: predictions.length,
      predictions,
      raw: resp.data
    });
  } catch (err) {
    console.error('Clarifai API error:', err.response?.data || err.message);
    const details = err.response?.data ?? err.message;
    res.status(500).json({ error: 'Recognition failed', details });
  }
});

module.exports = router;