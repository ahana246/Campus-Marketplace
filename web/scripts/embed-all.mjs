// Computes an embedding for every listing in MySQL and stores it in Redis.
// Run once after the database is created:   npm run embed
import mysql from 'mysql2/promise';
import { createClient, SchemaFieldTypes, VectorAlgorithms } from 'redis';
import { pipeline } from '@huggingface/transformers';

const db = await mysql.createConnection({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  database: process.env.DB_NAME,
  user: process.env.DB_ADMIN_USER,
  password: process.env.DB_ADMIN_PASSWORD,
});
const redis = createClient({ url: process.env.REDIS_URL });
await redis.connect();

// create the vector index (skip if it already exists)
try {
  await redis.ft.create(
    'idx:listings',
    {
      title: SchemaFieldTypes.TEXT,
      status: SchemaFieldTypes.TAG,
      price: SchemaFieldTypes.NUMERIC,
      embedding: {
        type: SchemaFieldTypes.VECTOR,
        ALGORITHM: VectorAlgorithms.FLAT,
        TYPE: 'FLOAT32',
        DIM: 384,
        DISTANCE_METRIC: 'COSINE',
      },
    },
    { ON: 'HASH', PREFIX: 'listing:' }
  );
} catch (e) {
  if (!e.message.includes('Index already exists')) throw e;
}

console.log('Loading the embedding model...');
const model = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2', { dtype: 'fp32' });

const [listings] = await db.query('SELECT * FROM v_listing_details');
for (const l of listings) {
  const output = await model(`${l.title}. ${l.category_name}. ${l.description || ''}`, { pooling: 'mean', normalize: true });
  await redis.hSet(`listing:${l.listing_id}`, {
    listing_id: String(l.listing_id),
    title: l.title,
    status: l.status,
    price: String(l.price),
    embedding: Buffer.from(new Float32Array(output.data).buffer),
  });
  console.log(`  saved listing ${l.listing_id}: ${l.title}`);
}

console.log(`Done: ${listings.length} listings stored in Redis.`);
await db.end();
await redis.quit();
