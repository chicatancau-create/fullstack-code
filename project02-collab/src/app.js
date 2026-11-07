import Fastify from 'fastify';
import crypto from 'node:crypto';

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.scryptSync(password, salt, 32).toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, stored) {
  const [salt, hash] = String(stored).split(':');
  if (!salt || !hash) return false;
  const actual = crypto.scryptSync(password, salt, 32);
  return crypto.timingSafeEqual(actual, Buffer.from(hash, 'hex'));
}

export function buildApp({ pool, logger = false } = {}) {
  const app = Fastify({ logger, bodyLimit: 16384 });
  app.addHook('onSend', async (request, reply, payload) => {
    reply.header('X-Content-Type-Options', 'nosniff');
    return payload;
  });
  app.setErrorHandler((error, request, reply) => {
    if (error.validation) return reply.code(400).send({ error: 'validation_failed' });
    if (error.code === '23505') return reply.code(409).send({ error: 'conflict' });
    request.log.error({ message: error.message });
    return reply.code(500).send({ error: 'internal_error' });
  });

  async function requireUser(request, reply) {
    const header = request.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : '';
    if (!token) return reply.code(401).send({ error: 'unauthenticated' });
    const result = await pool.query(
      `SELECT u.id, u.email FROM p02.sessions s JOIN p02.users u ON u.id = s.user_id
       WHERE s.token = $1 AND s.expires_at > now()`,
      [token],
    );
    if (result.rowCount === 0) return reply.code(401).send({ error: 'unauthenticated' });
    request.user = result.rows[0];
  }

  async function memberOf(workspaceId, userId) {
    const result = await pool.query(
      'SELECT role FROM p02.members WHERE workspace_id = $1 AND user_id = $2',
      [workspaceId, userId],
    );
    return result.rows[0] || null;
  }

  async function ownerOf(workspaceId, userId) {
    const member = await memberOf(workspaceId, userId);
    return member?.role === 'owner';
  }

  app.post('/auth/register', async (request, reply) => {
    const { email, password } = request.body || {};
    if (typeof email !== 'string' || !email.includes('@') || email.length > 120) {
      return reply.code(400).send({ error: 'invalid_email' });
    }
    if (typeof password !== 'string' || password.length < 8) {
      return reply.code(400).send({ error: 'weak_password' });
    }
    const inserted = await pool.query(
      'INSERT INTO p02.users (email, password_hash) VALUES ($1, $2) RETURNING id, email',
      [email.toLowerCase(), hashPassword(password)],
    );
    return reply.code(201).send(inserted.rows[0]);
  });

  app.post('/auth/login', async (request, reply) => {
    const { email, password } = request.body || {};
    const result = await pool.query('SELECT id, email, password_hash FROM p02.users WHERE email = $1', [
      String(email || '').toLowerCase(),
    ]);
    const user = result.rows[0];
    if (!user || !verifyPassword(String(password || ''), user.password_hash)) {
      return reply.code(401).send({ error: 'bad_credentials' });
    }
    const token = crypto.randomBytes(24).toString('hex');
    await pool.query(
      "INSERT INTO p02.sessions (token, user_id, expires_at) VALUES ($1, $2, now() + interval '1 hour')",
      [token, user.id],
    );
    return { token };
  });

  app.post('/auth/logout', { preHandler: requireUser }, async (request, reply) => {
    const header = request.headers.authorization || '';
    await pool.query('DELETE FROM p02.sessions WHERE token = $1', [header.slice(7)]);
    return reply.code(204).send();
  });

  app.get('/me', { preHandler: requireUser }, async (request) => request.user);

  app.post('/workspaces', { preHandler: requireUser }, async (request, reply) => {
    const { name, slug } = request.body || {};
    if (typeof name !== 'string' || name.trim().length < 1 || name.length > 80) {
      return reply.code(400).send({ error: 'invalid_name' });
    }
    if (typeof slug !== 'string' || !/^[a-z0-9-]{2,40}$/.test(slug)) {
      return reply.code(400).send({ error: 'invalid_slug' });
    }
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const ws = await client.query('INSERT INTO p02.workspaces (slug, name) VALUES ($1, $2) RETURNING id, slug, name', [slug, name]);
      await client.query("INSERT INTO p02.members (workspace_id, user_id, role) VALUES ($1, $2, 'owner')", [ws.rows[0].id, request.user.id]);
      await client.query('COMMIT');
      return reply.code(201).send(ws.rows[0]);
    } catch (error) {
      await client.query('ROLLBACK');
      if (error.code === '23505') return reply.code(409).send({ error: 'slug_taken' });
      throw error;
    } finally {
      client.release();
    }
  });

  app.get('/workspaces', { preHandler: requireUser }, async (request) => {
    const result = await pool.query(
      `SELECT w.id, w.slug, w.name, m.role
       FROM p02.workspaces w JOIN p02.members m ON m.workspace_id = w.id
       WHERE m.user_id = $1 ORDER BY w.id`,
      [request.user.id],
    );
    return { workspaces: result.rows };
  });

  app.get('/workspaces/:id', { preHandler: requireUser }, async (request, reply) => {
    const member = await memberOf(Number(request.params.id), request.user.id);
    if (!member) return reply.code(404).send({ error: 'not_found' });
    const result = await pool.query('SELECT id, slug, name FROM p02.workspaces WHERE id = $1', [request.params.id]);
    return { ...result.rows[0], role: member.role };
  });

  app.post('/workspaces/:id/members', { preHandler: requireUser }, async (request, reply) => {
    const workspaceId = Number(request.params.id);
    if (!(await ownerOf(workspaceId, request.user.id))) return reply.code(404).send({ error: 'not_found' });
    const { email, role = 'member' } = request.body || {};
    if (role !== 'owner' && role !== 'member') return reply.code(400).send({ error: 'invalid_role' });
    const user = await pool.query('SELECT id FROM p02.users WHERE email = $1', [String(email || '').toLowerCase()]);
    if (user.rowCount === 0) return reply.code(404).send({ error: 'user_not_found' });
    await pool.query('INSERT INTO p02.members (workspace_id, user_id, role) VALUES ($1, $2, $3)', [workspaceId, user.rows[0].id, role]);
    return reply.code(201).send({ workspace_id: workspaceId, user_id: user.rows[0].id, role });
  });

  app.delete('/workspaces/:id/members/:userId', { preHandler: requireUser }, async (request, reply) => {
    const workspaceId = Number(request.params.id);
    const targetId = Number(request.params.userId);
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const lock = await client.query('SELECT id FROM p02.workspaces WHERE id = $1 FOR UPDATE', [workspaceId]);
      if (lock.rowCount === 0) { await client.query('ROLLBACK'); return reply.code(404).send({ error: 'not_found' }); }
      const requester = await client.query('SELECT role FROM p02.members WHERE workspace_id = $1 AND user_id = $2', [workspaceId, request.user.id]);
      if (requester.rows[0]?.role !== 'owner') { await client.query('ROLLBACK'); return reply.code(404).send({ error: 'not_found' }); }
      const target = await client.query('SELECT role FROM p02.members WHERE workspace_id = $1 AND user_id = $2', [workspaceId, targetId]);
      if (target.rowCount === 0) { await client.query('ROLLBACK'); return reply.code(404).send({ error: 'not_found' }); }
      if (target.rows[0].role === 'owner') {
        const owners = await client.query("SELECT count(*)::int AS n FROM p02.members WHERE workspace_id = $1 AND role = 'owner'", [workspaceId]);
        if (owners.rows[0].n <= 1) { await client.query('ROLLBACK'); return reply.code(409).send({ error: 'last_owner' }); }
      }
      await client.query('DELETE FROM p02.members WHERE workspace_id = $1 AND user_id = $2', [workspaceId, targetId]);
      await client.query('COMMIT');
      return reply.code(204).send();
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  });

  app.patch('/workspaces/:id/members/:userId', { preHandler: requireUser }, async (request, reply) => {
    const workspaceId = Number(request.params.id);
    const targetId = Number(request.params.userId);
    const role = request.body?.role;
    if (role !== 'owner' && role !== 'member') return reply.code(400).send({ error: 'invalid_role' });
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query('SELECT id FROM p02.workspaces WHERE id = $1 FOR UPDATE', [workspaceId]);
      const requester = await client.query('SELECT role FROM p02.members WHERE workspace_id = $1 AND user_id = $2', [workspaceId, request.user.id]);
      if (requester.rows[0]?.role !== 'owner') { await client.query('ROLLBACK'); return reply.code(404).send({ error: 'not_found' }); }
      const target = await client.query('SELECT role FROM p02.members WHERE workspace_id = $1 AND user_id = $2', [workspaceId, targetId]);
      if (target.rowCount === 0) { await client.query('ROLLBACK'); return reply.code(404).send({ error: 'not_found' }); }
      if (target.rows[0].role === 'owner' && role === 'member') {
        const owners = await client.query("SELECT count(*)::int AS n FROM p02.members WHERE workspace_id = $1 AND role = 'owner'", [workspaceId]);
        if (owners.rows[0].n <= 1) { await client.query('ROLLBACK'); return reply.code(409).send({ error: 'last_owner' }); }
      }
      await client.query('UPDATE p02.members SET role = $3 WHERE workspace_id = $1 AND user_id = $2', [workspaceId, targetId, role]);
      await client.query('COMMIT');
      return { workspace_id: workspaceId, user_id: targetId, role };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  });

  app.get('/workspaces/:id/tasks', { preHandler: requireUser }, async (request, reply) => {
    const workspaceId = Number(request.params.id);
    if (!(await memberOf(workspaceId, request.user.id))) return reply.code(404).send({ error: 'not_found' });
    const result = await pool.query('SELECT id, title, status FROM p02.tasks WHERE workspace_id = $1 ORDER BY id', [workspaceId]);
    return { tasks: result.rows };
  });

  app.post('/workspaces/:id/tasks', { preHandler: requireUser }, async (request, reply) => {
    const workspaceId = Number(request.params.id);
    if (!(await memberOf(workspaceId, request.user.id))) return reply.code(404).send({ error: 'not_found' });
    const title = typeof request.body?.title === 'string' ? request.body.title.trim() : '';
    if (title.length < 1 || title.length > 80) return reply.code(400).send({ error: 'invalid_title' });
    try {
      const result = await pool.query('INSERT INTO p02.tasks (workspace_id, title) VALUES ($1, $2) RETURNING id, title, status', [workspaceId, title]);
      return reply.code(201).send(result.rows[0]);
    } catch (error) {
      if (error.code === '23505') return reply.code(409).send({ error: 'duplicate_title' });
      throw error;
    }
  });

  app.patch('/tasks/:taskId', { preHandler: requireUser }, async (request, reply) => {
    const status = request.body?.status;
    if (status !== 'todo' && status !== 'doing' && status !== 'done') return reply.code(400).send({ error: 'invalid_status' });
    const task = await pool.query(
      `SELECT t.id, t.workspace_id FROM p02.tasks t
       JOIN p02.members m ON m.workspace_id = t.workspace_id
       WHERE t.id = $1 AND m.user_id = $2`,
      [Number(request.params.taskId), request.user.id],
    );
    if (task.rowCount === 0) return reply.code(404).send({ error: 'not_found' });
    const updated = await pool.query('UPDATE p02.tasks SET status = $2 WHERE id = $1 RETURNING id, title, status', [task.rows[0].id, status]);
    return updated.rows[0];
  });

  return app;
}