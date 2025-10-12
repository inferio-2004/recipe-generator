import React, { useState, useEffect } from 'react';
import Auth from './Components/Auth';
import Home from './Components/Home';

export default function App() {
  const [token, setToken] = useState(localStorage.getItem('token'));
  const [user, setUser] = useState(JSON.parse(localStorage.getItem('user') || 'null'));

  useEffect(() => {
    if (token) localStorage.setItem('token', token);
    else localStorage.removeItem('token');
  }, [token]);

  useEffect(() => {
    if (user) localStorage.setItem('user', JSON.stringify(user));
    else localStorage.removeItem('user');
  }, [user]);

  function handleLogin(tkn, usr) {
    setToken(tkn);
    setUser(usr);
  }
  function handleLogout() {
    setToken(null);
    setUser(null);
  }

  return token ? (
    <Home token={token} user={user} onLogout={handleLogout} />
  ) : (
    <Auth onLogin={handleLogin} />
  );
}
