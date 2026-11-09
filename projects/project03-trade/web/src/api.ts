const BASE = import.meta.env.VITE_API_BASE || '/api';

export type Product = {
  sku: string;
  title: string;
  price_cents: number;
  stock: number;
};

export type Order = {
  id: number;
  status: string;
  amount: string | number;
  qty: number;
  items: Array<{ title: string; qty: number }>;
};

const headers = {
  'content-type': 'application/json',
  'x-api-key': import.meta.env.VITE_API_KEY || 'test-key',
  'x-user-id': 'demo-user',
};

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const response = await fetch(`${BASE}${path}`, {
    ...init,
    headers: { ...headers, ...(init.headers || {}) },
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error || `HTTP ${response.status}`);
  return body as T;
}

export const listProducts = () => request<{ products: Product[] }>('/products');

export const createOrder = (sku: string, qty: number) => request<Order>('/orders', {
  method: 'POST',
  headers: { 'idempotency-key': crypto.randomUUID() },
  body: JSON.stringify({ sku, qty }),
});

export const getOrder = (id: number) => request<Order>(`/orders/${id}`);

export const act = (id: number, action: 'pay' | 'cancel' | 'ship' | 'complete' | 'refund') => request<{ status: string }>(
  `/orders/${id}/${action}`,
  { method: 'POST', body: '{}' },
);
