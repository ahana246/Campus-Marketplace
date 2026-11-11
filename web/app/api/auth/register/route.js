import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import { query } from '@/lib/db';
import { createSession } from '@/lib/auth';
import { handler, bad } from '@/lib/api';

// Every new account is a STUDENT. Only an admin can make admins.
export const POST = handler(async (req) => {
  const { srn, name, email, password, department, semester } = await req.json();
  if (password.length < 8) return bad('Password must be at least 8 characters.');

  const hash = await bcrypt.hash(password, 10);
  try {
    const result = await query(
      'INSERT INTO users (srn, name, email, department, semester, password_hash) VALUES (?, ?, ?, ?, ?, ?)',
      [srn, name, email, department || null, semester || null, hash]
    );
    await createSession({ user_id: result.insertId, name, role: 'STUDENT' });
    return NextResponse.json({ role: 'STUDENT' });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return bad('This SRN or email is already registered.');
    throw err;
  }
});
