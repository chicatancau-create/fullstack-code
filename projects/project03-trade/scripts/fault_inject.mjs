// 故障注入：DB 不可用/恢复、RabbitMQ 不可用时的降级（DB Worker 接管）。
// 只用本地合成数据；失败以非零退出并打印现场。
import { spawn } from 'node:child_process';
import pg from 'pg';
import { createPool } from '../src/db.mjs';
import { buildApp } from '../src/app.js';

const goodPool = createPool();
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const API = { 'x-api-key': process.env.P03_API_KEY || 'test-key', 'x-user-id': 'fault-user' };
let failed = false;

function report(line) {
  console.log(line);
}

async function waitHealthy(base) {
  for (let i = 0; i < 60; i++) {
    try {
      if ((await fetch(`${base}/health`)).ok) return;
    } catch {}
    await sleep(250);
  }
  throw new Error('server not healthy');
}

// 1) DB 不可达：就绪 503，写入 500 且携带 request_id，不产生半提交订单
{
  const badPool = new pg.Pool({ host: '127.0.0.1', port: 5999, user: 'study', password: process.env.PGPASSWORD, database: 'study_lab', connectionTimeoutMillis: 300 });
  const app = buildApp({ pool: badPool });
  await app.ready();
  const before = (await goodPool.query('SELECT count(*)::int AS n FROM p03.orders')).rows[0].n;
  try {
    const ready = await app.inject({ method: 'GET', url: '/ready' });
    if (ready.statusCode !== 503) throw new Error(`ready expected 503, got ${ready.statusCode}`);
    const write = await app.inject({ method: 'POST', url: '/orders', headers: { ...API, 'idempotency-key': 'db-down-1' }, payload: { sku: 'fault-sku', qty: 1 } });
    if (write.statusCode !== 500) throw new Error(`write expected 500, got ${write.statusCode}`);
    const body = write.json();
    if (body.error !== 'internal_error' || !body.request_id) throw new Error('500 body missing internal_error/request_id');
    const after = (await goodPool.query('SELECT count(*)::int AS n FROM p03.orders')).rows[0].n;
    if (after !== before) throw new Error(`order leaked while DB down: ${before} -> ${after}`);
    report('stage=db_down ready=503 write=500 request_id=present no_partial_order=true');
  } finally {
    await app.close();
    await badPool.end();
  }
}

// 2) DB 恢复：就绪 200 且能正常下单
{
  await goodPool.query("INSERT INTO p03.products (sku, title, price_cents, active) VALUES ('fault-sku', '故障演练商品', 100, true) ON CONFLICT (sku) DO UPDATE SET active = true");
  await goodPool.query("INSERT INTO p03.inventory (sku, title, unit_price, stock) VALUES ('fault-sku', '故障演练商品', 100, 5) ON CONFLICT (sku) DO UPDATE SET stock = GREATEST(p03.inventory.stock, 5)");
  const app = buildApp({ pool: goodPool });
  await app.ready();
  try {
    const ready = await app.inject({ method: 'GET', url: '/ready' });
    if (ready.statusCode !== 200) throw new Error(`ready expected 200 after recovery, got ${ready.statusCode}`);
    const created = await app.inject({ method: 'POST', url: '/orders', headers: { ...API, 'idempotency-key': `db-recovered-${Date.now()}` }, payload: { sku: 'fault-sku', qty: 1 } });
    if (created.statusCode !== 201) throw new Error(`create after recovery expected 201, got ${created.statusCode}`);
    report('stage=db_recovered ready=200 create=201');
  } finally {
    await app.close();
  }
}

// 3) RabbitMQ 不可用：服务仍启动并降级到 DB Worker，支付后通知落库
{
  const PORT = 8795;
  const base = `http://127.0.0.1:${PORT}`;
  const server = spawn(process.execPath, ['src/server.js'], {
    env: { ...process.env, PORT: String(PORT), AMQP_URL: 'amqp://guest:guest@127.0.0.1:5998' },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  let log = '';
  server.stdout.on('data', (d) => { log += d; });
  server.stderr.on('data', (d) => { log += d; });
  try {
    await waitHealthy(base);
    if (!log.includes('falling back to DB worker')) throw new Error('fallback log missing');
    const created = await fetch(`${base}/orders`, {
      method: 'POST',
      headers: { ...API, 'content-type': 'application/json', 'idempotency-key': `mq-down-${Date.now()}` },
      body: JSON.stringify({ sku: 'fault-sku', qty: 1 }),
    });
    const order = await created.json();
    if (created.status !== 201) throw new Error(`mq-down create expected 201, got ${created.status}`);
    const paid = await fetch(`${base}/orders/${order.id}/pay`, { method: 'POST', headers: { ...API, 'content-type': 'application/json' }, body: '{}' });
    if (paid.status !== 200) throw new Error(`mq-down pay expected 200, got ${paid.status}`);
    const eventId = `pay-${(await paid.json()).payments.at(-1).id}`;
    let notified = false;
    for (let i = 0; i < 100; i++) {
      const row = (await goodPool.query('SELECT 1 FROM p03.notifications WHERE event_id = $1', [eventId])).rows[0];
      if (row) { notified = true; break; }
      await sleep(100);
    }
    if (!notified) throw new Error('worker fallback did not produce notification');
    report(`stage=mq_down health=200 fallback=db_worker notification=${eventId}`);
  } finally {
    server.kill('SIGTERM');
    await sleep(400);
  }
}

if (failed) process.exit(1);
console.log('FAULT INJECTION PASS');
await goodPool.end();
