// frontend/src/api.js
import axios from 'axios';

const API_BASE = process.env.REACT_APP_API_BASE || 'http://localhost:4000';

function getAuthHeaders(token) {
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function handleResp(promise) {
  try {
    const r = await promise;
    return r.data;
  } catch (err) {
    const e = err?.response?.data || { error: err.message || 'Network error' };
    throw e;
  }
}

export async function signup(payload) {
  return handleResp(axios.post(`${API_BASE}/auth/signup`, payload));
}

export async function login(payload) {
  return handleResp(axios.post(`${API_BASE}/auth/login`, payload));
}

// image_base64 should be a base64 string WITHOUT the data: prefix
export async function recognizeImageBase64(base64) {
  return handleResp(axios.post(`${API_BASE}/api/recognize`, { image_base64: base64 }));
}

export async function recommend(body, token) {
  return handleResp(axios.post(`${API_BASE}/api/recommend`, body, { headers: getAuthHeaders(token) }));
}

export async function getUserRecommendations(token, limit = 8) {
  return handleResp(
    axios.get(`${API_BASE}/api/recommend/user`, {
      headers: getAuthHeaders(token),
      params: { limit }
    })
  );
}

export async function postRecommendationAction(token, body) {
  if (!token) throw new Error('postRecommendationAction requires auth token');
  const res = await axios.post(`${API_BASE}/api/recommend/feedback`, body, {
    headers: {
      'Content-Type': 'application/json',
      ...getAuthHeaders(token),
    },
  });
  return res.data;
}

export async function getIngredients(token){
  return handleResp(axios.get(`${API_BASE}/api/recipes/getIngredients`,{ headers: getAuthHeaders(token)}));
}