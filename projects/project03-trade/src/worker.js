// 独立 MQ worker：发布 Outbox + 消费通知；RabbitMQ 不可用时降级 DB Worker。
// 自带 /health 供 compose 健康检查。
import http from 'node:http';
import { createPool } from './db.mjs';
import { connectMq, publishPending, startConsumer } from './mq.mjs';
import { startWorker } from './outboxWorker.mjs';

const pool = createPool();
const port = Number(process.env.WORKER_PORT || 8797);
let mq = null;
let dbWorker = null;
let timer = null;
let mode = 'starting';

try {
  mq = await connectMq(process.env.AMQP_URL);
  await startConsumer(pool, mq.channel);
  timer = setInterval(() => {
    publishPending(pool, mq.channel).catch((error) => {
      console.error(`worker publish failed: ${error.message}`);
    });
  }, 500);
  mode = 'mq';
  console.log('worker: MQ publisher + consumer started');
} catch (error) {
  console.warn(`worker: MQ unavailable (${error.message}); falling back to DB worker`);
  dbWorker = await startWorker({ pool });
  mode = 'db';
}

const health = http.createServer((request, response) => {
  if (request.url === '/health') {
    response.writeHead(200, { 'content-type': 'application/json' });
    response.end(JSON.stringify({ status: 'ok', mode }));
    return;
  }
  response.writeHead(404);
  response.end();
}).listen(port, '0.0.0.0', () => console.log(`worker: health on ${port}`));

async function shutdown(signal) {
  console.log(`worker: ${signal} received, closing`);
  if (timer) clearInterval(timer);
  health.close();
  if (mq) {
    await mq.channel.close().catch(() => {});
    await mq.connection.close().catch(() => {});
  }
  if (dbWorker) await dbWorker.stop().catch(() => {});
  await pool.end();
  process.exit(0);
}
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
