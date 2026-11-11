import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { requireStudent } from '@/lib/auth';
import { handler } from '@/lib/api';
import { indexListing } from '@/lib/listings';

// Create a new listing, then store its embedding in Redis for search
export const POST = handler(async (req) => {
  const user = await requireStudent();
  const { title, description, category_id, price, item_condition } = await req.json();

  const result = await query(
    'INSERT INTO listing (seller_id, category_id, title, description, price, item_condition) VALUES (?, ?, ?, ?, ?, ?)',
    [user.uid, category_id, title, description, price, item_condition]
  );

  await indexListing(result.insertId);
  return NextResponse.json({ listing_id: result.insertId });
});
