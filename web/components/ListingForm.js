'use client';
import { useState } from 'react';
import { api } from './api';

export default function ListingForm({ categories }) {
  const [error, setError] = useState('');

  async function onSubmit(e) {
    e.preventDefault();
    const form = Object.fromEntries(new FormData(e.target));
    try {
      const res = await api('/api/listings', 'POST', form);
      window.location.href = `/listings/${res.listing_id}`;
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <form className="card form-card" onSubmit={onSubmit}>
      <h1>Sell an item</h1>
      <label>Title</label>
      <input name="title" required placeholder="e.g. Casio fx-991EX Calculator" />
      <label>Description</label>
      <textarea name="description" />
      <label>Category</label>
      <select name="category_id" required>
        {categories.map((c) => (
          <option key={c.category_id} value={c.category_id}>{c.name}</option>
        ))}
      </select>
      <label>Price (₹)</label>
      <input name="price" type="number" min="0" required />
      <label>Condition</label>
      <select name="item_condition" defaultValue="GOOD">
        <option value="NEW">New</option>
        <option value="LIKE_NEW">Like new</option>
        <option value="GOOD">Good</option>
        <option value="FAIR">Fair</option>
      </select>
      <p><button>Publish</button></p>
      {error && <p className="error">{error}</p>}
    </form>
  );
}
