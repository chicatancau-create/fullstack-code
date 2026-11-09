import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const bin = process.env.MYSQL_BIN || 'D:/MySQL/server/bin';
const tool = (name) => path.join(bin, `${name}.exe`);
const env = { ...process.env, MYSQL_PWD: process.env.DB_PASSWORD || 'study-pass' };
const evidence = path.resolve('evidence');
fs.mkdirSync(evidence, { recursive: true });
const dumpFile = path.join(evidence, 'p02j-backup.sql');
const restoreDb = 'p02j_restore_check';

function run(cmd, args, extraEnv = {}) {
  const merged = { ...env, ...extraEnv };
  if (extraEnv.MYSQL_PWD === null) delete merged.MYSQL_PWD;
  const result = spawnSync(tool(cmd), args, { env: merged, encoding: 'utf8' });
  if (result.status !== 0) throw new Error(`${cmd} failed: ${result.error?.message || result.stderr}`);
  return result.stdout;
}

const dump = run('mysqldump', ['--protocol=tcp', '-h127.0.0.1', '-P3307', '-ustudy', 'p02j',
  '--no-tablespaces', '--skip-comments', '--single-transaction']);
fs.writeFileSync(dumpFile, dump);
console.log(`dump bytes=${Buffer.byteLength(dump)} file=${dumpFile}`);

run('mysql', ['--protocol=tcp', '-h127.0.0.1', '-P3307', '-uroot', '-e', `DROP DATABASE IF EXISTS ${restoreDb}; CREATE DATABASE ${restoreDb};`], { MYSQL_PWD: null });
try {
  const restoreEnv = { ...env };
  delete restoreEnv.MYSQL_PWD;
  const restore = spawnSync(tool('mysql'), ['--protocol=tcp', '-h127.0.0.1', '-P3307', '-uroot', restoreDb], { input: dump, encoding: 'utf8', env: restoreEnv });
  if (restore.status !== 0) throw new Error(`restore failed: ${restore.stderr}`);
  const query = "SELECT CONCAT('users=', COUNT(*)) FROM users UNION ALL SELECT CONCAT('memberships=', COUNT(*)) FROM memberships UNION ALL SELECT CONCAT('tasks=', COUNT(*)) FROM tasks UNION ALL SELECT CONCAT('audit=', COUNT(*)) FROM audit_events UNION ALL SELECT CONCAT('invitations=', COUNT(*)) FROM invitations";
  const counts = (db) => run('mysql', ['--protocol=tcp', '-h127.0.0.1', '-P3307', '-uroot', '-N', '-e', query, db], { MYSQL_PWD: null }).trim().replace(/\n/g, ' ');
  console.log(`source  ${counts('p02j')}`);
  console.log(`restore ${counts(restoreDb)}`);
  if (counts('p02j') !== counts(restoreDb)) throw new Error('restore row counts differ');
  console.log('RESTORE OK');
} finally {
  run('mysql', ['--protocol=tcp', '-h127.0.0.1', '-P3307', '-uroot', '-e', `DROP DATABASE IF EXISTS ${restoreDb};`], { MYSQL_PWD: null });
}
