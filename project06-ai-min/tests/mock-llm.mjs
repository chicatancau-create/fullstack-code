import http from 'node:http';

const VALID = { answer: '订单 A-100 已支付', citations: ['orders'], confidence: 0.9, refused: false };
const TOOL = { answer: '需要查询订单', citations: [], confidence: 0.5, refused: false, tool_call: { name: 'lookup_order', arguments: { order_id: 'A-100' } } };
const FINAL = { answer: '订单 A-100 状态 paid，金额 299', citations: ['orders'], confidence: 0.95, refused: false };
const REFUSE = { answer: '没有依据，无法回答', citations: [], confidence: 0.1, refused: true };

export async function startMock() {
  const calls = [];
  const counters = {};
  const server = http.createServer(async (req, res) => {
    let raw = '';
    for await (const chunk of req) raw += chunk;
    const body = JSON.parse(raw || '{}');
    const question = body.messages?.find((m) => m.role === 'user')?.content || '';
    calls.push({ question, tools: body.messages?.some((m) => m.role === 'tool') });
    const count = (counters[question] = (counters[question] || 0) + 1);
    const send = (status, content) => {
      res.writeHead(status, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ choices: [{ message: { content } }], usage: { prompt_tokens: 100, completion_tokens: 50 } }));
    };
    if (question.includes('retry') && count === 1) { res.writeHead(429); res.end('{}'); return; }
    if (question.includes('timeout') && count === 1) { await new Promise((r) => setTimeout(r, 400)); send(200, JSON.stringify(VALID)); return; }
    if (question.includes('tool')) { send(200, JSON.stringify(count === 1 ? TOOL : FINAL)); return; }
    if (question.includes('refuse')) { send(200, JSON.stringify(REFUSE)); return; }
    if (question.includes('bad')) { send(200, 'not-json'); return; }
    send(200, JSON.stringify(VALID));
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  return { url: `http://127.0.0.1:${server.address().port}`, calls, close: () => new Promise((r) => server.close(r)) };
}
