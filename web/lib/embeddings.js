import { pipeline } from '@huggingface/transformers';

// Turns text into a list of 384 numbers (an "embedding") using the
// all-MiniLM-L6-v2 model. Texts with similar meaning get similar numbers.
// The model (~23 MB) is downloaded the first time it is used.
let model = null;

export async function embed(text) {
  if (!model) model = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2', { dtype: 'fp32' });
  const output = await model(text, { pooling: 'mean', normalize: true });
  return Array.from(output.data);
}

// The text that describes a listing
export function listingText(l) {
  return `${l.title}. ${l.category_name}. ${l.description || ''}`;
}
