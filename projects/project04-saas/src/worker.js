import { createWorkerRuntime } from './worker_runtime.mjs';

const runtime = createWorkerRuntime();
await runtime.start();
for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    await runtime.shutdown();
    process.exit(0);
  });
}
