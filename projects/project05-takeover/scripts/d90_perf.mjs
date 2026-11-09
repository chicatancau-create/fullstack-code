import fs from 'node:fs';
import path from 'node:path';
import { createPool } from '../src/db.mjs';

if (!process.env.PGDATABASE || process.env.PGDATABASE === 'study_lab') {
  throw new Error('D90 必须使用独立库：PGDATABASE=study_lab_p05');
}

const pool = createPool();
const lines = [];
const log = (line = '') => {
  lines.push(line);
  console.log(line);
};

async function time(fn) {
  const start = process.hrtime.bigint();
  await fn();
  return Number(process.hrtime.bigint() - start) / 1e6;
}

try {
  await pool.query('DROP SCHEMA IF EXISTS p02 CASCADE');
  await pool.query(fs.readFileSync(path.resolve('migrations/001_init.sql'), 'utf8'));
  await pool.query(fs.readFileSync(path.resolve('migrations/002_task_events.sql'), 'utf8'));

  const owner = await pool.query(
    "INSERT INTO p02.users (email, password_hash) VALUES ('perf@example.com', 'x') RETURNING id",
  );
  const ws = await pool.query("INSERT INTO p02.workspaces (slug, name) VALUES ('perf', 'Perf') RETURNING id");
  await pool.query("INSERT INTO p02.members (workspace_id, user_id, role) VALUES ($1, $2, 'owner')", [ws.rows[0].id, owner.rows[0].id]);
  await pool.query(
    `INSERT INTO p02.tasks (workspace_id, title, status)
     SELECT $1, 'perf-' || g, CASE WHEN g % 2 = 0 THEN 'done' ELSE 'todo' END
     FROM generate_series(1, 10000) AS g`,
    [ws.rows[0].id],
  );

  const indexed = await pool.query(
    `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
     SELECT id, title, status FROM p02.tasks WHERE workspace_id = $1 AND status = 'done' ORDER BY id`,
    [ws.rows[0].id],
  );
  log('== indexed plan ==');
  log(indexed.rows.map((row) => row['QUERY PLAN']).join('\n'));

  await pool.query('BEGIN');
  await pool.query('SET LOCAL enable_indexscan = off');
  await pool.query('SET LOCAL enable_bitmapscan = off');
  const seq = await pool.query(
    `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
     SELECT id, title, status FROM p02.tasks WHERE workspace_id = $1 AND status = 'done' ORDER BY id`,
    [ws.rows[0].id],
  );
  await pool.query('ROLLBACK');
  log('== forced sequential plan (index/bitmap disabled, same SQL) ==');
  log(seq.rows.map((row) => row['QUERY PLAN']).join('\n'));

  const ids = (await pool.query('SELECT id FROM p02.tasks WHERE workspace_id = $1 ORDER BY id LIMIT 50', [ws.rows[0].id])).rows.map((row) => row.id);

  const individual = [];
  for (let round = 0; round < 3; round++) {
    const status = round % 2 === 0 ? 'doing' : 'todo';
    individual.push(await time(async () => {
      await pool.query('BEGIN');
      for (const id of ids) await pool.query('UPDATE p02.tasks SET status = $2 WHERE id = $1', [id, status]);
      await pool.query('COMMIT');
    }));
  }

  const setBased = [];
  for (let round = 0; round < 3; round++) {
    const status = round % 2 === 0 ? 'doing' : 'todo';
    setBased.push(await time(() => pool.query('UPDATE p02.tasks SET status = $2 WHERE id = ANY($1) AND workspace_id = $3', [ids, status, ws.rows[0].id])));
  }

  log('');
  log(`rows_seeded=10000`);
  log(`individual_50_updates_ms=${individual.map((value) => value.toFixed(2)).join(',')}`);
  log(`set_based_50_updates_ms=${setBased.map((value) => value.toFixed(2)).join(',')}`);
  log(`median_individual_ms=${[...individual].sort((a, b) => a - b)[1].toFixed(2)}`);
  log(`median_set_based_ms=${[...setBased].sort((a, b) => a - b)[1].toFixed(2)}`);
  log('D90 PASS');
} finally {
  await pool.end();
  fs.mkdirSync('evidence', { recursive: true });
  fs.writeFileSync('evidence/d90-perf.txt', lines.join('\n') + '\n');
}
