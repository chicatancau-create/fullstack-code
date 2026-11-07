# 复现修复前状态（手动）

工作树是修复后的版本；要验证“失败先行”，在临时副本中回退以下三处即可得到 1 pass / 3 fail。

```bash
cd /tmp
git -C E:/fullstack-code archive HEAD project05-takeover | tar -x -C /tmp
cd /tmp/project05-takeover
# 使用独立库，避免清共享数据
createdb -h 127.0.0.1 -U study study_lab_p05_probe
export PGDATABASE=study_lab_p05_probe PGPASSWORD=study-pass
```

## 1. 会话过期校验

`src/app.js` 的 `requireUser` SQL：

```diff
- WHERE s.token = $1 AND s.expires_at > now()`
+ WHERE s.token = $1`
```

## 2. 任务列表成员校验

`GET /workspaces/:id/tasks`：

```diff
  const workspaceId = Number(request.params.id);
- if (!(await memberOf(workspaceId, request.user.id))) return reply.code(404).send({ error: 'not_found' });
  const result = await pool.query(...)
```

## 3. 最后 owner 保护

`DELETE /workspaces/:id/members/:userId` 删除前：

```diff
- if (target.rows[0].role === 'owner') {
-   const owners = await client.query("SELECT count(*)::int AS n ... role = 'owner'", [workspaceId]);
-   if (owners.rows[0].n <= 1) { await client.query('ROLLBACK'); return reply.code(409).send({ error: 'last_owner' }); }
- }
  await client.query('DELETE FROM p02.members ...')
```

运行：

```bash
node --test tests/regressions.test.js
```

预期：T-01 返回 200（应 401）、T-02 返回 200（应 404）、T-03 返回 204（应 409）；
基线任务读取仍通过。修复后同一命令 7/7 通过。

> 这是“已知缺陷回退”演练，不是盲测；不能替代真实接手或外部复核。
