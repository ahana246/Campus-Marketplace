import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import { query } from '@/lib/db';
import { createSession } from '@/lib/auth';
import { handler, bad } from '@/lib/api';

export const POST = handler(async (req) => {
  const { email, password } = await req.json();

  const [user] = await query('SELECT * FROM users WHERE email = ?', [email]);
  if (!user || !(await bcrypt.compare(password, user.password_hash))) {
    return bad('Wrong email or password.', 401);
  }
  if (!user.is_active) return bad('Your account has been deactivated.', 403);

  await createSession(user);
  return NextResponse.json({ role: user.role });
});
