import Fastify from 'fastify';
import { createPool } from './db.mjs';
import { processJobs } from './jobs.mjs';

export function createWorkerRuntime(options = {}) {
  const pool = options.pool || createPool();
  const app = Fastify({ logger: false });
  const state = { last: null, running: true, timer: null, closed: false };
  app.get('/health', async () => ({ status: 'ok', last: state.last }));
  app.get('/ready', async (_request, reply) => {
    if (state.closed) return reply.code(503).send({ status: 'unavailable', reason: 'shutting_down' });
    try { await pool.query('SELECT 1'); return { status: 'ready' }; } catch { return reply.code(503).send({ status: 'unavailable' }); }
  });

  const interval = options.interval ?? Number(process.env.JOB_INTERVAL_MS || 500);
  const batchSize = options.batchSize ?? Number(process.env.JOB_BATCH || 5);

  async function loop() {
    if (!state.running) return;
    try { state.last = await processJobs(pool, { limit: batchSize }); }
    catch (error) { state.last = { error: error.message }; }
    if (state.running) state.timer = setTimeout(loop, interval);
  }

  async function start(port = Number(process.env.WORKER_PORT || 8798)) {
    await app.listen({ port, host: '0.0.0.0' });
    void loop();
    return app.server.address();
  }

  async function shutdown() {
    if (state.closed) return;
    state.closed = true;
    state.running = false;
    clearTimeout(state.timer);
    await app.close();
    await pool.end();
  }

  return { app, pool, state, start, shutdown };
}
