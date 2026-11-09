import http from 'node:http';
import { getLlama, LlamaChatSession } from 'node-llama-cpp';

export async function startLocalLlm({ modelPath = process.env.MODEL_PATH || 'D:/Models/qwen2.5-0.5b-instruct-q4_k_m.gguf', port = 0 } = {}) {
  const llama = await getLlama();
  const model = await llama.loadModel({ modelPath });
  const grammar = await llama.createGrammarForJsonSchema({
    type: 'object',
    properties: {
      answer: { type: 'string' },
      citations: { type: 'array', items: { type: 'string' } },
      confidence: { type: 'number', minimum: 0, maximum: 1 },
      refused: { type: 'boolean' },
    },
    required: ['answer', 'citations', 'confidence', 'refused'],
    additionalProperties: false,
  });
  const server = http.createServer(async (req, res) => {
    if (req.method === 'GET' && req.url === '/health') {
      console.error('LLM_RAW=' + content.replace(/\s+/g, ' ').slice(0, 500));
      res.writeHead(200, { 'content-type': 'application/json' });
      res.end('{"status":"ok"}');
      return;
    }
    let raw = '';
    for await (const chunk of req) raw += chunk;
    let body = {};
    try { body = JSON.parse(raw || '{}'); } catch { /* handled below */ }
    const system = body.messages?.find((m) => m.role === 'system')?.content || '';
    const user = body.messages?.filter((m) => m.role === 'user').at(-1)?.content || '';
    if (!user) {
      res.writeHead(400, { 'content-type': 'application/json' });
      res.end('{"error":"missing_user"}');
      return;
    }
    const context = await model.createContext({ contextSize: 512 });
    const session = new LlamaChatSession({ contextSequence: context.getSequence() });
    try {
      const content = await session.prompt(`${system}\n\n用户：${user}`, { grammar, maxTokens: 180, temperature: 0 });
      console.error('LLM_RAW=' + content.replace(/\s+/g, ' ').slice(0, 500));
      res.writeHead(200, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ choices: [{ message: { content } }], usage: null }));
    } catch (error) {
      res.writeHead(500, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ error: error.message }));
    } finally {
      await context.dispose();
    }
  });
  await new Promise((resolve) => server.listen(port, '127.0.0.1', resolve));
  return {
    url: `http://127.0.0.1:${server.address().port}`,
    model: modelPath,
    close: async () => { await new Promise((r) => server.close(r)); await model.dispose(); await llama.dispose(); },
  };
}
