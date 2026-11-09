import test, { before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import { createPool } from '../src/db.mjs';
import { buildApp } from '../src/app.js';

const API = { 'x-api-key': 'test-key', 'x-user-id': 'alice' };
const SECRET = 'test-provider-secret';
const signRaw = (raw) => crypto.createHmac('sha256', SECRET).update(raw).digest('hex');

let pool;
let app;

before(async () => {
  pool = createPool();
  app = buildApp({ pool });
  await app.ready();
});

after(async () => {
  await app.close();
  await pool.end();
});

beforeEach(async () => {
  await pool.query('TRUNCATE p03.notifications, p03.outbox, p03.payment_events, p03.order_items, p03.orders, p03.audit_log, p03.payments, p03.refunds RESTART IDENTITY CASCADE');
  await pool.query('TRUNCATE p03.inventory, p03.products CASCADE');
  await pool.query("INSERT INTO p03.products (sku, title, price_cents) VALUES ('sku-1','机械键盘',299)");
  await pool.query("INSERT INTO p03.inventory (sku, title, unit_price, stock) VALUES ('sku-1','机械键盘',299,5)");
});

async function createOrder() {
  const res = await app.inject({
    method: 'POST',
    url: '/orders',
    headers: { ...API, 'idempotency-key': crypto.randomUUID() },
    payload: { sku: 'sku-1', qty: 1 },
  });
  assert.equal(res.statusCode, 201);
  return res.json();
}

test('A02：生产环境缺少显式秘密时拒绝启动', () => {
  const previous = { env: process.env.NODE_ENV, api: process.env.P03_API_KEY, secret: process.env.P03_PROVIDER_SECRET };
  process.env.NODE_ENV = 'production';
  delete process.env.P03_API_KEY;
  delete process.env.P03_PROVIDER_SECRET;
  try {
    assert.throws(() => buildApp({ pool }), /生产环境必须显式设置/);
  } finally {
    process.env.NODE_ENV = previous.env;
    if (previous.api !== undefined) process.env.P03_API_KEY = previous.api;
    if (previous.secret !== undefined) process.env.P03_PROVIDER_SECRET = previous.secret;
  }
});

test('A02：完整安全头存在，跨域来源被拒绝，同源放行', async () => {
  const ok = await app.inject({ method: 'GET', url: '/health' });
  assert.equal(ok.headers['content-security-policy'], "default-src 'none'; frame-ancestors 'none'");
  assert.equal(ok.headers['x-frame-options'], 'DENY');
  assert.equal(ok.headers['x-content-type-options'], 'nosniff');
  assert.equal(ok.headers['permissions-policy'], 'geolocation=(), camera=(), microphone=()');

  const evil = await app.inject({ method: 'GET', url: '/health', headers: { origin: 'https://evil.example' } });
  assert.equal(evil.statusCode, 403);
  assert.equal(evil.json().error, 'origin_not_allowed');

  const same = await app.inject({ method: 'GET', url: '/health', headers: { origin: 'http://localhost:80' } });
  assert.equal(same.statusCode, 200);
  assert.equal(same.headers['access-control-allow-origin'], 'http://localhost:80');
});

test('A04：签名按原始字节校验，重排/加空格篡改被拒', async () => {
  const order = await createOrder();
  const body = { event_id: 'raw-1', order_id: order.id, result: 'success', timestamp: Date.now() };
  const compact = JSON.stringify(body);
  const tampered = JSON.stringify(body, null, 2);
  const res = await app.inject({
    method: 'POST',
    url: '/payments/callback',
    headers: { 'content-type': 'application/json', 'x-signature': signRaw(compact) },
    payload: tampered,
  });
  assert.equal(res.statusCode, 401);
  assert.equal(res.json().error, 'bad_signature');

  const good = await app.inject({
    method: 'POST',
    url: '/payments/callback',
    headers: { 'content-type': 'application/json', 'x-signature': signRaw(compact) },
    payload: compact,
  });
  assert.equal(good.statusCode, 200);
});

test('A01：跨用户发货/完成/退款均 404，且状态不变', async () => {
  const order = await createOrder();
  for (const action of ['ship', 'complete', 'refund']) {
    const res = await app.inject({
      method: 'POST',
      url: `/orders/${order.id}/${action}`,
      headers: { 'x-api-key': 'test-key', 'x-user-id': 'bob' },
    });
    assert.equal(res.statusCode, 404, action);
  }
  const row = (await pool.query('SELECT status FROM p03.orders WHERE id = $1', [order.id])).rows[0];
  assert.equal(row.status, 'pending_payment');
});

test('A05：注入型 SKU 不落单、不 500，错误信息不泄露 SQL', async () => {
  const before = (await pool.query('SELECT count(*)::int AS n FROM p03.orders')).rows[0].n;
  const res = await app.inject({
    method: 'POST',
    url: '/orders',
    headers: { ...API, 'idempotency-key': 'inject-1' },
    payload: { sku: "' OR 1=1 --", qty: 1 },
  });
  assert.equal(res.statusCode, 404);
  assert.equal(res.json().error, 'sku_not_found');
  const after = (await pool.query('SELECT count(*)::int AS n FROM p03.orders')).rows[0].n;
  assert.equal(after, before);
});

test('A10：非法 ID 404，畸形 JSON 与空 JSON 400，错误体带 request_id', async () => {
  const badId = await app.inject({ method: 'GET', url: '/orders/not-a-number', headers: API });
  assert.equal(badId.statusCode, 404);

  const badJson = await app.inject({
    method: 'POST',
    url: '/orders',
    headers: { ...API, 'content-type': 'application/json' },
    payload: '{"sku":',
  });
  assert.equal(badJson.statusCode, 400);
  assert.ok(badJson.json().request_id);

  const empty = await app.inject({ method: 'POST', url: '/orders/1/pay', headers: { ...API, 'content-type': 'application/json' }, payload: '' });
  assert.equal(empty.statusCode, 400);
});

test('A02/A09：认证失败写告警日志，且不记录密钥原文', async () => {
  const lines = [];
  const logged = buildApp({ pool, logger: { level: 'warn', stream: { write: (line) => lines.push(line) } } });
  await logged.ready();
  try {
    const res = await logged.inject({ method: 'GET', url: '/orders/1', headers: { 'x-api-key': 'wrong-secret-value', 'x-user-id': 'alice' } });
    assert.equal(res.statusCode, 401);
  } finally {
    await logged.close();
  }
  const joined = lines.join('');
  assert.match(joined, /auth_failed/);
  assert.match(joined, /request_id/);
  assert.ok(!joined.includes('wrong-secret-value'));
});
