import Link from 'next/link';
import { notFound } from 'next/navigation';
import RequestForm from '@/components/RequestForm';
import { money } from '@/components/api';
import { getSession } from '@/lib/auth';
import { query } from '@/lib/db';
import { addView } from '@/lib/redis';

export default async function ListingPage({ params }) {
  const { id } = await params;
  const user = await getSession();
  const [l] = await query('SELECT * FROM v_listing_details WHERE listing_id = ?', [id]);
  if (!l) notFound();

  const views = await addView(id); // Redis key-value counter
  const isOwner = user?.uid === l.seller_id;
  const isAdmin = user?.role === 'ADMIN';

  return (
    <div className="detail">
      <div className="card">
        <span className="badge">{l.category_name}</span>{' '}
        <span className={`badge ${l.status}`}>{l.status}</span>
        <h1>{l.title}</h1>
        <div className="price">{money(l.price)}</div>
        <p>{l.description}</p>
        <p className="muted">Condition: {l.item_condition.replace('_', ' ')} · {views} views</p>
        <p>Seller: {l.seller_name} {l.seller_rating && <>· ★ {l.seller_rating}</>}</p>
      </div>
      <div>
        {!user && <p><Link href="/login">Log in</Link> to buy this item.</p>}
        {isAdmin && <p className="muted">Admins cannot buy items.</p>}
        {user && !isAdmin && !isOwner && l.status === 'AVAILABLE' && <RequestForm listing={l} />}
        {isOwner && <p className="muted">This is your listing. See requests under My listings.</p>}
        {!isAdmin && !isOwner && l.status !== 'AVAILABLE' && <p className="muted">This item is no longer available.</p>}
      </div>
    </div>
  );
}
