// 运行时 MQ 联通验证：真实启动 src/server.js，下单->支付，确认发布器把 outbox 置 sent 且消费者写入通知。
// 消耗本地合成数据，不触碰生产；失败时打印服务日志尾部并以非零退出。
import { spawn } from 'node:child_process';
import { createPool } from '../src/db.mjs';

const PORT = Number(process.env.MQ_RUNTIME_PORT || 8797);
const BASE = `http://127.0.0.1:${PORT}`;
const headers = { 'content-type': 'application/json', 'x-api-key': process.env.P03_API_KEY || 'test-key', 'x-user-id': 'mq-runtime' };
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const pool = createPool();
const server = spawn(process.execPath, ['src/server.js'], {
  env: { ...process.env, PORT: String(PORT) },
  stdio: ['ignore', 'pipe', 'pipe'],
});
let log = '';
server.stdout.on('data', (d) => { log += d; });
server.stderr.on('data', (d) => { log += d; });

async function waitHealthy() {
  for (let i = 0; i < 80; i++) {
    try {
      const res = await fetch(`${BASE}/health`);
      if (res.ok) return;
    } catch {}
    await sleep(250);
  }
  throw new Error('server did not become healthy');
}

async function waitFor(check, label, timeout = 10000) {
  const end = Date.now() + timeout;
  while (Date.now() < end) {
    if (await check()) return;
    await sleep(100);
  }
  throw new Error(`timeout waiting for ${label}`);
}

try {
  await waitHealthy();
  await pool.query(
    `INSERT INTO p03.products (sku, title, price_cents, active) VALUES ('mq-runtime-sku', 'MQ 运行期商品', 100, true)
     ON CONFLICT (sku) DO UPDATE SET active = true`,
  );
  await pool.query(
    `INSERT INTO p03.inventory (sku, title, unit_price, stock) VALUES ('mq-runtime-sku', 'MQ 运行期商品', 100, 5)
     ON CONFLICT (sku) DO UPDATE SET stock = GREATEST(p03.inventory.stock, 5)`,
  );

  const created = await fetch(`${BASE}/orders`, {
    method: 'POST',
    headers: { ...headers, 'idempotency-key': `mq-runtime-${Date.now()}` },
    body: JSON.stringify({ sku: 'mq-runtime-sku', qty: 1 }),
  });
  const order = await created.json();
  if (created.status !== 201) throw new Error(`create failed ${created.status} ${JSON.stringify(order)}`);

  const paid = await fetch(`${BASE}/orders/${order.id}/pay`, { method: 'POST', headers, body: '{}' });
  const paidBody = await paid.json();
  if (paid.status !== 200) throw new Error(`pay failed ${paid.status} ${JSON.stringify(paidBody)}`);
  const eventId = `pay-${paidBody.payments.at(-1).id}`;

  await waitFor(async () => {
    const row = (await pool.query('SELECT status FROM p03.outbox WHERE event_id = $1', [eventId])).rows[0];
    return row?.status === 'sent';
  }, 'outbox sent');
  await waitFor(async () => {
    const row = (await pool.query('SELECT 1 FROM p03.notifications WHERE event_id = $1', [eventId])).rows[0];
    return Boolean(row);
  }, 'notification');

  const outbox = (await pool.query('SELECT status, sent_at FROM p03.outbox WHERE event_id = $1', [eventId])).rows[0];
  const notification = (await pool.query('SELECT order_id, message FROM p03.notifications WHERE event_id = $1', [eventId])).rows[0];
  console.log(`stage=runtime_mq order=${order.id} event=${eventId} outbox=${outbox.status} notification_order=${notification.order_id}`);
  console.log('PROJECT03 MQ RUNTIME PASS');
} catch (error) {
  console.error(`PROJECT03 MQ RUNTIME FAIL: ${error.message}`);
  console.error(log.split('\n').slice(-15).join('\n'));
  process.exitCode = 1;
} finally {
  server.kill('SIGTERM');
  await sleep(300);
  await pool.end();
}
