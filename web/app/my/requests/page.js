import Link from 'next/link';
import RequestActions from '@/components/RequestActions';
import ReviewForm from '@/components/ReviewForm';
import { money } from '@/components/api';
import { requireUser } from '@/lib/auth';
import { query } from '@/lib/db';

// Buyer view: requests I sent; after a completed deal I can review the seller
export default async function MyRequestsPage() {
  const user = await requireUser();
  const requests = await query(
    `SELECT r.*, l.title, l.seller_id, s.name AS seller_name, t.transaction_id, rv.rating
     FROM purchase_request r
     JOIN listing l           ON l.listing_id = r.listing_id
     JOIN users s             ON s.user_id    = l.seller_id
     LEFT JOIN transactions t ON t.request_id = r.request_id
     LEFT JOIN review rv      ON rv.transaction_id = t.transaction_id AND rv.reviewer_id = r.buyer_id
     WHERE r.buyer_id = ?
     ORDER BY r.requested_at DESC`,
    [user.uid]
  );

  return (
    <>
      <h1>My requests</h1>
      <table>
        <thead>
          <tr><th>Item</th><th>Seller</th><th>My offer</th><th>Status</th><th></th></tr>
        </thead>
        <tbody>
          {requests.map((r) => (
            <tr key={r.request_id}>
              <td><Link href={`/listings/${r.listing_id}`}>{r.title}</Link></td>
              <td>{r.seller_name}</td>
              <td>{money(r.offered_price)}</td>
              <td><span className={`badge ${r.status}`}>{r.transaction_id ? 'COMPLETED' : r.status}</span></td>
              <td>
                {r.transaction_id && r.rating && <span>You rated {r.rating} ★</span>}
                {r.transaction_id && !r.rating && <ReviewForm transactionId={r.transaction_id} sellerId={r.seller_id} />}
                {!r.transaction_id && <RequestActions requestId={r.request_id} status={r.status} side="buyer" />}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}
