# 交接说明（Handover）

## 仓库地图

```text
src/app.js          Fastify 应用：认证、工作区、成员、任务
src/db.mjs          pg Pool（PGPASSWORD 必填）
migrations/001_init.sql  p02 schema：users/sessions/workspaces/members/tasks
tests/regressions.test.js 接手后新增的回归测试（4 个）
scripts/migrate.mjs 执行迁移
```

## 运行与停止

- 依赖：Node 24、PostgreSQL 18（本机 `D:/PostgreSQL/18`）。
- 启动：快照没有 server 入口；用 `buildApp({ pool })` 由调用方启动，测试即示例。
- 测试：`node --test tests/regressions.test.js`（会自动 drop/create p02 schema）。
- 停止：测试结束即退出；没有常驻进程。

## 接手发现

1. **会话过期未校验**：`requireUser` 查询缺 `expires_at > now()`，过期令牌永久有效。
2. **任务列表缺成员校验**：`GET /workspaces/:id/tasks` 只按 workspace_id 查询，任何登录用户可读。
3. **最后 owner 保护缺失**：删除成员只校验请求者是 owner，没有检查目标是否是最后一名 owner，
   也没有在事务内统计；本次恢复为事务内行锁 + 计数。

## 风险与建议（未实施）

- 会话令牌明文入库（项目 02 快照设计），生产应存哈希。
- 登录无速率限制/锁定；无审计日志。
- 成员角色变更与删除的并发路径需要专门测试（当前只有顺序回归）。
- 无健康检查、结构化指标、备份恢复与部署脚本。

## 交接清单

- [x] 能按 README 从空库跑起测试
- [x] 三个报告缺陷有失败先行证据
- [x] 修复后有回归测试
- [x] 风险与未修复项写明
- [ ] 真实接收人独立复现（未做）
