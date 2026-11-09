import { createPool } from './db.mjs';
import { buildApp } from './app.js';
import { startWorker } from './outboxWorker.mjs';
import { connectMq, publishPending, startConsumer } from './mq.mjs';

const pool = createPool();
const app = buildApp({ pool, logger: true });
const port = Number(process.env.PORT || 8796);

await app.listen({ host: process.env.HOST || '127.0.0.1', port });
console.log(`project03 listening on http://${process.env.HOST || '127.0.0.1'}:${port}`);

let mq = null;
let worker = null;
let publishTimer = null;

if (process.env.MQ_MODE !== 'off') {
  try {
    mq = await connectMq(process.env.AMQP_URL);
    await startConsumer(pool, mq.channel);
    publishTimer = setInterval(() => {
      publishPending(pool, mq.channel).catch((error) => {
        console.error(`outbox publish failed: ${error.message}`);
      });
    }, 500);
    console.log('MQ runtime: publisher + consumer started');
  } catch (error) {
    console.warn(`MQ unavailable (${error.message}); falling back to DB worker`);
    worker = await startWorker({ pool });
  }
}

async function shutdown(signal) {
  console.log(`${signal} received, closing`);
  if (publishTimer) clearInterval(publishTimer);
  if (mq) {
    await mq.channel.close().catch(() => {});
    await mq.connection.close().catch(() => {});
  }
  if (worker) await worker.stop().catch(() => {});
  await app.close();
  await pool.end();
  process.exit(0);
}
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
