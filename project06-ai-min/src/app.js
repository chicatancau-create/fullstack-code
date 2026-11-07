import Fastify from 'fastify';
import crypto from 'node:crypto';
import { createLlm, LlmError } from './llm.js';

export const PROMPT_VERSION = 'v1';
const SYSTEM_PROMPT = '你是订单助手。只输出 JSON：{answer,citations,confidence,refused,tool_call?}。没有依据时 refused=true。';
const ORDERS = { 'A-100': { status: 'paid', amount: 299 }, 'B-200': { status: 'cancelled', amount: 99 } };

function parseModelOutput(text) {
  let value;
  try { value = JSON.parse(text); } catch { throw new LlmError('invalid_json', 502); }
  if (!value || typeof value.answer !== 'string' || !Array.isArray(value.citations)) throw new LlmError('invalid_shape', 502);
  if (typeof value.confidence !== 'number' || value.confidence < 0 || value.confidence > 1) throw new LlmError('invalid_confidence', 502);
  if (typeof value.refused !== 'boolean') throw new LlmError('invalid_refusal', 502);
  if (value.tool_call && (typeof value.tool_call.name !== 'string' || typeof value.tool_call.arguments !== 'object')) throw new LlmError('invalid_tool_call', 502);
  return value;
}

export function buildApp({ apiKey = process.env.LLM_API_KEY, baseUrl = process.env.LLM_BASE_URL || 'https://api.openai.com', model = process.env.LLM_MODEL || 'gpt-4o-mini', fetchImpl, timeoutMs = 2000 } = {}) {
  const app = Fastify({ logger: false, bodyLimit: 16384, genReqId: () => crypto.randomUUID() });
  const complete = createLlm({ baseUrl, apiKey, model, fetchImpl, timeoutMs });

  app.get('/health', async () => ({ status: 'ok', configured: Boolean(apiKey), prompt_version: PROMPT_VERSION }));
  app.get('/prompt', async () => ({ version: PROMPT_VERSION, system: SYSTEM_PROMPT }));

  app.post('/chat', async (request, reply) => {
    const { question } = request.body || {};
    if (typeof question !== 'string' || question.trim().length < 2 || question.length > 500) {
      return reply.code(400).send({ error: 'invalid_question' });
    }
    if (!apiKey) return reply.code(503).send({ error: 'llm_not_configured' });
    const messages = [{ role: 'system', content: SYSTEM_PROMPT }, { role: 'user', content: question }];
    let totalAttempts = 0;
    let lastUsage = null;
    try {
      let result = await complete(messages, { promptVersion: PROMPT_VERSION });
      totalAttempts += result.attempts; lastUsage = result.usage || lastUsage;
      let output = parseModelOutput(result.content);
      let toolResult = null;
      if (output.tool_call && !output.refused) {
        if (output.tool_call.name !== 'lookup_order') throw new LlmError('unknown_tool', 400);
        const orderId = String(output.tool_call.arguments.order_id || '');
        const order = ORDERS[orderId];
        toolResult = order ? { order_id: orderId, ...order } : { order_id: orderId, error: 'not_found' };
        messages.push({ role: 'assistant', content: result.content });
        messages.push({ role: 'tool', content: JSON.stringify(toolResult) });
        result = await complete(messages, { promptVersion: PROMPT_VERSION });
        totalAttempts += result.attempts; lastUsage = result.usage || lastUsage;
        output = parseModelOutput(result.content);
      }
      const cost = lastUsage
        ? Number(((lastUsage.prompt_tokens || 0) * 0.00000015 + (lastUsage.completion_tokens || 0) * 0.0000006).toFixed(8))
        : Number((((JSON.stringify(messages).length + result.content.length) / 4) * 0.0000003).toFixed(8));
      return {
        answer: output.answer, citations: output.citations, confidence: output.confidence, refused: output.refused,
        tool_result: toolResult, prompt_version: PROMPT_VERSION, model, attempts: totalAttempts, cost_usd: cost,
      };
    } catch (error) {
      const status = error instanceof LlmError ? error.status : 502;
      return reply.code(status).send({ error: error.message || 'llm_error' });
    }
  });
  return app;
}
