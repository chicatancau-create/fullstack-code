import fs from 'node:fs';
import path from 'node:path';
import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { buildApp } from '../src/app.js';
import { createPool } from '../src/db.mjs';

if (!process.env.PGDATABASE || process.env.PGDATABASE === 'study_lab') {
  throw new Error('测试必须使用独立库：PGDATABASE=study_lab_p05（测试会 DROP SCHEMA p02）');
}

const pool = createPool();
let app;

async function reset() {
  await pool.query('DROP SCHEMA IF EXISTS p02 CASCADE');
  await pool.query(fs.readFileSync(path.resolve('migrations/001_init.sql'), 'utf8'));
  await pool.query(fs.readFileSync(path.resolve('migrations/002_task_events.sql'), 'utf8'));
}

before(async () => {
  app = buildApp({ pool });
  await app.ready();
});
beforeEach(reset);
after(async () => {
  await app.close();
  await pool.end();
});

const auth = (token) => ({ authorization: `Bearer ${token}` });

async function user(email) {
  const register = await app.inject({ method: 'POST', url: '/auth/register', payload: { email, password: 'password123' } });
  assert.equal(register.statusCode, 201, register.body);
  const login = await app.inject({ method: 'POST', url: '/auth/login', payload: { email, password: 'password123' } });
  assert.equal(login.statusCode, 200, login.body);
  return { id: register.json().id, token: login.json().token };
}

async function workspace(token, slug) {
  const response = await app.inject({ method: 'POST', url: '/workspaces', headers: auth(token), payload: { name: slug, slug } });
  assert.equal(response.statusCode, 201, response.body);
  return response.json();
}

test('回归：过期会话必须被拒绝', async () => {
  const alice = await user('alice@example.com');
  await pool.query("UPDATE p02.sessions SET expires_at = now() - interval '1 minute' WHERE token = $1", [alice.token]);
  const me = await app.inject({ method: 'GET', url: '/me', headers: auth(alice.token) });
  assert.equal(me.statusCode, 401);
});

