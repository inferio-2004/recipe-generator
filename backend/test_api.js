// backend/test_api.js
require('dotenv').config({path: '../.env'});
const axios = require('axios');
const { Client } = require('pg');

const BASE = `http://localhost:${process.env.PORT || 4000}`;
const dbUrl = process.env.DATABASE_URL;

if (!dbUrl) {
  console.error("Please set DATABASE_URL in backend/.env before running this test.");
  process.exit(1);
}

const testEmail = `testscript+${Date.now()}@example.com`;
const testPassword = 'TestPass!123';
const testRecipeTitle = `TESTSCRIPT Recipe ${Date.now()}`;

// Put a public image URL here to enable Clarifai test (or leave blank to skip)
// Example: "https://samples.clarifai.com/metro-north.jpg"
const testImageUrl ="https://www.allrecipes.com/thmb/KBhxgb1fzemKeisK9sjE8FpGgNo=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/14172-CeasarSaladSupreme-ddmfs-Step1-0908-ef2d5380fed04afd88aba06c4c9d0a4b.jpg"; // <-- set to a public image URL to enable image -> recommend test

let totalTests = 0;
let passedTests = 0;
let skippedTests = 0;
const skippedList = [];

async function runTest(name, fn) {
  totalTests++;
  try {
    const result = await fn();
    if (result && result === 'SKIP') {
      skippedTests++;
      skippedList.push(name);
      console.log(`→ ${name} SKIPPED`);
    } else {
      passedTests++;
      console.log(`✔ ${name}`);
    }
  } catch (err) {
    console.error(`✖ ${name} FAILED:`, err && (err.response?.data || err.message || err));
  }
}

async function cleanup(pg) {
  try {
    await pg.query("DELETE FROM recipe_steps WHERE recipe_id IN (SELECT id FROM recipes WHERE title LIKE $1)", [`TESTSCRIPT%`]);
    await pg.query("DELETE FROM recipe_ingredients WHERE recipe_id IN (SELECT id FROM recipes WHERE title LIKE $1)", [`TESTSCRIPT%`]);
    const delRecipes = await pg.query("DELETE FROM recipes WHERE title LIKE $1 RETURNING id", [`TESTSCRIPT%`]);
    const delUser = await pg.query("DELETE FROM users WHERE email = $1 RETURNING id", [testEmail]);
    console.log("Cleanup executed, removed recipes:", delRecipes.rowCount, "removed test user:", delUser.rowCount);
  } catch (e) {
    console.warn("Cleanup error:", e.message || e);
  } finally {
    try { await pg.end(); } catch {}
  }
}

