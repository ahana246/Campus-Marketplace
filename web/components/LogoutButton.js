'use client';
import { api } from './api';

export default function LogoutButton() {
  async function logout() {
    await api('/api/auth/logout', 'POST');
    window.location.href = '/';
  }
  return <button className="secondary small" onClick={logout}>Log out</button>;
}
