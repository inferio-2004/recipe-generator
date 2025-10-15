// frontend/src/components/Home.jsx
import React, { useState, useEffect, useRef } from 'react';
import { recognizeImageBase64, recommend, getUserRecommendations, postRecommendationAction, getIngredients } from '../api';
import RecipeCard from './RecipeCard';
import '../styles/home.css';
import '../styles/ingredientChips.css'; // new CSS (see below)

const MAX_VISIBLE = 10;

export default function Home({ token, user, onLogout }) {
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState(null);

  // ---- ingredient chips/autocomplete state ----
  const [allIngredients, setAllIngredients] = useState([]); // fetched from API once
  const [selectedIngredients, setSelectedIngredients] = useState([]); // chips
  const [inputValue, setInputValue] = useState(''); // current typing text (not the CSV)
  const [suggestions, setSuggestions] = useState([]); // filtered suggestions dropdown
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [fileError, setFileError] = useState(''); // img extnsion error
  // keep ingredientsText for compatibility with your existing code
  const [ingredientsText, setIngredientsText] = useState('');

  const [allResults, setAllResults] = useState([]);
  const [visibleRecipes, setVisibleRecipes] = useState([]);
  const [interactedRecipes, setInteractedRecipes] = useState([]);
  const [recommendedForUser, setRecommendedForUser] = useState([]);
  const [msg, setMsg] = useState('');
  const [loading, setLoading] = useState(false);
  const [filters, setFilters] = useState({
    vegan: false,
    vegetarian: false,
    gluten_free: false,
    dairy_free: false,
    halal: false,
    kosher: false,
  });

  const inputRef = useRef();
  const suggestionsRef = useRef();

  // ------------------ init: fetch master ingredient list once ------------------
  useEffect(() => {
    let mounted = true;
    async function loadIngredients() {
      try {
        const res = await getIngredients(); // expects [{ ingredient:'tomato' }, ...] or ['tomato', ...]
        if (!mounted) return;

        // normalize values (preserve original casing when possible)
        const names = Array.isArray(res)
          ? res.map(r => (typeof r === 'string' ? r : (r.ingredient || r.name || ''))).filter(Boolean)
          : [];

        // dedupe (case-insensitive), preserve first-seen casing
        const seen = new Set();
        const uniq = [];
        for (const n of names) {
          const low = n.toLowerCase();
          if (!seen.has(low)) {
            seen.add(low);
            uniq.push(n);
          }
        }

        setAllIngredients(uniq); // canonical list, nicely cased
      } catch (e) {
        console.warn('getIngredients failed', e);
        setAllIngredients([]);
      }
    }
    loadIngredients();
    return () => { mounted = false; };
  }, []); // run once on mount

  useEffect(() => {
    console.log('allIngredients:', allIngredients.slice(0, 20));
  }, [allIngredients]);

  useEffect(() => {
    console.log('selectedIngredients:', selectedIngredients);
  }, [selectedIngredients]);

  useEffect(() => {
    // if first element is a string, convert
    if (selectedIngredients.length > 0 && typeof selectedIngredients[0] === 'string') {
      setSelectedIngredients(prev => convertStringsToObjects(prev));
    }
  }, []); // run once
  // update ingredientsText whenever selectedIngredients change (keeps existing search code compatible)
  useEffect(() => {
    setIngredientsText(selectedIngredients.map(s => s.name).join(', '));
  }, [selectedIngredients]);

  // preview building (unchanged)
  useEffect(() => {
    if (!file) { setPreview(null); return; }
    const reader = new FileReader();
    reader.onload = () => setPreview(reader.result);
    reader.readAsDataURL(file);
  }, [file]);

  // client-side filtering and limiting
  useEffect(() => {
    applyClientFiltersAndLimit(allResults, filters);
  }, [allResults, filters]);

  // personalized recommendations (run only once on start, as you asked earlier)
  useEffect(() => {
    let mounted = true;
    async function fetchOnce() {
      try {
        if (!token) return;
        const data = await getUserRecommendations(token, 4); // max 4
        if (!mounted) return;
        setRecommendedForUser(Array.isArray(data) ? data : []);
      } catch (e) {
        console.warn('Personal recs fetch failed', e);
        if (mounted) setRecommendedForUser([]);
      }
    }
    fetchOnce();
    return () => { mounted = false; };
  }, []); // runs only once

  function isValidImageFile(f) {
    if (!f) return false;
    const name = (f.name || '').toLowerCase();
    const extOk = /\.(jpe?g|png|webp)$/i.test(name);
    const mimeOk = /^image\/(jpeg|jpg|png|webp)$/.test((f.type || '').toLowerCase());
    return extOk && (mimeOk || /^image\//.test(f.type || '')); 
  }

  function applyClientFiltersAndLimit(list, filtersObj) {
    if (!Array.isArray(list)) {
      setVisibleRecipes([]);
      setMsg('Found 0 recipes');
      return;
    }

    const anyChecked = Object.values(filtersObj).some(Boolean);

    let filtered = list;
    if (anyChecked) {
      filtered = list.filter((recipe) =>
        Object.entries(filtersObj).every(([k, v]) => !v || recipe[k])
      );
    }

    const totalCount = filtered.length;
    setVisibleRecipes(filtered.slice(0, MAX_VISIBLE));
    setMsg(`Found ${totalCount} recipes (showing top ${Math.min(totalCount, MAX_VISIBLE)})`);
  }

  function onFilterChange(e) {
    const { name, checked } = e.target;
    setFilters((prev) => ({ ...prev, [name]: checked }));
  }

  function onFileSelected(e) {
    const f = e.target.files?.[0];
    if (!f) {
      setFile(null);
      setPreview(null);
      setFileError('');
      return;
    }

    if (!isValidImageFile(f)) {
      // invalid file selected
      setFile(null);
      setPreview(null);
      setFileError('This image extn is not supported. Try an image with these extns: jpeg, jpg, png, webp');
      // reset the input so re-selecting the same bad file fires change again if needed
      try { e.target.value = ''; } catch (_) {}
      return;
    }

    // valid file
    setFileError('');
    setFile(f);

  }

  // ---------- Autocomplete / Chips helpers ----------
  function openSuggestions() {
    setShowSuggestions(true);
  }
  function closeSuggestions() {
    setShowSuggestions(false);
  }

  function filterSuggestions(val) {
    const q = (val || '').toLowerCase().trim();
    const selectedLower = new Set(selectedIngredients.map(s => s.toString().toLowerCase()));

    if (!q) {
      // show a few suggestions (exclude already selected)
      setSuggestions(allIngredients.filter(n => !selectedLower.has(n.toLowerCase())).slice(0, 8));
      setShowSuggestions(true);
      return;
    }

    // startsWith behavior: narrow as you type
    const filtered = allIngredients
      .filter(n => {
        const low = n.toLowerCase();
        return !selectedLower.has(low) && low.startsWith(q);
      })
      .slice(0, 12);

    setSuggestions(filtered);
    setShowSuggestions(true);
  }

  // util to create a short unique id (good enough for UI)
  function makeId() {
    return Date.now().toString(36) + '-' + Math.random().toString(36).slice(2,8);
  }

  function getCanonical(name) {
    if (!name) return name;
    const low = name.toLowerCase();
    const found = allIngredients.find(a => a.toLowerCase() === low);
    return found || name;
  }

  function convertStringsToObjects(arr) {
    if (!Array.isArray(arr)) return [];
    return arr
      .map(s => (typeof s === 'string' ? s.trim() : ''))
      .filter(Boolean)
      .map(s => ({ id: makeId(), name: getCanonical(s) }));
  }

  // Add a chip (stores as {id, name})
  function addChip(name) {
    if (!name) return;
    const trimmed = String(name).trim();
    if (!trimmed) return;
    const canonical = getCanonical(trimmed);

    setSelectedIngredients(prev => {
      // prevent duplicate by name (case-insensitive)
      if (prev.some(p => p.name.toLowerCase() === canonical.toLowerCase())) return prev;
      const next = [...prev, { id: makeId(), name: canonical }];
      console.debug('[addChip] ->', next.map(x => x.name));
      return next;
    });

    setInputValue('');
    setShowSuggestions(false);
  }

  // remove by id (preferred)
  function removeChipById(id) {
    setSelectedIngredients(prev => prev.filter(p => p.id !== id));
  }

  // optional: remove by index wrapper (keeps API)
  function removeChipAt(index) {
    setSelectedIngredients(prev => {
      if (index < 0 || index >= prev.length) return prev;
      const id = prev[index].id;
      return prev.filter(p => p.id !== id);
    });
  }
  // handle typing in the ingredient input
  function onIngredientInputChange(e) {
    const v = e.target.value;
    setInputValue(v);
    filterSuggestions(v);
    setShowSuggestions(true);
  }

  // when user presses Enter or comma: add chip
  function onIngredientKeyDown(e) {
    if (e.key === 'Enter' || e.key === ',' ) {
      e.preventDefault();
      const val = inputValue.trim();
      if (val) addChip(val);
    } else if (e.key === 'Backspace' && inputValue === '' && selectedIngredients.length > 0) {
      // quick remove last chip on backspace if input empty
      setSelectedIngredients(prev => prev.slice(0, -1));
    }
  }

  // clicking outside suggestions closes dropdown
  useEffect(() => {
    function onDocClick(e) {
      if (suggestionsRef.current && !suggestionsRef.current.contains(e.target)) {
        closeSuggestions();
      }
    }
    document.addEventListener('mousedown', onDocClick);
    return () => document.removeEventListener('mousedown', onDocClick);
  }, []);

  // --------------- recognition / search (unchanged except using ingredientsText) ----------------
  async function handleUpload() {
    if (!file) return;
    if (fileError) { setMsg('Please choose a supported image before uploading.'); return; }
    setLoading(true);
    setMsg('Recognizing...');
    try {
      const dataUri = await new Promise((res, rej) => {
        const r = new FileReader();
        r.onload = () => res(r.result.split(',')[1]);
        r.onerror = rej;
        r.readAsDataURL(file);
      });

      const result = await recognizeImageBase64(dataUri);
      const preds = result?.predictions ?? result?.outputs?.[0]?.data?.concepts ?? [];
      const rawNames = (preds || [])
        .map(p => (p && (p.name || p.concept || p.tag) ? String(p.name || p.concept || p.tag) : ''))
        .map(s => s.replace(/\s+/g, ' ').trim())
        .map(s => s.replace(/,+$/,'').trim())
        .filter(Boolean);

      if (rawNames.length === 0) {
        setInputValue('');
        setMsg('No ingredients detected — please edit or add manually.');
        return;
      }

      // Add only top N predictions (change maxPreds to adjust)
      const maxPreds = 8;
      const top = rawNames.slice(0, maxPreds);

      setSelectedIngredients(prev => {
        const lowerPrev = new Set(prev.map(p => p.name.toLowerCase()));
        const additions = [];
        for (const nm of top) {
          const canonical = getCanonical(nm);
          if (!canonical) continue;
          if (!lowerPrev.has(canonical.toLowerCase())) {
            lowerPrev.add(canonical.toLowerCase());
            additions.push({ id: makeId(), name: canonical });
          }
        }
        const next = [...prev, ...additions];
        // final cleanup
        return next.filter(it => it && it.name && String(it.name).trim().length > 0);
      });

      setInputValue('');
      setShowSuggestions(false);
      setMsg('Predicted ingredients added — edit if needed.');
    } catch (err) {
      console.error('Recognition error:', err);
      setMsg('Recognition failed');
    } finally {
      setLoading(false);
    }
  }

  async function searchRecipes(e) {
    e?.preventDefault();
    setMsg('Searching recipes...');
    setLoading(true);
    try {
      // make the final array exactly like before: use ingredientsText splitting
      // but we must include any typed text in inputValue as well
      const typedExtras = inputValue.split(',').map(s => s.trim()).filter(Boolean);
      const combined = [...selectedIngredients.map(s => s.name), ...typedExtras];
      setIngredientsText(combined.join(', ')); // keeps compatibility

      const arr = combined.map((s) => s.trim()).filter(Boolean);
      const results = await recommend({ ingredients: arr, limit: 50 }, token);
      const list = Array.isArray(results) ? results : results?.rows || [];
      setAllResults(list);
      setInteractedRecipes([]);
      if (list.length > MAX_VISIBLE)
        setMsg(`Found ${list.length} recipes (showing top ${MAX_VISIBLE})`);
      else setMsg(`Found ${list.length} recipes`);
    } catch (err) {
      console.error(err);
      setMsg('Search failed');
    } finally {
      setLoading(false);
    }
  }

  // unchanged feedback handlers (assuming you already patched these earlier)
  async function handleLike(recipeId) {
    const found = allResults.find((r) => r.id === recipeId) || recommendedForUser.find(r => r.id === recipeId);
    if (!found) return;
    setInteractedRecipes((prev) => [
      { recipe: found, liked: true, showInstr: false },
      ...prev,
    ]);
    setAllResults((prev) => prev.filter((r) => r.id !== recipeId));
    // persist & refresh
    try {
      if (token) {
        await postRecommendationAction(token, { recipe_id: recipeId, action: 'like' });
        const data = await getUserRecommendations(token, 4);
        setRecommendedForUser(Array.isArray(data) ? data : []);
      }
    } catch (err) { console.warn('Failed save like', err); }
  }

  async function handleDislike(recipeId) {
    setAllResults((prev) => prev.filter((r) => r.id !== recipeId));
    try {
      if (token) await postRecommendationAction(token, { recipe_id: recipeId, action: 'dislike' });
    } catch (err) { console.warn('Failed save dislike', err); }
  }

  // Interacted list helpers (unchanged)
  const likedInteracted = interactedRecipes.filter((it) => it.liked);

  function toggleInstructions(index) {
    setInteractedRecipes((prev) =>
      prev.map((it, i) =>
        i === index ? { ...it, showInstr: !it.showInstr } : it
      )
    );
  }

  // -------------------------------------------------------------------------
  // JSX render (note: ingredient input/chips area is replaced here)
  // -------------------------------------------------------------------------
  return (
    <div className="home-wrap">
      <header className="topbar">
        <h1>Smart Recipe Generator</h1>
        <div>
          <span className="muted">Hi, {user?.name || user?.email} </span>
          <button className="btn" onClick={onLogout}>
            Log out
          </button>
        </div>
      </header>

      <main className="container">
        <section className="card upload-card">
          <h3>Upload ingredients image</h3>

          <div className="file-chooser">
            <input
              ref={inputRef}
              type="file"
              accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"
              onChange={onFileSelected}
              style={{ display: 'none' }}
            />
            <button className="btn" onClick={() => inputRef.current?.click()}>
              Choose image
            </button>
            <div className="file-name">{file ? file.name : 'No file chosen'}</div>
          </div>

          {preview && (
            <img src={preview} alt="preview" className="preview fixed-preview" />
          )}

          <div style={{ marginTop: 12 }}>
            <button
              className="btn primary"
              onClick={handleUpload}
              disabled={!file || loading}
            >
              {loading ? 'Recognizing...' : 'Upload & Recognize'}
            </button>
          </div>
          {fileError && (
           <div className="file-error" role="alert" aria-live="polite" style={{ marginTop: 8 }}>
             {fileError}
           </div>
          )}
          <form onSubmit={searchRecipes} className="ingredients-form" style={{ marginTop: 12 }}>
            <label className="field full">
              <span>Is this your final list? (add from suggestions or type and press Enter)</span>

              {/* ---------- chips + input ---------- */}
              <div className="chip-input-wrapper">
                <div className="chips">
                  {selectedIngredients.map((c, idx) => (
                    <div className="chip" key={c.id}>
                      <span className="chip-label">{c.name}</span>
                      <button
                        type="button"
                        className="chip-remove"
                        onMouseDown={(e) => { e.preventDefault(); e.stopPropagation(); removeChipById(c.id); }}
                        aria-label={`Remove ${c.name}`}
                      >
                        ×
                      </button>
                    </div>
                  ))}
                  <input
                    className="chip-input no-outline"
                    placeholder="Type ingredient and select (e.g. tomato)"
                    value={inputValue}
                    onChange={onIngredientInputChange}
                    onKeyDown={onIngredientKeyDown}
                    onFocus={() => filterSuggestions(inputValue)}
                    aria-autocomplete="list"
                  />
                </div>

                {/* suggestions dropdown */}
                {showSuggestions && suggestions.length > 0 && (
                  <div className="suggestions" ref={suggestionsRef}>
                    {suggestions.map((s) => (
                      <div
                        key={s}
                        className="suggestion-item"
                        onMouseDown={(e) => {
                          // prevent document-level mousedown from running before we add the chip
                          e.preventDefault();
                          e.stopPropagation();
                          addChip(s);
                        }}
                      >
                        {s}
                      </div>
                    ))}
                  </div>
                )}
              </div>

            </label>

            <div className="filters-row" style={{ marginTop: 8 }}>
              {Object.keys(filters).map((f) => (
                <label key={f}>
                  <input
                    type="checkbox"
                    name={f}
                    checked={filters[f]}
                    onChange={onFilterChange}
                  />{' '}
                  {f.replace('_', ' ')}
                </label>
              ))}
            </div>

            <div style={{ display: 'flex', gap: 10, alignItems: 'center', marginTop: 10 }}>
              <button className="btn primary" type="submit">
                Search Recipes
              </button>
              <div className="muted">{msg}</div>
            </div>
          </form>
        </section>

        <section className="card results" style={{ minHeight: 140 }}>
          <h3>Matched recipes</h3>
          {visibleRecipes.length === 0 && (
            <div className="muted">No recipes — try uploading an image or edit the list</div>
          )}
          <div className="cards">
            {visibleRecipes.map((r, idx) => (
              <RecipeCard
                key={r.id || idx}
                recipe={r}
                onLike={() => handleLike(r.id)}
                onDislike={() => handleDislike(r.id)}
              />
            ))}
          </div>

          {/* Liked (interacted) recipes */}
          <div className="interacted-section" style={{ marginTop: 16 }}>
            <h4>Liked Recipes</h4>
            {likedInteracted.length === 0 && (
              <div className="muted small">
                No liked recipes yet — click ❤ to like a recipe.
              </div>
            )}
            <div className="interacted-list">
              {likedInteracted.map((it, i) => {
                const instructions = (it.recipe.instructions || '')
                  .split(';')
                  .map((s) => s.trim())
                  .filter(Boolean);
                return (
                  <div
                    key={i}
                    className="recipe-card-static interacted-item"
                    onClick={() => toggleInstructions(i)}
                  >
                    <img
                      src={
                        it.recipe.image_url ||
                        'https://via.placeholder.com/300x180?text=No+Image'
                      }
                      alt={it.recipe.title}
                      className="fixed-image"
                    />
                    <div style={{ paddingLeft: 12, flex: 1 }}>
                      <div
                        style={{
                          display: 'flex',
                          justifyContent: 'space-between',
                          alignItems: 'baseline',
                        }}
                      >
                        <h4 style={{ margin: 0 }}>{it.recipe.title}</h4>
                        <div className="muted small">Liked</div>
                      </div>
                      {it.showInstr ? (
                        <ol className="instructions">
                          {instructions.map((step, j) => (
                            <li key={j}>{step}</li>
                          ))}
                        </ol>
                      ) : (
                        <p className="summary" style={{ marginTop: 6 }}>
                          {it.recipe.summary}
                        </p>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Personalized recommendations (use RecipeCard so click expands) */}
          {recommendedForUser.length > 0 && (
            <div className="card recommended" style={{ marginTop: 16 }}>
              <h4>Recommended for you</h4>
              <div className="cards">
                {recommendedForUser.map((r, idx) => (
                  <RecipeCard
                    key={r.id || idx}
                    recipe={r}
                    onLike={() => handleLike(r.id)}
                    onDislike={() => handleDislike(r.id)}
                  />
                ))}
              </div>
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
