// 验证 compose 的 app/worker 拆分：app 只提供 HTTP（MQ_MODE=off），worker 独立发布 Outbox 并消费。
import { spawn } from 'node:child_process';
import { createPool } from '../src/db.mjs';

const PORT = 8794;
const WORKER_PORT = 8797;
const base = `http://127.0.0.1:${PORT}`;
const headers = { 'content-type': 'application/json', 'x-api-key': 'test-key', 'x-user-id': 'worker-split' };
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const pool = createPool();

function start(args, env) {
  const child = spawn(process.execPath, args, { env: { ...process.env, ...env }, stdio: ['ignore', 'pipe', 'pipe'] });
  let log = '';
  child.stdout.on('data', (d) => { log += d; });
  child.stderr.on('data', (d) => { log += d; });
  return { child, getLog: () => log };
}

const app = start(['src/server.js'], { PORT: String(PORT), MQ_MODE: 'off' });
const worker = start(['src/worker.js'], { WORKER_PORT: String(WORKER_PORT) });

async function waitUrl(url, label) {
  for (let i = 0; i < 80; i++) {
    try {
      const res = await fetch(url);
      if (res.ok) return res;
    } catch {}
    await sleep(250);
  }
  throw new Error(`${label} not ready`);
}

try {
  await waitUrl(`${base}/health`, 'app');
  const health = await (await waitUrl(`http://127.0.0.1:${WORKER_PORT}/health`, 'worker')).json();
  if (health.mode !== 'mq') throw new Error(`worker mode expected mq, got ${health.mode}`);

  await pool.query("INSERT INTO p03.products (sku, title, price_cents, active) VALUES ('worker-sku', 'Worker 商品', 100, true) ON CONFLICT (sku) DO UPDATE SET active = true");
  await pool.query("INSERT INTO p03.inventory (sku, title, unit_price, stock) VALUES ('worker-sku', 'Worker 商品', 100, 5) ON CONFLICT (sku) DO UPDATE SET stock = GREATEST(p03.inventory.stock, 5)");

  const created = await fetch(`${base}/orders`, {
    method: 'POST',
    headers: { ...headers, 'idempotency-key': `worker-split-${Date.now()}` },
    body: JSON.stringify({ sku: 'worker-sku', qty: 1 }),
  });
  const order = await created.json();
  if (created.status !== 201) throw new Error(`create failed ${created.status} ${JSON.stringify(order)}`);
  const paid = await fetch(`${base}/orders/${order.id}/pay`, { method: 'POST', headers, body: '{}' });
  if (paid.status !== 200) throw new Error(`pay failed ${paid.status}`);
  const eventId = `pay-${(await paid.json()).payments.at(-1).id}`;

  let sent = false;
  let notified = false;
  for (let i = 0; i < 100; i++) {
    const outbox = (await pool.query('SELECT status FROM p03.outbox WHERE event_id = $1', [eventId])).rows[0];
    const note = (await pool.query('SELECT 1 FROM p03.notifications WHERE event_id = $1', [eventId])).rows[0];
    sent = outbox?.status === 'sent';
    notified = Boolean(note);
    if (sent && notified) break;
    await sleep(100);
  }
  if (!sent || !notified) {
    throw new Error(`worker split incomplete sent=${sent} notified=${notified}\nAPP:\n${app.getLog()}\nWORKER:\n${worker.getLog()}`);
  }
  console.log(`stage=worker_split app_mq=off worker_mode=${health.mode} order=${order.id} outbox=sent notification=true`);
  console.log('P03 WORKER SPLIT PASS');
} catch (error) {
  console.error(`P03 WORKER SPLIT FAIL: ${error.message}`);
  process.exitCode = 1;
} finally {
  app.child.kill('SIGTERM');
  worker.child.kill('SIGTERM');
  await sleep(400);
  await pool.end();
}
