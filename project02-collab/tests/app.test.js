import fs from 'node:fs';
import path from 'node:path';
import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { buildApp } from '../src/app.js';
import { createPool } from '../src/db.mjs';

const pool = createPool();
let app;

async function reset() {
  await pool.query('DROP SCHEMA IF EXISTS p02 CASCADE');
  const sql = fs.readFileSync(path.resolve('migrations/001_init.sql'), 'utf8');
  await pool.query(sql);
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

async function registerAndLogin(email, password = 'password123') {
  const register = await app.inject({ method: 'POST', url: '/auth/register', payload: { email, password } });
  assert.equal(register.statusCode, 201, register.body);
  const login = await app.inject({ method: 'POST', url: '/auth/login', payload: { email, password } });
  assert.equal(login.statusCode, 200, login.body);
  return { id: register.json().id, token: login.json().token };
}

async function createWorkspace(token, slug) {
  const response = await app.inject({ method: 'POST', url: '/workspaces', headers: auth(token), payload: { name: slug, slug } });
  assert.equal(response.statusCode, 201, response.body);
  return response.json();
}

test('注册/登录/me/logout', async () => {
  const { token } = await registerAndLogin('alice@example.com');
  const me = await app.inject({ method: 'GET', url: '/me', headers: auth(token) });
  assert.equal(me.statusCode, 200);
  assert.equal(me.json().email, 'alice@example.com');
  const out = await app.inject({ method: 'POST', url: '/auth/logout', headers: auth(token) });
  assert.equal(out.statusCode, 204);
  assert.equal((await app.inject({ method: 'GET', url: '/me', headers: auth(token) })).statusCode, 401);
});

test('工作区：创建者成为 owner，跨租户 404', async () => {
  const alice = await registerAndLogin('alice@example.com');
  const bob = await registerAndLogin('bob@example.com');
  const ws = await createWorkspace(alice.token, 'alpha');
  const list = await app.inject({ method: 'GET', url: '/workspaces', headers: auth(alice.token) });
  assert.equal(list.json().workspaces[0].role, 'owner');
  const other = await app.inject({ method: 'GET', url: `/workspaces/${ws.id}`, headers: auth(bob.token) });
  assert.equal(other.statusCode, 404);
});

test('成员管理：owner 可加人，member 不可加/删', async () => {
  const alice = await registerAndLogin('alice@example.com');
  const bob = await registerAndLogin('bob@example.com');
  const ws = await createWorkspace(alice.token, 'alpha');
  const added = await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/members`, headers: auth(alice.token), payload: { email: 'bob@example.com' } });
  assert.equal(added.statusCode, 201);
  const memberAdd = await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/members`, headers: auth(bob.token), payload: { email: 'bob@example.com' } });
  assert.equal(memberAdd.statusCode, 404);
  const memberDelete = await app.inject({ method: 'DELETE', url: `/workspaces/${ws.id}/members/${alice.id}`, headers: auth(bob.token) });
  assert.equal(memberDelete.statusCode, 404);
});

test('最后 Owner：删除自己返回 409', async () => {
  const alice = await registerAndLogin('alice@example.com');
  const ws = await createWorkspace(alice.token, 'alpha');
  const response = await app.inject({ method: 'DELETE', url: `/workspaces/${ws.id}/members/${alice.id}`, headers: auth(alice.token) });
  assert.equal(response.statusCode, 409);
  assert.equal(response.json().error, 'last_owner');
});

test('并发：两个 Owner 同时删自己，只有一个成功，最终保留 1 个', async () => {
  const alice = await registerAndLogin('alice@example.com');
  const bob = await registerAndLogin('bob@example.com');
  const ws = await createWorkspace(alice.token, 'alpha');
  await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/members`, headers: auth(alice.token), payload: { email: 'bob@example.com', role: 'owner' } });

  const [a, b] = await Promise.all([
    app.inject({ method: 'DELETE', url: `/workspaces/${ws.id}/members/${alice.id}`, headers: auth(alice.token) }),
    app.inject({ method: 'DELETE', url: `/workspaces/${ws.id}/members/${bob.id}`, headers: auth(bob.token) }),
  ]);
  assert.deepEqual([a.statusCode, b.statusCode].sort(), [204, 409]);
  const owners = await pool.query("SELECT count(*)::int AS n FROM p02.members WHERE workspace_id = $1 AND role = 'owner'", [ws.id]);
  assert.equal(owners.rows[0].n, 1);
});

test('唯一约束：slug 与任务标题重复返回 409', async () => {
  const alice = await registerAndLogin('alice@example.com');
  const ws = await createWorkspace(alice.token, 'alpha');
  const dupSlug = await app.inject({ method: 'POST', url: '/workspaces', headers: auth(alice.token), payload: { name: 'alpha2', slug: 'alpha' } });
  assert.equal(dupSlug.statusCode, 409);
  const first = await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/tasks`, headers: auth(alice.token), payload: { title: 'same' } });
  const second = await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/tasks`, headers: auth(alice.token), payload: { title: 'same' } });
  assert.equal(first.statusCode, 201);
  assert.equal(second.statusCode, 409);
});

test('任务：成员可改状态，跨租户 404', async () => {
  const alice = await registerAndLogin('alice@example.com');
  const bob = await registerAndLogin('bob@example.com');
  const ws = await createWorkspace(alice.token, 'alpha');
  await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/members`, headers: auth(alice.token), payload: { email: 'bob@example.com' } });
  const task = await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/tasks`, headers: auth(alice.token), payload: { title: 'do it' } });
  const updated = await app.inject({ method: 'PATCH', url: `/tasks/${task.json().id}`, headers: auth(bob.token), payload: { status: 'done' } });
  assert.equal(updated.statusCode, 200);
  assert.equal(updated.json().status, 'done');

  const bobWs = await createWorkspace(bob.token, 'beta');
  const bobTask = await app.inject({ method: 'POST', url: `/workspaces/${bobWs.id}/tasks`, headers: auth(bob.token), payload: { title: 'bob only' } });
  const cross = await app.inject({ method: 'PATCH', url: `/tasks/${bobTask.json().id}`, headers: auth(alice.token), payload: { status: 'todo' } });
  assert.equal(cross.statusCode, 404);
});