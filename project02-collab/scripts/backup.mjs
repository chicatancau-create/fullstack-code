import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { config, createPool } from '../src/db.mjs';

const pool = createPool();
const bin = process.env.PGBIN || 'D:/PostgreSQL/18/bin';
const dump = path.resolve('evidence/p02-dump.sql');
fs.mkdirSync('evidence', { recursive: true });
fs.rmSync(dump, { force: true });
const env = { ...process.env, PGHOST: config.host, PGPORT: String(config.port), PGUSER: config.user, PGDATABASE: config.database, PGPASSWORD: config.password };

try {
  const before = await pool.query('SELECT count(*)::int AS n FROM p02.users');
  if (before.rows[0].n === 0) {
    await pool.query("INSERT INTO p02.users (email, password_hash) VALUES ('backup@example.com', 'x:y') ON CONFLICT DO NOTHING");
  }
  execFileSync(path.join(bin, 'pg_dump.exe'), ['--schema=p02', '--no-owner', '--no-privileges', '-f', dump], { env, stdio: 'pipe' });
  execFileSync(path.join(bin, 'psql.exe'), ['-v', 'ON_ERROR_STOP=1', '-c', 'DROP SCHEMA p02 CASCADE'], { env, stdio: 'pipe' });
  execFileSync(path.join(bin, 'psql.exe'), ['-v', 'ON_ERROR_STOP=1', '-f', dump], { env, stdio: 'pipe' });
  const users = await pool.query('SELECT count(*)::int AS n FROM p02.users');
  const tables = await pool.query("SELECT count(*)::int AS n FROM pg_tables WHERE schemaname='p02'");
  console.log(`dump_bytes=${fs.statSync(dump).size} users=${users.rows[0].n} tables=${tables.rows[0].n}`);
  if (users.rows[0].n < 1 || tables.rows[0].n < 5) {
    console.error('RESTORE FAIL');
    process.exitCode = 1;
  } else {
    console.log('RESTORE PASS');
  }
} finally {
  await pool.end();
}
