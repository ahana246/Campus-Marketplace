import { NextResponse } from 'next/server';

// Wraps an API route so every error becomes a JSON { error } response.
// Errors raised with SIGNAL SQLSTATE '45000' in our triggers / procedures
// carry a readable message, so we show it to the user.
export function handler(fn) {
  return async (req, ctx) => {
    try {
      return await fn(req, ctx);
    } catch (err) {
      if (err.sqlState === '45000' || err.status) {
        return NextResponse.json({ error: err.sqlMessage || err.message }, { status: err.status || 400 });
      }
      console.error(err);
      return NextResponse.json({ error: 'Something went wrong' }, { status: 500 });
    }
  };
}

export function bad(message, status = 400) {
  return NextResponse.json({ error: message }, { status });
}
