# 独立接手复现记录（AI 接收人，2026-11-08）

> 这不是人类接收人。由独立 AI 审查代理只读复现，结论属于“AI 可用性复核”，不能替代外部验收。

## 实际执行

```bash
cd E:/fullstack-code/project05-takeover
npm ci                                             # exit 0
PGDATABASE=study_lab_p05 node scripts/migrate.mjs  # exit 0
PGDATABASE=study_lab_p05 node --test tests/regressions.test.js  # 7/7, exit 0
```

空库验证（代理自建临时库）：新建库后迁移 + 测试 4/4（当时用例数）通过；`manifest verify` OK。

## 发现与处置

| # | 发现 | 级别 | 处置 |
| --- | --- | --- | --- |
| 1 | 测试会 `DROP SCHEMA p02`，原先默认指向共享 `study_lab`，误跑清库 | 阻断 | 默认/CI 改为独立库 `study_lab_p05`；测试在 `study_lab` 下直接拒绝运行 |
| 2 | `package.json` 的 `start`/`backup` 指向不存在的文件 | 阻断 | 删除两个脚本；文档声明无 server 入口 |
| 3 | 只有负向用例；把删除全改 409 仍会绿 | 建议 | 新增正向删除、双 owner 降级、并发互删 3 个用例（7/7） |
| 4 | 修复前状态无法从工作树复现 | 建议 | 新增 [reproduce-before-fix.md](reproduce-before-fix.md)，给出三处回退 |
| 5 | README 与 handover 对“测试是否自建 schema”表述冲突 | 建议 | 统一：测试自建 schema；migrate 仅手动启动前使用 |
| 6 | 重跑 `run_project.sh` 会重写证据、使 manifest 哈希失效 | 建议 | README 明示需重新生成 manifest |

## 仍未解决（接收人视角）

- 测试令牌明文入库、登录无速率限制、无审计/备份；这些是快照设计，已列入 handover 风险。
- 回归测试仍只覆盖 3 个报告缺陷与 3 个正向/并发场景，未覆盖 PATCH 降级最后 owner 的全部并发组合。
- 证据文件带合成密码占位；重跑会改变哈希。
