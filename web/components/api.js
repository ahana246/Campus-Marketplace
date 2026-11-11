// Send JSON to one of our API routes; throws the API's error message
export async function api(url, method, body) {
  const res = await fetch(url, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body || {}),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error);
  return data;
}

export const money = (v) => `₹${Number(v)}`;
