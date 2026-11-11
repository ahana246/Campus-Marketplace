import ListingCard from '@/components/ListingCard';
import { searchListings } from '@/lib/listings';

// Home page: all available listings, with one search bar
export default async function Home({ searchParams }) {
  const { q = '' } = await searchParams;
  const listings = await searchListings(q);

  return (
    <>
      <h1>Find it on campus</h1>
      <form className="search">
        <input name="q" defaultValue={q} placeholder="Search for books, calculators, lab coats..." />
        <button>Search</button>
      </form>
      {q && <p className="muted">{listings.length} result(s) for "{q}"</p>}
      {listings.length === 0 && <p className="muted">No listings found.</p>}
      <div className="grid">
        {listings.map((l) => <ListingCard key={l.listing_id} l={l} />)}
      </div>
    </>
  );
}
