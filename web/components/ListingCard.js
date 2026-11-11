import Link from 'next/link';
import { money } from './api';

export default function ListingCard({ l }) {
  return (
    <Link href={`/listings/${l.listing_id}`} className="card listing-card">
      <span className="badge">{l.category_name}</span>
      <h3>{l.title}</h3>
      <div className="price">{money(l.price)}</div>
      <div className="muted">Condition: {l.item_condition.replace('_', ' ')}</div>
      <div className="muted">Seller: {l.seller_name}</div>
    </Link>
  );
}