test('回归：非成员不能读取其他工作区任务', async () => {
  const alice = await user('alice@example.com');
  const bob = await user('bob@example.com');
  const ws = await workspace(alice.token, 'alpha');
  await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/tasks`, headers: auth(alice.token), payload: { title: '私有任务' } });
  const leaked = await app.inject({ method: 'GET', url: `/workspaces/${ws.id}/tasks`, headers: auth(bob.token) });
  assert.equal(leaked.statusCode, 404);
});

test('回归：最后一名 owner 不能被移除', async () => {
  const alice = await user('alice@example.com');
  const ws = await workspace(alice.token, 'alpha');
  const removed = await app.inject({ method: 'DELETE', url: `/workspaces/${ws.id}/members/${alice.id}`, headers: auth(alice.token) });
  assert.equal(removed.statusCode, 409);
  const owners = await pool.query("SELECT count(*)::int AS n FROM p02.members WHERE workspace_id = $1 AND role = 'owner'", [ws.id]);
  assert.equal(owners.rows[0].n, 1);
});


async function addMember(token, workspaceId, email) {
  const response = await app.inject({ method: 'POST', url: `/workspaces/${workspaceId}/members`, headers: auth(token), payload: { email } });
  assert.equal(response.statusCode, 201, response.body);
}

async function setRole(token, workspaceId, userId, role) {
  return app.inject({ method: 'PATCH', url: `/workspaces/${workspaceId}/members/${userId}`, headers: auth(token), payload: { role } });
}

test('正向：owner 可以移除普通成员，成员列表同步减少', async () => {
  const alice = await user('alice@example.com');
  const bob = await user('bob@example.com');
  const ws = await workspace(alice.token, 'alpha');
  await addMember(alice.token, ws.id, 'bob@example.com');
  const removed = await app.inject({ method: 'DELETE', url: `/workspaces/${ws.id}/members/${bob.id}`, headers: auth(alice.token) });
  assert.equal(removed.statusCode, 204);
  const members = await pool.query("SELECT count(*)::int AS n FROM p02.members WHERE workspace_id = $1", [ws.id]);
  assert.equal(members.rows[0].n, 1);
});

test('最后 owner 同时保护自删与降级；双 owner 时允许降级', async () => {
  const alice = await user('alice@example.com');
  const bob = await user('bob@example.com');
  const ws = await workspace(alice.token, 'alpha');
  const demoteSelf = await setRole(alice.token, ws.id, alice.id, 'member');
  assert.equal(demoteSelf.statusCode, 409);
  await addMember(alice.token, ws.id, 'bob@example.com');
  assert.equal((await setRole(alice.token, ws.id, bob.id, 'owner')).statusCode, 200);
  assert.equal((await setRole(alice.token, ws.id, alice.id, 'member')).statusCode, 200);
  const demoteLast = await setRole(bob.token, ws.id, bob.id, 'member');
  assert.equal(demoteLast.statusCode, 409);
  const owners = await pool.query("SELECT count(*)::int AS n FROM p02.members WHERE workspace_id = $1 AND role = 'owner'", [ws.id]);
  assert.equal(owners.rows[0].n, 1);
});

test('并发互删双 owner 最终仍保留 1 个 owner', async () => {
  const alice = await user('alice@example.com');
  const bob = await user('bob@example.com');
  const ws = await workspace(alice.token, 'alpha');
  await addMember(alice.token, ws.id, 'bob@example.com');
  assert.equal((await setRole(alice.token, ws.id, bob.id, 'owner')).statusCode, 200);
  const [r1, r2] = await Promise.all([
    app.inject({ method: 'DELETE', url: `/workspaces/${ws.id}/members/${bob.id}`, headers: auth(alice.token) }),
    app.inject({ method: 'DELETE', url: `/workspaces/${ws.id}/members/${alice.id}`, headers: auth(bob.token) }),
  ]);
  const statuses = [r1.statusCode, r2.statusCode];
  assert.ok(statuses.includes(204));
  assert.ok(statuses.includes(409) || statuses.includes(404));
  const owners = await pool.query("SELECT count(*)::int AS n FROM p02.members WHERE workspace_id = $1 AND role = 'owner'", [ws.id]);
  assert.equal(owners.rows[0].n, 1);
});

test('基线：成员仍可读取本工作区任务', async () => {
  const alice = await user('alice@example.com');
  const ws = await workspace(alice.token, 'alpha');
  await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/tasks`, headers: auth(alice.token), payload: { title: '本区任务' } });
  const own = await app.inject({ method: 'GET', url: `/workspaces/${ws.id}/tasks`, headers: auth(alice.token) });
  assert.equal(own.statusCode, 200);
  assert.equal(own.json().tasks.length, 1);
});

async function createTask(token, workspaceId, title) {
  const response = await app.inject({ method: 'POST', url: `/workspaces/${workspaceId}/tasks`, headers: auth(token), payload: { title } });
  assert.equal(response.statusCode, 201, response.body);
  return response.json();
}

test('D88：批量改状态返回逐项结果并写审计', async () => {
  const alice = await user('alice@example.com');
  const ws = await workspace(alice.token, 'alpha');
  const first = await createTask(alice.token, ws.id, '任务一');
  const second = await createTask(alice.token, ws.id, '任务二');
  const third = await createTask(alice.token, ws.id, '任务三');
  const response = await app.inject({
    method: 'PATCH',
    url: `/workspaces/${ws.id}/tasks/batch`,
    headers: auth(alice.token),
    payload: { updates: [{ id: first.id, status: 'done' }, { id: second.id, status: 'doing' }, { id: third.id, status: 'todo' }] },
  });
  assert.equal(response.statusCode, 200, response.body);
  const results = response.json().results;
  assert.equal(results.length, 3);
  assert.deepEqual(results.map((item) => item.changed), [true, true, false]);
  const rows = await pool.query('SELECT id, status FROM p02.tasks WHERE workspace_id = $1 ORDER BY id', [ws.id]);
  assert.deepEqual(rows.rows.map((row) => row.status), ['done', 'doing', 'todo']);
  const events = await pool.query('SELECT from_status, to_status, actor_id FROM p02.task_events WHERE task_id = $1', [first.id]);
  assert.equal(events.rowCount, 1);
  assert.equal(events.rows[0].from_status, 'todo');
  assert.equal(events.rows[0].to_status, 'done');
  assert.equal(events.rows[0].actor_id, alice.id);
});

