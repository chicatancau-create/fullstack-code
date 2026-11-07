# 项目 02 自审记录

- 日期：2026-11-07
- 范围：`src/`、`tests/`、`migrations/`、`openapi.json`
- 方式：自审 + AI 辅助；不是外部评审

## 结论

| 风险 | 结论 | 证据 |
| --- | --- | --- |
| 最后 Owner 并发 | 父行锁串行化；并发只成功 1 个 | `tests/app.test.js` |
| 跨租户读写 | workspace/task 404 | 测试 |
| 唯一约束 | slug、任务标题 409 | 测试 |
| 认证/注销 | 登录、logout 后 401 | 测试 |
| 迁移 | 5 表幂等创建 | `evidence/migrate.txt` |
| 恢复 | dump/DROP/restore | `evidence/backup.txt` |

## 未覆盖

- 无前端、实时、通知、审计、限流、MFA、密码重置。
- 无连接池耗尽/锁等待超时/死锁演练。
- 无生产部署、HTTPS、监控、RTO/RPO。
- 无外部评审；AI 意见需逐条验证。
