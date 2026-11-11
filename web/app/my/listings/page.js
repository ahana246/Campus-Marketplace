import Link from 'next/link';
import RequestActions from '@/components/RequestActions';
import { money } from '@/components/api';
import { requireUser } from '@/lib/auth';
import { query } from '@/lib/db';

// Seller view: my listings and the requests other students sent for them
export default async function MyListingsPage() {
  const user = await requireUser();

  const listings = await query('SELECT * FROM listing WHERE seller_id = ? ORDER BY created_at DESC', [user.uid]);
  const requests = await query(
    `SELECT r.*, l.title, b.name AS buyer_name, t.transaction_id
     FROM purchase_request r
     JOIN listing l           ON l.listing_id = r.listing_id
     JOIN users b             ON b.user_id    = r.buyer_id
     LEFT JOIN transactions t ON t.request_id = r.request_id
     WHERE l.seller_id = ?
     ORDER BY r.requested_at DESC`,
    [user.uid]
  );

  return (
    <>
      <h1>My listings</h1>
      <table>
        <thead>
          <tr><th>Title</th><th>Price</th><th>Status</th></tr>
        </thead>
        <tbody>
          {listings.map((l) => (
            <tr key={l.listing_id}>
              <td><Link href={`/listings/${l.listing_id}`}>{l.title}</Link></td>
              <td>{money(l.price)}</td>
              <td><span className={`badge ${l.status}`}>{l.status}</span></td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2>Requests for my items</h2>
      <table>
        <thead>
          <tr><th>Item</th><th>Buyer</th><th>Offer</th><th>Message</th><th>Status</th><th></th></tr>
        </thead>
        <tbody>
          {requests.map((r) => (
            <tr key={r.request_id}>
              <td>{r.title}</td>
              <td>{r.buyer_name}</td>
              <td>{money(r.offered_price)}</td>
              <td>{r.message}</td>
              <td><span className={`badge ${r.status}`}>{r.transaction_id ? 'COMPLETED' : r.status}</span></td>
              <td>
                <RequestActions requestId={r.request_id} status={r.status} side="seller" completed={!!r.transaction_id} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}
