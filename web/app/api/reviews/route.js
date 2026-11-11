import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { requireStudent } from '@/lib/auth';
import { handler, bad } from '@/lib/api';

// Buyer reviews the seller of a completed deal.
// The trigger trg_review_before_insert checks they really were the two parties.
export const POST = handler(async (req) => {
  const user = await requireStudent();
  const { transaction_id, seller_id, rating, comment } = await req.json();
  try {
    await query(
      'INSERT INTO review (transaction_id, reviewer_id, reviewee_id, rating, comment) VALUES (?, ?, ?, ?, ?)',
      [transaction_id, user.uid, seller_id, rating, comment]
    );
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return bad('You already reviewed this deal.');
    throw err;
  }
  return NextResponse.json({ ok: true });
});
