import test, { before, after } from 'node:test';
import assert from 'node:assert/strict';
import { buildApp } from '../src/app.js';
import { startMock } from './mock-llm.mjs';

let mock;
let app;
before(async () => {
  mock = await startMock();
  app = buildApp({ apiKey: 'test-key', baseUrl: mock.url, model: 'mock-1', timeoutMs: 150 });
  await app.ready();
});
after(async () => { await app.close(); await mock.close(); });

async function chat(question) {
  return app.inject({ method: 'POST', url: '/chat', payload: { question } });
}

test('health 与 prompt 版本', async () => {
  const health = await app.inject({ method: 'GET', url: '/health' });
  assert.equal(health.statusCode, 200);
  assert.equal(health.json().configured, true);
  assert.equal(health.json().prompt_version, 'v1');
  const prompt = await app.inject({ method: 'GET', url: '/prompt' });
  assert.equal(prompt.json().version, 'v1');
});

test('结构化输出与成本记录', async () => {
  const response = await chat('valid question');
  assert.equal(response.statusCode, 200);
  const body = response.json();
  assert.equal(body.answer, '订单 A-100 已支付');
  assert.equal(body.prompt_version, 'v1');
  assert.equal(body.attempts, 1);
  assert.ok(body.cost_usd > 0);
  assert.deepEqual(body.citations, ['orders']);
});

test('429 重试后成功', async () => {
  const response = await chat('retry please');
  assert.equal(response.statusCode, 200);
  assert.equal(response.json().attempts, 2);
});

test('超时重试后成功', async () => {
  const response = await chat('timeout please');
  assert.equal(response.statusCode, 200);
  assert.equal(response.json().attempts, 2);
});

test('工具调用后二次请求并返回工具结果', async () => {
  const response = await chat('tool lookup');
  assert.equal(response.statusCode, 200);
  const body = response.json();
  assert.equal(body.tool_result.status, 'paid');
  assert.equal(body.attempts, 2);
  assert.ok(mock.calls.some((c) => c.tools));
});

test('拒答不重试', async () => {
  const response = await chat('refuse this');
  assert.equal(response.statusCode, 200);
  assert.equal(response.json().refused, true);
});

test('非法模型输出返回 502', async () => {
  const response = await chat('bad output');
  assert.equal(response.statusCode, 502);
  assert.equal(response.json().error, 'invalid_json');
});

test('缺少密钥返回 503，参数非法返回 400', async () => {
  const noKey = buildApp({ apiKey: null, baseUrl: mock.url, fetchImpl: fetch });
  await noKey.ready();
  const response = await noKey.inject({ method: 'POST', url: '/chat', payload: { question: 'valid' } });
  assert.equal(response.statusCode, 503);
  const bad = await chat('x');
  assert.equal(bad.statusCode, 400);
  await noKey.close();
});
