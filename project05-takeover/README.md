# 项目 05：受控仓库接手演练

> **边界声明**：本项目不是真实他人代码，也不是真实团队交接。仓库由本人项目 02 的快照注入 3 个缺陷构成，
> 用于演练“失败先行 → 定位 → 修复 → 回归 → 交接”的流程；不会伪装成外部系统或真实事故。

## 演练方式

1. 接收冻结快照 `src/app.js`（无原项目文档），只读代码与运行命令。
2. 按“用户报告”写回归测试，先得到 3 个失败（`evidence/before-fix.txt`）。
3. 逐项定位根因、最小修复，保留基线测试不回归（`evidence/after-fix.txt`）。
4. 输出交接文档：仓库地图、运行手册、风险清单、未修复项。

## 报告的问题

| ID | 现象 | 期望 |
| --- | --- | --- |
| T-01 | 会话过期后仍能访问 `/me` | 401 |
| T-02 | 非成员能读取其他工作区任务列表 | 404 |
| T-03 | 最后一名 owner 能删除自己，工作区变为 0 owner | 409 |

## 运行

```bash
export PGHOST=127.0.0.1 PGUSER=study PGDATABASE=study_lab PGPASSWORD=study-pass
npm ci
node scripts/migrate.mjs
node --test tests/regressions.test.js
bash scripts/run_project.sh     # 迁移 + 测试 + 证据
```

## 修复前后

- 修复前：4 个测试中 **1 pass / 3 fail**（基线通过，三个报告缺陷复现）。
- 修复后：**4/4 pass**。
- 修复点：恢复会话过期条件、任务列表成员校验、删除成员时的最后 owner 保护（行锁事务内）。
- 详细根因与取舍见 [docs/fix-log.md](docs/fix-log.md)；交接说明见 [docs/handover.md](docs/handover.md)。

## 证据

- [evidence/before-fix.txt](evidence/before-fix.txt)：失败测试原始输出。
- [evidence/after-fix.txt](evidence/after-fix.txt)：修复后全绿。
- [evidence/test.txt](evidence/test.txt) 与 [evidence/run.txt](evidence/run.txt)：脚本复跑结果。

## 未完成 / 未验证

- 没有真实接收人复现，不能声称团队交接通过。
- 只演练 3 个缺陷；未覆盖并发删 owner（当前实现有行锁，但本轮测试是顺序场景）。
- 未修复项：登录无速率限制、无审计、无分页、无备份恢复、无 CI/部署。
- 快照来自本人项目，不能代表陌生大型代码库的接手难度。