test('D88：批量中的非法项逐项失败，合法项仍然生效', async () => {
  const alice = await user('alice@example.com');
  const ws = await workspace(alice.token, 'alpha');
  const task = await createTask(alice.token, ws.id, '任务一');
  const response = await app.inject({
    method: 'PATCH',
    url: `/workspaces/${ws.id}/tasks/batch`,
    headers: auth(alice.token),
    payload: { updates: [{ id: task.id, status: 'bogus' }, { id: -1, status: 'done' }, { id: task.id, status: 'doing' }] },
  });
  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.json().results.map((item) => item.ok), [false, false, true]);
  assert.deepEqual(response.json().results.map((item) => item.error || null), ['invalid_status', 'invalid_id', null]);
  const row = await pool.query('SELECT status FROM p02.tasks WHERE id = $1', [task.id]);
  assert.equal(row.rows[0].status, 'doing');
});

test('D88：批量不能改其他工作区任务', async () => {
  const alice = await user('alice@example.com');
  const bob = await user('bob@example.com');
  const alpha = await workspace(alice.token, 'alpha');
  const beta = await workspace(bob.token, 'beta');
  const foreign = await createTask(alice.token, alpha.id, '别人的任务');
  const response = await app.inject({
    method: 'PATCH',
    url: `/workspaces/${beta.id}/tasks/batch`,
    headers: auth(bob.token),
    payload: { updates: [{ id: foreign.id, status: 'done' }] },
  });
  assert.equal(response.statusCode, 200);
  assert.equal(response.json().results[0].error, 'not_found');
  const row = await pool.query('SELECT status FROM p02.tasks WHERE id = $1', [foreign.id]);
  assert.equal(row.rows[0].status, 'todo');
});

test('D88：批量上限 50 条，超限整体拒绝', async () => {
  const alice = await user('alice@example.com');
  const ws = await workspace(alice.token, 'alpha');
  const updates = Array.from({ length: 51 }, (_, index) => ({ id: index + 1, status: 'done' }));
  const response = await app.inject({ method: 'PATCH', url: `/workspaces/${ws.id}/tasks/batch`, headers: auth(alice.token), payload: { updates } });
  assert.equal(response.statusCode, 400);
  assert.equal(response.json().error, 'invalid_updates');
});

test('D89：单条状态更新写审计且重复提交幂等', async () => {
  const alice = await user('alice@example.com');
  const ws = await workspace(alice.token, 'alpha');
  const task = await createTask(alice.token, ws.id, '任务一');
  const first = await app.inject({ method: 'PATCH', url: `/tasks/${task.id}`, headers: auth(alice.token), payload: { status: 'done' } });
  assert.equal(first.statusCode, 200);
  assert.equal(first.json().changed, true);
  const second = await app.inject({ method: 'PATCH', url: `/tasks/${task.id}`, headers: auth(alice.token), payload: { status: 'done' } });
  assert.equal(second.statusCode, 200);
  assert.equal(second.json().changed, false);
  const events = await pool.query('SELECT count(*)::int AS n FROM p02.task_events WHERE task_id = $1', [task.id]);
  assert.equal(events.rows[0].n, 1);
});
