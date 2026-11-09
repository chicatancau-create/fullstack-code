import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { createExpressApp } from '../express/app.mjs';

const require = createRequire(import.meta.url);
const { createNestApp } = require('../dist/main.js');

async function withServer(app, run) {
  const server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  const { port } = server.address();
  try {
    await run(`http://127.0.0.1:${port}`);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

async function assertContract(base) {
  const health = await fetch(`${base}/health`);
  assert.equal(health.status, 200);
  assert.deepEqual(await health.json(), { status: 'ok' });
  assert.equal(health.headers.get('x-content-type-options'), 'nosniff');

  const echo = await fetch(`${base}/echo`, {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ text: 'hello' }),
  });
  assert.equal(echo.status, 200);
  assert.deepEqual(await echo.json(), { text: 'hello' });

  const missing = await fetch(`${base}/echo`, {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({}),
  });
  assert.equal(missing.status, 400);
  assert.deepEqual(await missing.json(), { error: 'invalid' });

  const extra = await fetch(`${base}/echo`, {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ text: 'ok', admin: true }),
  });
  assert.equal(extra.status, 400);
  assert.deepEqual(await extra.json(), { error: 'invalid' });

  const tooLong = await fetch(`${base}/echo`, {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ text: 'x'.repeat(51) }),
  });
  assert.equal(tooLong.status, 400);

  const malformed = await fetch(`${base}/echo`, {
    method: 'POST', headers: { 'content-type': 'application/json' }, body: '{bad',
  });
  assert.equal(malformed.status, 400);
  assert.deepEqual(await malformed.json(), { error: 'invalid' });

  const syncBoom = await fetch(`${base}/boom`);
  assert.equal(syncBoom.status, 500);
  const syncBody = await syncBoom.text();
  assert.equal(syncBody, JSON.stringify({ error: 'internal_error' }));
  assert.ok(!syncBody.includes('sync boom'));

  const asyncBoom = await fetch(`${base}/async-boom`);
  assert.equal(asyncBoom.status, 500);
  assert.deepEqual(await asyncBoom.json(), { error: 'internal_error' });

  const notFound = await fetch(`${base}/missing`);
  assert.equal(notFound.status, 404);
  assert.deepEqual(await notFound.json(), { error: 'not_found' });

  const wrongMethod = await fetch(`${base}/health`, { method: 'DELETE' });
  assert.equal(wrongMethod.status, 404);
  assert.deepEqual(await wrongMethod.json(), { error: 'not_found' });
}

test('Express 5 满足共享契约', async () => {
  await withServer(createExpressApp(), assertContract);
});

test('NestJS 12 满足共享契约', async () => {
  const app = await createNestApp();
  await withServer(app.getHttpServer(), assertContract);
  await app.close();
});
