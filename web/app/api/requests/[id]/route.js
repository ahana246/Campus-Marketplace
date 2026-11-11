import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { requireStudent } from '@/lib/auth';
import { handler, bad } from '@/lib/api';
import { syncStatus } from '@/lib/listings';

// action = ACCEPT | REJECT | COMPLETE (seller)   or   CANCEL (buyer)
export const PATCH = handler(async (req, { params }) => {
  const user = await requireStudent();
  const { id } = await params;
  const { action, payment_mode } = await req.json();

  if (action === 'ACCEPT') {
    await query('CALL sp_accept_request(?, ?)', [id, user.uid]);
  } else if (action === 'COMPLETE') {
    await query('CALL sp_complete_transaction(?, ?, ?)', [id, user.uid, payment_mode]);
  } else if (action === 'REJECT') {
    const result = await query(
      `UPDATE purchase_request r JOIN listing l ON l.listing_id = r.listing_id
       SET r.status = 'REJECTED'
       WHERE r.request_id = ? AND l.seller_id = ? AND r.status = 'PENDING'`,
      [id, user.uid]
    );
    if (result.affectedRows === 0) return bad('You cannot reject this request');
  } else if (action === 'CANCEL') {
    const result = await query(
      "UPDATE purchase_request SET status = 'CANCELLED' WHERE request_id = ? AND buyer_id = ? AND status = 'PENDING'",
      [id, user.uid]
    );
    if (result.affectedRows === 0) return bad('You cannot cancel this request');
  } else {
    return bad('Unknown action');
  }

  // listing status may have changed -> update Redis too
  const [r] = await query('SELECT listing_id FROM purchase_request WHERE request_id = ?', [id]);
  await syncStatus(r.listing_id);
  return NextResponse.json({ ok: true });
});
