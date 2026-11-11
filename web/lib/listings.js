import { query } from './db';
import { embed, listingText } from './embeddings';
import { createIndex, saveListing, searchSimilar, setStatus } from './redis';

// How similar (0 to 1) a semantic match must be to be shown
const MIN_SIMILARITY = 0.3;

// One search bar, two engines:
//   1. MySQL FULLTEXT finds listings that contain the words typed
//   2. Redis vector search adds listings with a similar meaning
//      (e.g. "maths book" also finds "Engineering Mathematics - Grewal")
export async function searchListings(q) {
  if (!q) {
    return query("SELECT * FROM v_listing_details WHERE status = 'AVAILABLE' ORDER BY created_at DESC");
  }

  const keywordMatches = await query(
    `SELECT * FROM v_listing_details
     WHERE status = 'AVAILABLE' AND MATCH(title, description) AGAINST (?)
     ORDER BY MATCH(title, description) AGAINST (?) DESC`,
    [q, q]
  );

  const hits = (await searchSimilar(await embed(q), 6)).filter((h) => h.similarity >= MIN_SIMILARITY);
  const newIds = hits.map((h) => h.listing_id).filter((id) => !keywordMatches.some((l) => l.listing_id === id));
  const similarMatches = newIds.length
    ? await query('SELECT * FROM v_listing_details WHERE listing_id IN (?)', [newIds])
    : [];

  return [...keywordMatches, ...similarMatches];
}

// Compute a listing's embedding and store it in Redis
export async function indexListing(listingId) {
  const [listing] = await query('SELECT * FROM v_listing_details WHERE listing_id = ?', [listingId]);
  await createIndex();
  await saveListing(listing, await embed(listingText(listing)));
}

// After a status change in MySQL, copy the new status to Redis
export async function syncStatus(listingId) {
  const [row] = await query('SELECT status FROM listing WHERE listing_id = ?', [listingId]);
  await setStatus(listingId, row.status);
}
