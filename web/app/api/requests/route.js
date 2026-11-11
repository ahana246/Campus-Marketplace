import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { requireStudent } from '@/lib/auth';
import { handler } from '@/lib/api';

// Buyer sends a request. The trigger trg_request_before_insert rejects
// requests for your own listing or for a listing that is not available.
export const POST = handler(async (req) => {
  const user = await requireStudent();
  const { listing_id, offered_price, message } = await req.json();

  await query('INSERT INTO purchase_request (listing_id, buyer_id, offered_price, message) VALUES (?, ?, ?, ?)', [
    listing_id,
    user.uid,
    offered_price,
    message,
  ]);
  return NextResponse.json({ ok: true });
});
