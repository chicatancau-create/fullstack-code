import test, { before, after } from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import http from 'node:http';
import { createPool } from '../src/db.mjs';
import { buildApp } from '../src/app.js';

let pool;
before(async () => { pool = createPool(4); });
after(async () => { await pool.end(); });

test('worker 运行时：就绪探针可用，shutdown 后端口关闭且幂等', async () => {
  const { createWorkerRuntime } = await import('../src/worker_runtime.mjs');
  const runtime = createWorkerRuntime({ pool: createPool(2), interval: 50, batchSize: 1 });
  const address = await runtime.start(0);
  const base = `http://127.0.0.1:${address.port}`;
  assert.equal((await fetch(`${base}/health`)).status, 200);
  assert.equal((await fetch(`${base}/ready`)).status, 200);
  await runtime.shutdown();
  await assert.rejects(fetch(`${base}/ready`), '关闭后端口应不再应答');
  await runtime.shutdown();
  assert.equal(runtime.state.closed, true);
});

test('SIGTERM 处理链：子进程收到信号事件后优雅退出，退出码 0', async () => {
  const script = [
    "import { createWorkerRuntime } from './src/worker_runtime.mjs';",
    'const r = createWorkerRuntime({ interval: 50, batchSize: 1 });',
    'await r.start(0);',
    "for (const s of ['SIGINT','SIGTERM']) process.on(s, async () => { await r.shutdown(); console.log('graceful-close:'+s); process.exit(0); });",
    "console.log('ready');",
    'await new Promise((res) => setTimeout(res, 300));',
    "process.emit('SIGTERM');",
    'await new Promise((res) => setTimeout(res, 5000));',
  ].join('\n');
  const child = spawn(process.execPath, ['--input-type=module', '-e', script], { stdio: ['ignore', 'pipe', 'pipe'] });
  let out = '';
  child.stdout.on('data', (chunk) => { out += chunk; });
  child.stderr.on('data', (chunk) => { out += chunk; });
  const code = await new Promise((resolve) => child.on('exit', resolve));
  assert.equal(code, 0, out);
  assert.match(out, /graceful-close:SIGTERM/);
  assert.match(out, /ready/);
});

test('SSE 通知通道：订阅后写入 job_notifications 可收到带 id 的事件', async () => {
  const app = buildApp({ pool });
  await app.ready();
  await app.listen({ port: 0, host: '127.0.0.1' });
  const port = app.server.address().port;
  let request;
  try {
    await pool.query('TRUNCATE p04.users, p04.tenants, p04.jobs, p04.job_notifications RESTART IDENTITY CASCADE');
    await app.inject({ method: 'POST', url: '/auth/register', payload: { email: 'sse@example.com', name: 'SSE', password: 'correct-horse-1' } });
    const token = (await app.inject({ method: 'POST', url: '/auth/login', payload: { email: 'sse@example.com', password: 'correct-horse-1' } })).json().token;
    const tenant = (await app.inject({
      method: 'POST',
      url: '/tenants',
      headers: { authorization: `Bearer ${token}` },
      payload: { name: 'SSE 租户', plan: 'team' },
    })).json();

    let buffer = '';
    let statusCode = 0;
    let contentType = '';
    const connected = new Promise((resolve, reject) => {
      request = http.get({
        host: '127.0.0.1',
        port,
        path: `/tenants/${tenant.id}/notifications/stream`,
        headers: { authorization: `Bearer ${token}` },
      }, (response) => {
        statusCode = response.statusCode;
        contentType = response.headers['content-type'] || '';
        response.setEncoding('utf8');
        response.on('data', (chunk) => {
          buffer += chunk;
          resolve();
        });
      });
      request.setTimeout(8000, () => request.destroy(new Error('SSE 建立连接超时')));
      request.on('error', reject);
    });

    await connected;
    assert.equal(statusCode, 200);
    assert.match(contentType, /text\/event-stream/);

    await pool.query(
      `INSERT INTO p04.jobs (tenant_id, kind, dedupe_key, payload, run_at, priority)
       VALUES ($1, 'reminder', 'sse-smoke', '{}'::jsonb, now(), 0)`,
      [tenant.id],
    );
    await pool.query(
      `INSERT INTO p04.job_notifications (job_id, tenant_id, message)
       SELECT id, $1, $2 FROM p04.jobs WHERE tenant_id = $1 AND dedupe_key = 'sse-smoke'`,
      [tenant.id, 'SSE 冒烟事件'],
    );

    const deadline = Date.now() + 8000;
    while (Date.now() < deadline && !/data: .*SSE 冒烟事件/.test(buffer)) {
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
    assert.match(buffer, /: connected/);
    assert.match(buffer, /id: \d+/);
    assert.match(buffer, /data: .*SSE 冒烟事件/);
  } finally {
    if (request) request.destroy();
    await app.close();
  }
});
