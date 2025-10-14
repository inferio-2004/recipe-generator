"""
compute_embeddings_and_clusters.py

- Computes SBERT embeddings for recipes, writes to recipes.embedding (pgvector)
- Runs KMeans clustering (with K adjusted to dataset size), writes recipes.cluster_id
- Writes centroids into recipe_clusters table

Notes:
- Ensure your project .env contains DATABASE_URL (script will auto-load it).
- Installs / requirements: sentence-transformers, psycopg2-binary, scikit-learn, numpy, tqdm, python-dotenv
"""
from dotenv import load_dotenv
import pathlib, os, sys, time
import psycopg2
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.cluster import KMeans
from tqdm import tqdm

# load .env from project root (two levels up from this file)
root_dir = pathlib.Path(__file__).resolve().parents[2]
load_dotenv(dotenv_path="C:\\Users\\Aniruth\\Desktop\\receipe_generator\\backend\\.env")

DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL not found in env/.env. Exiting.")
    sys.exit(1)

MODEL_NAME = os.environ.get("EMBEDDING_MODEL", "all-MiniLM-L6-v2")
REQUESTED_K = int(os.environ.get("K_CLUSTERS", "100"))
BATCH = int(os.environ.get("EMB_BATCH", "64"))

def fetch_recipes(conn):
    cur = conn.cursor()
    cur.execute("SELECT id, title, COALESCE(ingredients_text,'') AS ingredients, COALESCE(summary,'') FROM recipes;")
    rows = cur.fetchall()
    return rows

def upsert_embedding(conn, rid, vec):
    # vec: numpy array
    literal = '[' + ','.join(f"{float(x):.8f}" for x in vec.tolist()) + ']'
    cur = conn.cursor()
    cur.execute("UPDATE recipes SET embedding = %s WHERE id = %s", (literal, rid))

def upsert_cluster_ids(conn, ids, labels):
    cur = conn.cursor()
    for rid, lab in zip(ids, labels):
        cur.execute("UPDATE recipes SET cluster_id = %s WHERE id = %s", (int(lab), rid))

def upsert_centroids(conn, centroids):
    cur = conn.cursor()
    cur.execute("DELETE FROM recipe_clusters;")
    for i, c in enumerate(centroids):
        literal = '[' + ','.join(f"{float(x):.8f}" for x in c.tolist()) + ']'
        cur.execute("INSERT INTO recipe_clusters (cluster_id, centroid) VALUES (%s,%s)", (int(i), literal))

def choose_k(requested_k, n_samples):
    # Heuristic: don't exceed n_samples-1, and pick sqrt-based if requested_k too big.
    if n_samples <= 2:
        return max(1, n_samples)
    # Upper bound: n_samples - 1 (must be < n_samples)
    ub = max(2, n_samples - 1)
    # sensible default: sqrt(n_samples) rounded
    sqrt_k = max(2, int(round(np.sqrt(n_samples))))
    # choose min of requested_k, ub and at least sqrt_k
    k = min(requested_k, ub)
    # if requested_k is unreasonably large, fallback to sqrt
    if k > sqrt_k and requested_k > ub:
        k = sqrt_k
    # final clamp
    k = max(1, min(k, ub))
    return k

def main():
    print(f"Connecting to DB: {DATABASE_URL.split('@')[-1] if DATABASE_URL else 'UNKNOWN'}")
    conn = psycopg2.connect(DATABASE_URL)
    rows = fetch_recipes(conn)
    if not rows:
        print("No recipes found in DB. Exiting.")
        return
    ids = []
    docs = []
    for r in rows:
        rid = int(r[0])
        title = r[1] or ""
        ings = r[2] or ""
        summary = r[3] or ""
        doc = f"{title} | {ings} | {summary}"
        ids.append(rid)
        docs.append(doc)

    n_samples = len(docs)
    print(f"Found {n_samples} recipes; requested K={REQUESTED_K}")

    model = SentenceTransformer(MODEL_NAME)
    print("Encoding embeddings with model:", MODEL_NAME)
    embs_list = []
    for i in range(0, n_samples, BATCH):
        batch_docs = docs[i:i+BATCH]
        emb = model.encode(batch_docs, convert_to_numpy=True, normalize_embeddings=True)
        embs_list.append(emb)
    embs = np.vstack(embs_list).astype('float32')
    dim = embs.shape[1]
    print(f"Computed embeddings: shape = {embs.shape}")

    # write embeddings back to DB
    print("Writing embeddings to DB...")
    for rid, vec in tqdm(zip(ids, embs), total=len(ids)):
        upsert_embedding(conn, rid, vec)
    conn.commit()
    print("Embeddings written.")

    # choose K sensibly
    K = choose_k(REQUESTED_K, n_samples)
    print(f"Clustering: chosen K = {K} (requested {REQUESTED_K}, n_samples {n_samples})")
    if K < 1:
        print("K < 1 after adjustment, skipping clustering.")
        conn.close()
        return

    # If K == 1, we can just assign cluster_id 0 to all
    if K == 1:
        print("K == 1: assigning cluster_id = 0 to all recipes")
        cur = conn.cursor()
        for rid in ids:
            cur.execute("UPDATE recipes SET cluster_id = %s WHERE id = %s", (0, rid))
        conn.commit()
        # also write centroid as mean
        centroid = np.mean(embs, axis=0)
        upsert_centroids(conn, np.array([centroid]))
        conn.commit()
        conn.close()
        print("Cluster assignment complete.")
        return

    # run KMeans
    print("Running KMeans clustering...")
    start = time.time()
    kmeans = KMeans(n_clusters=K, random_state=42, n_init=10)
    labels = kmeans.fit_predict(embs)
    elapsed = time.time() - start
    print(f"KMeans done in {elapsed:.2f}s")

    # write cluster ids
    print("Writing cluster ids to DB...")
    upsert_cluster_ids(conn, ids, labels)
    conn.commit()

    # write centroids
    centroids = kmeans.cluster_centers_
    upsert_centroids(conn, centroids)
    conn.commit()

    conn.close()
    print("Done: embeddings written, clusters & centroids saved.")

if __name__ == "__main__":
    main()
