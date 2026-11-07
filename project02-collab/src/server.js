import { buildApp } from './app.js';
import { createPool } from './db.mjs';

const pool = createPool();
const app = buildApp({ pool, logger: true });
const port = Number(process.env.PORT || 8795);

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    await app.close();
    await pool.end();
    process.exit(0);
  });
}

try {
  await app.listen({ port, host: '127.0.0.1' });
} catch (error) {
  app.log.error(error);
  await pool.end();
  process.exit(1);
}