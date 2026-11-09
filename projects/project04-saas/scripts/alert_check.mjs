import assert from 'node:assert/strict';
import { createPool } from '../src/db.mjs';
import { buildApp } from '../src/app.js';

const pool = createPool();
const app = buildApp({ pool });
await app.listen({ host: '127.0.0.1', port: 0 });
const base = `http://127.0.0.1:${app.server.address().port}`;
const email = `alert-${Date.now()}@example.com`;
const post = (path, body, token) => fetch(`${base}${path}`, { method: 'POST', headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) }, body: JSON.stringify(body) });
await post('/auth/register', { email, password: 'correct-horse-1', name: 'Alert' });
const { token } = await (await post('/auth/login', { email, password: 'correct-horse-1' })).json();
for (let i = 0; i < 5; i++) await fetch(`${base}/health`);
for (let i = 0; i < 10; i++) await fetch(`${base}/missing`);
await pool.query('TRUNCATE p04.job_notifications, p04.worker_inbox, p04.job_dead_letter, p04.job_results, p04.jobs RESTART IDENTITY CASCADE');
for (let i = 1; i <= 60; i++) {
  await pool.query(
    `INSERT INTO p04.jobs (tenant_id, kind, dedupe_key, payload, priority)
     VALUES ($1, 'followup.reminder', $2, '{}'::jsonb, 0)
     ON CONFLICT (tenant_id, dedupe_key) DO NOTHING`,
    [99, `alert-${i}`],
  );
}

const response = await fetch(`${base}/metrics`, { headers: { authorization: `Bearer ${token}` } });
const text = await response.text();
const total = [...text.matchAll(/p04_http_requests_total\{[^}]+\} (\d+)/g)].reduce((sum, m) => sum + Number(m[1]), 0);
const errors = [...text.matchAll(/p04_http_requests_total\{[^}]*status="(4\d\d|5\d\d)"[^}]*\} (\d+)/g)].reduce((sum, m) => sum + Number(m[2]), 0);
const pending = Number(text.match(/p04_jobs_pending (\d+)/)?.[1]);
const ratio = errors / total;
const highError = ratio > 0.2;
const backlog = pending > 50;
console.log(`http_total=${total} errors=${errors} error_ratio=${ratio.toFixed(2)}`);
console.log(`jobs_pending=${pending}`);
console.log(`${highError ? 'ALERT' : 'OK'} HighErrorRate (${(ratio * 100).toFixed(0)}% > 20%)`);
console.log(`${backlog ? 'ALERT' : 'OK'} JobBacklog (${pending} > 50)`);
assert.equal(highError, true);
assert.equal(backlog, true);
console.log('ALERTS PASS');
await app.close();
await pool.end();