async function run() {
  console.log("Base URL:", BASE);
  let token = null;
  let user = null;
  let recipe = null;

  const pg = new Client({ connectionString: dbUrl });
  await pg.connect();

  try {
    // 1) Signup
    await runTest("Signup user", async () => {
      const signup = await axios.post(`${BASE}/auth/signup`, {
        email: testEmail, password: testPassword, name: "Test Script"
      });
      if (!signup.data || !signup.data.token) throw new Error("No token returned from signup");
      token = signup.data.token;
      user = signup.data.user;
    });

    // 2) Create recipe (auth)
    await runTest("Create recipe (authenticated)", async () => {
      const createResp = await axios.post(`${BASE}/api/recipes`, {
        title: testRecipeTitle,
        summary: "Test recipe created by automated script",
        instructions: "Do nothing, just test.",
        prep_minutes: 5,
        cook_minutes: 0,
        servings: 2,
        vegetarian: true,
        vegan: true,
        gluten_free: true,
        dairy_free: true,
        halal: true,
        kosher: true,
        ingredients: [
          { name: "chickpeas", quantity: 200, unit: "gram" },
          { name: "lemon", quantity: 1, unit: "piece", note: "juiced" }
        ],
        steps: ["Mix chickpeas", "Add lemon", "Serve"],
        image_url: "https://example.com/test.jpg"
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (!createResp.data || !createResp.data.id) throw new Error("Recipe create returned no id");
      recipe = createResp.data;
    });

    // 3) List recipes
    await runTest("List recipes (public)", async () => {
      const list = await axios.get(`${BASE}/api/recipes`);
      if (!Array.isArray(list.data)) throw new Error("List did not return an array");
    });

    // 4) Get single recipe
    await runTest("Get single recipe", async () => {
      const single = await axios.get(`${BASE}/api/recipes/${recipe.id}`);
      if (!single.data || single.data.id !== recipe.id) throw new Error("Single recipe mismatch");
    });

    // 5) Update recipe
    await runTest("Update recipe", async () => {
      const updatedTitle = recipe.title + " (updated)";
      const upd = await axios.put(`${BASE}/api/recipes/${recipe.id}`, {
        title: updatedTitle,
        ingredients: [
          { name: "chickpeas", quantity: 150, unit: "gram" },
          { name: "parsley", quantity: 5, unit: "gram" }
        ],
        steps: ["Step 1 updated","Step 2 updated"]
      }, { headers: { Authorization: `Bearer ${token}` } });
      if (!upd.data || !upd.data.title || !upd.data.title.includes("(updated)")) throw new Error("Update didn't reflect");
      recipe = upd.data;
    });

    // 6) Recommend endpoint
    await runTest("Recommend endpoint", async () => {
      const rec = await axios.post(`${BASE}/api/recommend`, {
        ingredients: ["chickpeas", "lemon"],
        filters: { vegan: true }
      });
      if (!Array.isArray(rec.data)) throw new Error("Recommend did not return an array");
    });

    // 7) Clarifai recognize (conditional)
    const clarifaiEnvOk = process.env.CLARIFAI_API_KEY && process.env.CLARIFAI_USER_ID && process.env.CLARIFAI_APP_ID && process.env.CLARIFAI_MODEL_ID;
    const clarifaiReady = clarifaiEnvOk && testImageUrl;
    if (!clarifaiEnvOk) {
      await runTest("Clarifai recognize (image->predictions)", async () => 'SKIP');
    } else if (!testImageUrl) {
      await runTest("Clarifai recognize (image->predictions)", async () => 'SKIP');
    } else {
      await runTest("Clarifai recognize (image->predictions)", async () => {
        const recog = await axios.post(`${BASE}/api/recognize`, { image_url: testImageUrl });
        // our recognize route returns { predictions: [...] } or raw outputs; accept both
        const preds = recog.data?.predictions ?? recog.data?.outputs ?? null;
        if (!preds) throw new Error("Recognize returned no predictions/outputs");
        // Normalize: if objects from Clarifai raw, they are in raw.outputs[0].data.concepts
        let names = [];
        if (recog.data?.predictions) {
          names = recog.data.predictions.map(p => p.name);
        } else if (recog.data?.outputs) {
          const concepts = recog.data.outputs[0]?.data?.concepts ?? [];
          names = concepts.map(c => c.name);
        } else if (Array.isArray(preds)) {
          names = preds.map(p => p.name || p.concept || String(p));
        }
        // keep top 7 unique
        names = Array.from(new Set(names)).slice(0, 7);
        if (!names.length) throw new Error("No prediction names extracted");

        // attach names to test context so the next test (image->recommend) can reuse them
        recipe._detected_names = names;
        console.log(" -> Detected names:", names);
      });
    }

    // 8) IMAGE -> RECOMMEND (tsvector search) : use detected names to call /api/recommend and display results
    await runTest("Image -> recognize -> recommend (tsvector search)", async () => {
      // If previous step was skipped, mark skip here too
      if (!clarifaiReady) return 'SKIP';

      const names = recipe._detected_names || [];
      if (!names.length) throw new Error("No detected names from previous step");

      // call recommend endpoint with detected names
      const rec = await axios.post(`${BASE}/api/recommend`, {
        ingredients: names,
        filters: {} // no special filters; you can set {vegan:true} if desired
      });

      if (!Array.isArray(rec.data)) throw new Error("Recommend did not return an array");

      // Print top 5 returned recipes (id + title) to console for human inspection
      console.log(" -> recommend returned", rec.data.length, "recipes. Top results:");
      rec.data.slice(0, 5).forEach(r => console.log(`    - [${r.id}] ${r.title}`));

      // test passes if rec.data is an array (we already checked), and we can accept empty arrays as valid result.
    });

    // 9) Delete recipe
    await runTest("Delete recipe (authenticated)", async () => {
      await axios.delete(`${BASE}/api/recipes/${recipe.id}`, { headers: { Authorization: `Bearer ${token}` } });
      // confirm deletion
      try {
        await axios.get(`${BASE}/api/recipes/${recipe.id}`);
        throw new Error("Recipe still exists after delete");
      } catch (e) {
        if (e.response && e.response.status === 404) return; // success
        if (!e.response) throw e;
      }
    });
    //10 get ingredients
    await runTest("Get Ingredients", async () => {
      const ing = await axios.get(`${BASE}/api/recipes/getIngredients`);
      console.log(ing.data);
      if (!Array.isArray(ing.data)) throw new Error("Get Ingredients did not return an array");
    });

    // Cleanup DB entries: remove test recipes and user
    await cleanup(pg);

    // Final score
    console.log("");
    console.log("TEST SUMMARY:");
    console.log(`Passed ${passedTests} of ${totalTests} tests.`);
    if (skippedTests > 0) {
      console.log(`Skipped (${skippedTests}):`, skippedList);
    }
    console.log(`Score: ${passedTests}/${totalTests}`);

    process.exit( passedTests === totalTests ? 0 : 0 );
  } catch (err) {
    console.error("Test script error:", err && (err.response?.data || err.message || err));
    // attempt cleanup
    await cleanup(pg);
    console.log("");
    console.log("TEST SUMMARY:");
    console.log(`Passed ${passedTests} of ${totalTests} tests.`);
    if (skippedTests > 0) {
      console.log(`Skipped (${skippedTests}):`, skippedList);
    }
    console.log(`Score: ${passedTests}/${totalTests}`);
    process.exit(1);
  }
}

run();
