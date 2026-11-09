export class LlmError extends Error {
  constructor(message, status = 502) { super(message); this.status = status; }
}

export function createLlm({ baseUrl, apiKey, model, fetchImpl = fetch, timeoutMs = 2000, retryDelayMs = 100 }) {
  return async function complete(messages, { promptVersion }) {
    let lastError;
    for (let attempt = 1; attempt <= 2; attempt++) {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), timeoutMs);
      try {
        const response = await fetchImpl(`${baseUrl}/v1/chat/completions`, {
          method: 'POST',
          headers: { 'content-type': 'application/json', authorization: `Bearer ${apiKey}`, 'x-prompt-version': promptVersion },
          body: JSON.stringify({ model, messages, response_format: { type: 'json_object' }, temperature: 0 }),
          signal: controller.signal,
        });
        if (response.status === 429 || response.status >= 500) {
          lastError = new LlmError(`upstream_${response.status}`, 502);
          if (attempt < 2) { await new Promise((r) => setTimeout(r, retryDelayMs * attempt)); continue; }
          throw lastError;
        }
        if (!response.ok) throw new LlmError(`upstream_${response.status}`, 502);
        const body = await response.json();
        const content = body?.choices?.[0]?.message?.content;
        if (typeof content !== 'string') throw new LlmError('empty_completion', 502);
        return { content, usage: body.usage || null, attempts: attempt };
      } catch (error) {
        if (error.name === 'AbortError') {
          lastError = new LlmError('timeout', 504);
          if (attempt < 2) { await new Promise((r) => setTimeout(r, retryDelayMs * attempt)); continue; }
          throw lastError;
        }
        if (error instanceof LlmError) throw error;
        lastError = error;
        if (attempt < 2) { await new Promise((r) => setTimeout(r, retryDelayMs * attempt)); continue; }
        throw new LlmError('upstream_error', 502);
      } finally {
        clearTimeout(timer);
      }
    }
    throw lastError || new LlmError('upstream_error', 502);
  };
}
