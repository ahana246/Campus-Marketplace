import UserToggle from '@/components/UserToggle';
import { money } from '@/components/api';
import { requireAdmin } from '@/lib/auth';
import { query } from '@/lib/db';

// Admin dashboard - every query runs on the admin database account
export default async function AdminPage() {
  await requireAdmin();
  const admin = (sql) => query(sql, [], 'ADMIN');

  const [stats] = await admin(
    `SELECT (SELECT COUNT(*) FROM users)                                 AS users,
            (SELECT COUNT(*) FROM listing WHERE status = 'AVAILABLE')    AS available,
            (SELECT COUNT(*) FROM transactions)                          AS deals,
            (SELECT COALESCE(SUM(amount), 0) FROM transactions)          AS revenue`
  );
  const sellers = await admin('SELECT * FROM v_seller_stats WHERE deals > 0 ORDER BY revenue DESC');
  const users = await admin('SELECT user_id, srn, name, email, role, is_active FROM users ORDER BY user_id');
  const audit = await admin('SELECT * FROM audit_log ORDER BY log_id DESC LIMIT 10');

  return (
    <>
      <h1>Admin dashboard</h1>
      <div className="stats">
        <div className="card"><div className="muted">Users</div><div className="value">{stats.users}</div></div>
        <div className="card"><div className="muted">Available listings</div><div className="value">{stats.available}</div></div>
        <div className="card"><div className="muted">Completed deals</div><div className="value">{stats.deals}</div></div>
        <div className="card"><div className="muted">Money exchanged</div><div className="value">{money(stats.revenue)}</div></div>
      </div>

      <h2>Sellers (view v_seller_stats)</h2>
      <table>
        <thead><tr><th>Name</th><th>Deals</th><th>Revenue</th><th>Rating</th></tr></thead>
        <tbody>
          {sellers.map((s) => (
            <tr key={s.user_id}><td>{s.name}</td><td>{s.deals}</td><td>{money(s.revenue)}</td><td>{s.rating ?? '-'}</td></tr>
          ))}
        </tbody>
      </table>

      <h2>Users</h2>
      <table>
        <thead><tr><th>SRN</th><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th></th></tr></thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.user_id}>
              <td>{u.srn}</td><td>{u.name}</td><td>{u.email}</td>
              <td><span className={`badge ${u.role}`}>{u.role}</span></td>
              <td>{u.is_active ? 'Active' : 'Deactivated'}</td>
              <td>{u.role === 'STUDENT' && <UserToggle userId={u.user_id} isActive={!!u.is_active} />}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2>Audit log (written by a trigger)</h2>
      <table>
        <thead><tr><th>When</th><th>Listing</th><th>Old status</th><th>New status</th></tr></thead>
        <tbody>
          {audit.map((a) => (
            <tr key={a.log_id}><td>{a.changed_at}</td><td>{a.listing_id}</td><td>{a.old_status}</td><td>{a.new_status}</td></tr>
          ))}
        </tbody>
      </table>
    </>
  );
}
