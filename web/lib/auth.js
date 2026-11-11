import { cookies } from 'next/headers';
import { SESSION_COOKIE, signToken, verifyToken } from './token';

// The session is a signed token { uid, name, role } kept in a cookie
export async function createSession(user) {
  const token = await signToken({ uid: user.user_id, name: user.name, role: user.role });
  (await cookies()).set(SESSION_COOKIE, token, { httpOnly: true, path: '/', maxAge: 7 * 24 * 3600 });
}

export async function destroySession() {
  (await cookies()).delete(SESSION_COOKIE);
}

export async function getSession() {
  return verifyToken((await cookies()).get(SESSION_COOKIE)?.value);
}

function authError(message, status) {
  const err = new Error(message);
  err.status = status;
  return err;
}

export async function requireUser() {
  const s = await getSession();
  if (!s) throw authError('Please log in first.', 401);
  return s;
}

// Buying and selling is for students only; admins just manage the platform
export async function requireStudent() {
  const s = await requireUser();
  if (s.role === 'ADMIN') throw authError('Admins cannot buy or sell.', 403);
  return s;
}

export async function requireAdmin() {
  const s = await requireUser();
  if (s.role !== 'ADMIN') throw authError('Admins only.', 403);
  return s;
}
