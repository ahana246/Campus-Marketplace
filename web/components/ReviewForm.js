'use client';
import { api } from './api';

export default function ReviewForm({ transactionId, sellerId }) {
  async function onSubmit(e) {
    e.preventDefault();
    const form = Object.fromEntries(new FormData(e.target));
    try {
      await api('/api/reviews', 'POST', { ...form, transaction_id: transactionId, seller_id: sellerId });
      window.location.reload();
    } catch (err) {
      alert(err.message);
    }
  }

  return (
    <form className="actions" onSubmit={onSubmit}>
      <select name="rating" defaultValue="5" style={{ width: 'auto' }}>
        {[5, 4, 3, 2, 1].map((r) => <option key={r} value={r}>{r} ★</option>)}
      </select>
      <input name="comment" placeholder="Comment" style={{ width: 160 }} />
      <button className="small">Review</button>
    </form>
  );
}
