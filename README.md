# 🍽️ Smart Recipe Generator  
> **AI-powered recipe discovery platform** using *vector embeddings*, *ingredient recognition*, and *personalized recommendations*  
> 🌐 Live App: [https://recipe-generator-frontend.onrender.com](https://recipe-generator-frontend.onrender.com)

![React](https://img.shields.io/badge/frontend-React-blue?logo=react)
![Express](https://img.shields.io/badge/backend-Express-green?logo=express)
![PostgreSQL](https://img.shields.io/badge/database-PostgreSQL-blue?logo=postgresql)
![pgvector](https://img.shields.io/badge/AI%20Search-pgvector-yellow?logo=postgresql)
![Clarifai](https://img.shields.io/badge/API-Clarifai-orange?logo=clarifai)
![Render](https://img.shields.io/badge/Deployed_on-Render-purple?logo=render)

---

## 🧠 Core Innovation — Vector Embedding Recommendations

This project uses **semantic recipe embeddings** stored via **pgvector** to recommend recipes *not just by ingredients*, but by *conceptual similarity*.

### How it works:
1. Each recipe’s title, ingredients, and summary are converted into a **384‑dimensional SBERT embedding**.  
2. User interactions (likes/dislikes) adjust the preference vector.  
3. Recommendations are generated via **cosine similarity search** on pgvector embeddings.  
4. This ensures suggestions that *feel contextually relevant* — e.g., “Tomato Basil Soup” suggests “Creamy Tomato Bisque.”  

```sql
-- Example query using pgvector similarity
SELECT id, title, summary
FROM recipes
ORDER BY embedding <-> $1
LIMIT 10;
```

> 💡 *The result: Human‑like food intuition, powered by embeddings.*

---

## 🚀 Overview

The **Smart Recipe Generator** lets users upload food images, recognizes ingredients via **Clarifai API**, and recommends semantically similar recipes.  
The app combines *vector embeddings*, *ingredient matching*, and *user history learning* for next‑gen personalization.

---

## ✨ Key Features
- 🧠 **Vector Embedding Search** (pgvector) — find semantically similar recipes.  
- 🥗 **Ingredient Recognition** — powered by Clarifai API.  
- ❤️ **Personalized Recommendations** — learns from your liked recipes.  
- 🔍 **Hybrid Ranking** — blends vector, ingredient, and user preference scores.  
- 💾 **PostgreSQL Database** with pgvector + pg_trgm extensions.  
- 🧾 **JWT Authentication** — secure login/signup system.  
- 💻 **Responsive React Frontend** — smooth UI & swipable recipe cards.  
- ☁️ **Fully Deployed on Render** — backend, frontend, and database.

---

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend** | React (Vite / CRA), Axios, Tailwind |
| **Backend** | Node.js, Express.js |
| **Database** | PostgreSQL + pgvector + pg_trgm |
| **AI Model** | Sentence-BERT (MiniLM-L6-v2) + Clarifai Food Model |
| **Deployment** | Render Cloud |
| **Authentication** | JWT Tokens |

---

## 🖼️ Screenshots

### 🔹 Login
<img width="1919" height="951" alt="Screenshot 2025-10-16 104906" src="https://github.com/user-attachments/assets/811d7ae6-6d33-468f-b1ea-63203129f6bf" />

### 🔹 Sign Up
<img width="1919" height="942" alt="Screenshot 2025-10-16 104924" src="https://github.com/user-attachments/assets/9a7ff643-aab4-4d0d-926b-337a6c0dd1bd" />

### 🔹 Ingredient Recognition
<img width="1919" height="791" alt="Screenshot 2025-10-16 105123" src="https://github.com/user-attachments/assets/3c79fe88-0de4-4753-8ba6-b65bf81c781c" />

### 🔹 Recipe Results
<img width="1906" height="914" alt="Screenshot 2025-10-16 105212" src="https://github.com/user-attachments/assets/5b30a061-1a51-49cc-9976-721909ff20d6" />

### 🔹 Personalized Recommendations
<img width="1885" height="823" alt="Screenshot 2025-10-16 105234" src="https://github.com/user-attachments/assets/88ca8d01-7c7d-4b85-87dc-08981e5b6fd3" />

---

## 📁 Project Structure

```
recipe-generator/
│
├── backend/
│   ├── routes/              # Express routes
│   ├── migrations/          # SQL setup & embeddings
│   ├── db.js                # Postgres connection
│   ├── index.js             # Main Express app
│   └── .env                 # Backend environment
│
├── frontend/
│   ├── src/
│   │   ├── Components/      # UI Components
│   │   ├── api.js           # API integration
│   │   └── App.jsx          # React main file
│   └── .env
│
└── README.md
```

---

## ⚙️ Environment Variables

### 🔹 Backend (`/backend/.env`)
```env
DATABASE_URL=postgres://<user>:<password>@<host>:<port>/<dbname>
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d
CLARIFAI_API_KEY=your_clarifai_key
CLARIFAI_USER_ID=clarifai
CLARIFAI_APP_ID=main
CLARIFAI_MODEL_ID=food-item-recognition
PORT=4000
PGSSLMODE=require
```

### 🔹 Frontend (`/frontend/.env`)
```env
REACT_APP_API_BASE=https://recipe-generator-backend.onrender.com/api
```

---

## 💾 Database Setup Order

1️⃣ `init_with_recipes.sql`  
2️⃣ `add_users_and_prefs.sql`  
3️⃣ `insert_20_recipes_safe.sql`  
4️⃣ `insert_20_recipes_extra.sql`  
5️⃣ `update_recipe_images.sql`  
6️⃣ `add_pgvector_and_clusters.sql`  
7️⃣ Run `compute_embeddings_and_clusters.py`

---

## 🧠 AI Recommendation Pipeline

| Step | Component | Description |
|------|------------|-------------|
| 1 | **Clarifai API** | Detects ingredients in uploaded food images |
| 2 | **pg_trgm Match** | Maps noisy ingredient labels to canonical DB entries |
| 3 | **pgvector Embedding** | Finds similar recipes via vector distance |
| 4 | **Hybrid Ranker** | Combines ingredient overlap, user history, vector similarity |
| 5 | **Frontend Display** | Shows recipes with swipe & like/dislike actions |

---

## 🧪 Local Development

### Setup
```bash
git clone https://github.com/<your-username>/recipe-generator.git
cd recipe-generator
```

### Backend
```bash
cd backend
npm install
npm start
```

### Frontend
```bash
cd ../frontend
npm install
npm start
```

Access: [http://localhost:3000](http://localhost:3000)

---

## ☁️ Deployment (Render)

### **Backend — Web Service**
- Root Directory → `backend/`  
- Build Command → `npm install`  
- Start Command → `node index.js`  

### **Frontend — Static Site**
- Root Directory → `frontend/`  
- Build Command → `npm run build`  
- Publish Directory → `build`  
- Environment Variable →  
  ```env
  REACT_APP_API_BASE=https://recipe-generator-backend.onrender.com/api
  ```

---

## 🧑‍💻 Author

**Hema Malini Sriram**  
💼 Segment Head & Foundation Stage Coordinator  
📧 [Contact via GitHub Issues]()

---

> _“Cooking is an art; recommending is a science.”_  
> **— Smart Recipe Generator Team**
