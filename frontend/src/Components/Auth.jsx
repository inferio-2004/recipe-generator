// frontend/src/components/Auth.jsx
import React, { useState } from 'react';
import { login, signup } from '../api';
import '../styles/auth.css';

export default function Auth({ onLogin }) {
  const [isLogin, setIsLogin] = useState(true);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    try {
      if (isLogin) {
        const data = await login({ email, password });
        onLogin(data.token, data.user);
      } else {
        const data = await signup({ name, email, password });
        onLogin(data.token, data.user);
      }
    } catch (err) {
      const msg = err?.error || err?.response?.data?.error || err.message || 'Auth error';
      if (isLogin && (msg === 'Invalid credentials' || err?.status === 401)) {
        setError('Invalid credentials');
      } else {
        setError(msg);
      }
    }
  }

  return (
    <div className="auth-wrap">
      <form className="auth-card" onSubmit={handleSubmit}>
        <h2>{isLogin ? 'Log in' : 'Create account'}</h2>

        {!isLogin && (
          <label className="field">
            <span>Name</span>
            <input value={name} onChange={e => setName(e.target.value)} />
          </label>
        )}

        <label className="field">
          <span>Email</span>
          <input type="email" value={email} onChange={e => setEmail(e.target.value)} required />
        </label>

        <label className="field">
          <span>Password</span>
          <input type="password" value={password} onChange={e => setPassword(e.target.value)} required />
        </label>

        <div className="actions center">
          <button className="btn primary" type="submit">{isLogin ? 'Log in' : 'Sign up'}</button>
        </div>

        {error && <div className="error">{error}</div>}

        <div className="muted small" style={{ marginTop: 14, textAlign: 'center' }}>
          {isLogin ? (
            <>Don't have an account? <button type="button" className="link" onClick={() => { setIsLogin(false); setError(''); }}>Sign up</button></>
          ) : (
            <>Already have an account? <button type="button" className="link" onClick={() => { setIsLogin(true); setError(''); }}>Log in</button></>
          )}
        </div>
      </form>
    </div>
  );
}
