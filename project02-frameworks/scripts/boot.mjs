import { createRequire } from 'node:module';
import { createExpressApp } from '../express/app.mjs';

const require = createRequire(import.meta.url);
const { createNestApp } = require('../dist/main.js');

async function measure(label, factory) {
  const samples = [];
  for (let i = 0; i < 5; i++) {
    const started = performance.now();
    const app = await factory();
    const maybeServer = app.listen(0, '127.0.0.1');
    const server = maybeServer && typeof maybeServer.then === 'function' ? await maybeServer : maybeServer;
    if (server && !server.listening) await new Promise((resolve) => server.once('listening', resolve));
    const ready = performance.now();
    if (typeof app.close === 'function' && typeof app.getHttpServer === 'function') {
      await app.close();
    } else {
      await new Promise((resolve) => server.close(resolve));
    }
    samples.push({ listen_ms: +(ready - started).toFixed(2), close_ms: +(performance.now() - ready).toFixed(2) });
  }
  const listen = samples.map((s) => s.listen_ms).sort((a, b) => a - b);
  const close = samples.map((s) => s.close_ms).sort((a, b) => a - b);
  console.log(`${label} listen_min=${listen[0]}ms listen_median=${listen[2]}ms close_median=${close[2]}ms samples=${JSON.stringify(samples)}`);
}

await measure('express', async () => createExpressApp());
await measure('nest', async () => createNestApp());
