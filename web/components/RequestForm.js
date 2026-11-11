'use client';
import { useState } from 'react';
import { api } from './api';

// Buyer offers a price for the listing
export default function RequestForm({ listing }) {
  const [msg, setMsg] = useState('');

  async function onSubmit(e) {
    e.preventDefault();
    const form = Object.fromEntries(new FormData(e.target));
    try {
      await api('/api/requests', 'POST', { ...form, listing_id: listing.listing_id });
      setMsg('Request sent! See "My requests".');
    } catch (err) {
      setMsg(err.message);
    }
  }

  return (
    <form className="card" onSubmit={onSubmit}>
      <h3>Buy this item</h3>
      <label>Your offer (₹)</label>
      <input name="offered_price" type="number" min="0" required defaultValue={listing.price} />
      <label>Message to the seller</label>
      <input name="message" />
      <p><button>Send request</button></p>
      {msg && <p className="muted">{msg}</p>}
    </form>
  );
}
