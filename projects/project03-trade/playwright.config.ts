import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 45_000,
  workers: 1,
  use: { baseURL: 'http://localhost:4190', channel: process.env.CI ? undefined : 'msedge' },
  webServer: [
    {
      command: 'node scripts/migrate.mjs && node scripts/seed_e2e.mjs && node src/server.js',
      url: 'http://127.0.0.1:8796/health',
      reuseExistingServer: !process.env.CI,
      timeout: 60_000,
      env: {
        PGHOST: '127.0.0.1', PGPORT: '5432', PGUSER: 'study',
        PGPASSWORD: process.env.PGPASSWORD || '', PGDATABASE: process.env.PGDATABASE || 'study_lab',
        PORT: '8796', P03_API_KEY: 'test-key',
      },
    },
    { command: 'npm run dev --prefix web -- --port 4190 --strictPort', url: 'http://localhost:4190', reuseExistingServer: !process.env.CI, timeout: 60_000 },
  ],
});
