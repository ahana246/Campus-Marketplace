import { createClient, SchemaFieldTypes, VectorAlgorithms } from 'redis';

// Redis (NoSQL) is used as
//   1. a key-value store : views:listing:<id>  -> number of views
//   2. a vector database : listing:<id> hash with a 384-number embedding
const INDEX = 'idx:listings';
let client = null;

export async function getRedis() {
  if (!client) {
    client = createClient({ url: process.env.REDIS_URL });
    client.on('error', (e) => console.error('Redis error:', e.message));
    await client.connect();
  }
  return client;
}

const toBytes = (vector) => Buffer.from(new Float32Array(vector).buffer);

// FT.CREATE idx:listings ON HASH PREFIX 1 listing: SCHEMA ... embedding VECTOR FLAT ...
export async function createIndex() {
  const r = await getRedis();
  try {
    await r.ft.create(
      INDEX,
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
}

// CREATE / UPDATE: store a listing and its embedding
export async function saveListing(listing, vector) {
  const r = await getRedis();
  await r.hSet(`listing:${listing.listing_id}`, {
    listing_id: String(listing.listing_id),
    title: listing.title,
    status: listing.status,
    price: String(listing.price),
    embedding: toBytes(vector),
  });
}

// UPDATE: keep the status in Redis the same as in MySQL
export async function setStatus(listingId, status) {
  const r = await getRedis();
  await r.hSet(`listing:${listingId}`, 'status', status);
}

// READ: the k listings whose embedding is closest to the query vector
export async function searchSimilar(vector, k = 6) {
  const r = await getRedis();
  const res = await r.ft.search(INDEX, `(@status:{AVAILABLE})=>[KNN ${k} @embedding $vec AS score]`, {
    PARAMS: { vec: toBytes(vector) },
    SORTBY: 'score',
    RETURN: ['listing_id', 'score'],
    DIALECT: 2,
  });
  // cosine distance -> similarity
  return res.documents.map((d) => ({
    listing_id: Number(d.value.listing_id),
    similarity: 1 - Number(d.value.score),
  }));
}

// Key-value: count a view of a listing and return the new total
export async function addView(listingId) {
  const r = await getRedis();
  return r.incr(`views:listing:${listingId}`);
}
