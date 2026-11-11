import ListingForm from '@/components/ListingForm';
import { query } from '@/lib/db';

export default async function NewListingPage() {
  const categories = await query('SELECT category_id, name FROM category ORDER BY name');
  return <ListingForm categories={categories} />;
}
