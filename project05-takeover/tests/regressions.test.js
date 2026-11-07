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
  await pool.query(fs.readFileSync(path.resolve('migrations/001_init.sql'), 'utf8'));
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

test('基线：成员仍可读取本工作区任务', async () => {
  const alice = await user('alice@example.com');
  const ws = await workspace(alice.token, 'alpha');
  await app.inject({ method: 'POST', url: `/workspaces/${ws.id}/tasks`, headers: auth(alice.token), payload: { title: '本区任务' } });
  const own = await app.inject({ method: 'GET', url: `/workspaces/${ws.id}/tasks`, headers: auth(alice.token) });
  assert.equal(own.statusCode, 200);
  assert.equal(own.json().tasks.length, 1);
});
