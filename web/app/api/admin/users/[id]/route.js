import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { requireAdmin } from '@/lib/auth';
import { handler } from '@/lib/api';

// Admin activates / deactivates a user (runs on the admin database account)
export const PATCH = handler(async (req, { params }) => {
  await requireAdmin();
  const { id } = await params;
  const { is_active } = await req.json();
  await query('UPDATE users SET is_active = ? WHERE user_id = ?', [is_active, id], 'ADMIN');
  return NextResponse.json({ ok: true });
});
