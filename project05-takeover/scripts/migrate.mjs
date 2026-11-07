import fs from 'node:fs';
import path from 'node:path';
import { createPool } from '../src/db.mjs';

const pool = createPool();
try {
  const sql = fs.readFileSync(path.resolve('migrations/001_init.sql'), 'utf8');
  await pool.query(sql);
  const tables = await pool.query("SELECT tablename FROM pg_tables WHERE schemaname='p02' ORDER BY tablename");
  console.log(`migrated tables=${tables.rows.map((r) => r.tablename).join(',')}`);
} finally {
  await pool.end();
}
