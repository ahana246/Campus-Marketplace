'use client';
import { useState } from 'react';
import Link from 'next/link';
import { api } from './api';

export default function AuthForm({ mode }) {
  const [error, setError] = useState('');
  const isRegister = mode === 'register';

  async function onSubmit(e) {
    e.preventDefault();
    const form = Object.fromEntries(new FormData(e.target));
    try {
      const res = await api(isRegister ? '/api/auth/register' : '/api/auth/login', 'POST', form);
      window.location.href = res.role === 'ADMIN' ? '/admin' : '/';
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <form className="card form-card" onSubmit={onSubmit}>
      <h1>{isRegister ? 'Sign up' : 'Log in'}</h1>
      {isRegister && (
        <>
          <label>SRN</label>
          <input name="srn" required />
          <label>Name</label>
          <input name="name" required />
          <label>Department</label>
          <input name="department" placeholder="AIML" />
          <label>Semester</label>
          <input name="semester" type="number" min="1" max="8" />
        </>
      )}
      <label>Email</label>
      <input name="email" type="email" required />
      <label>Password</label>
      <input name="password" type="password" required />
      <p><button>{isRegister ? 'Sign up' : 'Log in'}</button></p>
      {error && <p className="error">{error}</p>}
      <p className="muted">
        {isRegister ? <Link href="/login">Already have an account?</Link> : <Link href="/register">Create an account</Link>}
      </p>
    </form>
  );
}
