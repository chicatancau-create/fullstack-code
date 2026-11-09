// Compose/本地业务 smoke：商品 -> 下单 -> 支付。默认打容器前端 http://127.0.0.1:8081/api。
const BASE = process.env.SMOKE_BASE_URL || 'http://127.0.0.1:8081/api';
const headers = {
  'content-type': 'application/json',
  'x-api-key': process.env.P03_API_KEY || 'local-api-key',
  'x-user-id': 'compose-smoke',
};

async function call(path, init = {}) {
  const response = await fetch(`${BASE}${path}`, { ...init, headers: { ...headers, ...(init.headers || {}) } });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(`${init.method || 'GET'} ${path} -> ${response.status} ${JSON.stringify(body)}`);
  return body;
}

try {
  const { products } = await call('/products');
  const product = products.find((item) => item.stock > 0);
  if (!product) throw new Error('no product with stock');
  console.log(`smoke products=${products.length} pick=${product.sku} stock=${product.stock}`);

  const order = await call('/orders', {
    method: 'POST',
    headers: { 'idempotency-key': `compose-smoke-${Date.now()}` },
    body: JSON.stringify({ sku: product.sku, qty: 1 }),
  });
  if (order.status !== 'pending_payment') throw new Error(`unexpected status ${order.status}`);
  console.log(`smoke order=${order.id} amount=${order.amount} status=${order.status}`);

  await call(`/orders/${order.id}/pay`, { method: 'POST', body: '{}' });
  const paid = await call(`/orders/${order.id}`);
  if (paid.status !== 'paid') throw new Error(`pay did not reach paid: ${paid.status}`);
  console.log(`smoke order=${order.id} status=${paid.status}`);
  console.log('P03 COMPOSE SMOKE PASS');
} catch (error) {
  console.error(`P03 COMPOSE SMOKE FAIL: ${error.message}`);
  process.exitCode = 1;
}
