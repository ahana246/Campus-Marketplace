import { NextResponse } from 'next/server';
import { SESSION_COOKIE, verifyToken } from './lib/token';

// Pages that need a login; /admin also needs the ADMIN role
export async function middleware(req) {
  const session = await verifyToken(req.cookies.get(SESSION_COOKIE)?.value);
  if (!session) return NextResponse.redirect(new URL('/login', req.url));
  if (req.nextUrl.pathname.startsWith('/admin') && session.role !== 'ADMIN') {
    return NextResponse.redirect(new URL('/', req.url));
  }
  // Admins do not buy or sell, so keep them out of the student pages
  if (!req.nextUrl.pathname.startsWith('/admin') && session.role === 'ADMIN') {
    return NextResponse.redirect(new URL('/admin', req.url));
  }
  return NextResponse.next();
}

export const config = {
  matcher: ['/my/:path*', '/admin/:path*', '/listings/new'],
};
