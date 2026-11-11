'use client';
import { api } from './api';

// Admin button to activate / deactivate a user
export default function UserToggle({ userId, isActive }) {
  async function toggle() {
    await api(`/api/admin/users/${userId}`, 'PATCH', { is_active: !isActive });
    window.location.reload();
  }
  return (
    <button className={`small ${isActive ? 'danger' : 'ok'}`} onClick={toggle}>
      {isActive ? 'Deactivate' : 'Activate'}
    </button>
  );
}
