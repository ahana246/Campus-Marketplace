'use client';
import { api } from './api';

// Buttons for one request. Seller: Accept / Reject / Complete. Buyer: Cancel.
export default function RequestActions({ requestId, status, side, completed }) {
  async function act(action, payment_mode) {
    try {
      await api(`/api/requests/${requestId}`, 'PATCH', { action, payment_mode });
      window.location.reload();
    } catch (err) {
      alert(err.message);
    }
  }

  if (side === 'seller' && status === 'PENDING') {
    return (
      <div className="actions">
        <button className="ok small" onClick={() => act('ACCEPT')}>Accept</button>
        <button className="danger small" onClick={() => act('REJECT')}>Reject</button>
      </div>
    );
  }
  if (side === 'seller' && status === 'ACCEPTED' && !completed) {
    return (
      <div className="actions">
        <button className="ok small" onClick={() => act('COMPLETE', 'UPI')}>Paid by UPI</button>
        <button className="ok small" onClick={() => act('COMPLETE', 'CASH')}>Paid in cash</button>
      </div>
    );
  }
  if (side === 'buyer' && status === 'PENDING') {
    return <button className="secondary small" onClick={() => act('CANCEL')}>Cancel</button>;
  }
  return null;
}
