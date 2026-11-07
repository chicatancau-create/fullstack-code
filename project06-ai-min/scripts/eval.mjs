import { buildApp } from '../src/app.js';
import { startMock } from '../tests/mock-llm.mjs';

const cases = [
  { question: 'valid question', expect: (b) => b.answer.includes('已支付') && !b.refused },
  { question: 'tool lookup', expect: (b) => b.tool_result?.status === 'paid' },
  { question: 'refuse this', expect: (b) => b.refused === true },
  { question: 'retry please', expect: (b) => b.attempts === 2 },
  { question: 'bad output', expectHttp: 502 },
];
const mock = await startMock();
const app = buildApp({ apiKey: 'eval-key', baseUrl: mock.url, model: 'mock-1', timeoutMs: 150 });
let pass = 0;
for (const item of cases) {
  const response = await app.inject({ method: 'POST', url: '/chat', payload: { question: item.question } });
  const body = response.json();
  const ok = item.expectHttp ? response.statusCode === item.expectHttp : response.statusCode === 200 && item.expect(body);
  if (ok) pass++;
  console.log(`${ok ? 'PASS' : 'FAIL'} ${item.question} status=${response.statusCode}`);
}
console.log(`golden_set=${cases.length} pass=${pass} rate=${(pass / cases.length * 100).toFixed(0)}%`);
console.log(pass === cases.length ? 'EVAL PASS' : 'EVAL FAIL');
await app.close(); await mock.close();
process.exit(pass === cases.length ? 0 : 1);
