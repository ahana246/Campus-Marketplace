import Link from 'next/link';
import './globals.css';
import { getSession } from '@/lib/auth';
import LogoutButton from '@/components/LogoutButton';

export const dynamic = 'force-dynamic';
export const metadata = { title: 'Campus Marketplace' };

export default async function RootLayout({ children }) {
  const user = await getSession();
  return (
    <html lang="en">
      <body>
        <nav className="nav">
          <div className="nav-inner">
            <Link href="/" className="brand">Campus Marketplace</Link>
            <div className="nav-links">
              <Link href="/">Browse</Link>
              {user ? (
                <>
                  {user.role !== 'ADMIN' && (
                    <>
                      <Link href="/listings/new">Sell</Link>
                      <Link href="/my/listings">My listings</Link>
                      <Link href="/my/requests">My requests</Link>
                    </>
                  )}
                  {user.role === 'ADMIN' && <Link href="/admin">Admin</Link>}
                  <span>{user.name} <span className={`badge ${user.role}`}>{user.role}</span></span>
                  <LogoutButton />
                </>
              ) : (
                <>
                  <Link href="/login">Log in</Link>
                  <Link href="/register" className="btn">Sign up</Link>
                </>
              )}
            </div>
          </div>
        </nav>
        <main className="container">{children}</main>
      </body>
    </html>
  );
}
