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
export PGHOST=127.0.0.1 PGUSER=study PGDATABASE=study_lab_p05 PGPASSWORD=study-pass
npm ci
node scripts/migrate.mjs          # 手动运行用；测试会自行 drop/create schema
node --test tests/regressions.test.js
bash scripts/run_project.sh     # 默认使用独立库 study_lab_p05
```

> 测试库：默认 `study_lab_p05`，测试会 `DROP SCHEMA p02` 后重建；**不要指向共享的 `study_lab`**。
> 需要先创建库：`createdb -h 127.0.0.1 -U study study_lab_p05`。

## 修复前后

- 修复前：4 个测试中 **1 pass / 3 fail**（基线通过，三个报告缺陷复现）。
- 修复后（当时）：**7/7 pass**（新增正向删除、降级与双 owner 并发用例）；当前含 D88/D89 为 **12/12**。
- 接手增量：新增批量状态更新与任务事件审计，回归扩到 **12/12**（含 D88/D89 五条）。
- 修复点：恢复会话过期条件、任务列表成员校验、删除成员时的最后 owner 保护（行锁事务内）。
- 详细根因与取舍见 [docs/fix-log.md](docs/fix-log.md)；交接说明见 [docs/handover.md](docs/handover.md)。

## 接手增量（D88–D90）

- **D88 有界功能**：`PATCH /workspaces/:id/tasks/batch`，最多 50 项，逐项返回 `ok/error/changed`；
  跨工作区返回 `not_found`，同状态重复提交幂等。设计与取舍见 [docs/rfc-d88-batch-status.md](docs/rfc-d88-batch-status.md)。
- **D89 兼容迁移**：`migrations/002_task_events.sql` 追加任务事件表并回填初始事件；
  兼容矩阵与回滚限制见 [docs/d89-compatibility.md](docs/d89-compatibility.md)。
- **D90 性能定位**：10,000 行状态过滤的索引/顺序扫描对照，以及 50 条逐条更新 vs 集合更新；
  原始计划与耗时见 [evidence/d90-perf.txt](evidence/d90-perf.txt)，结论与限制见 [docs/d90-performance.md](docs/d90-performance.md)。

## 证据

- [evidence/before-fix.txt](evidence/before-fix.txt)：失败测试原始输出。
- [evidence/after-fix.txt](evidence/after-fix.txt)：修复后全绿（历史 4/4；当时扩到 7/7；当前回归 12/12）。
- [docs/reproduce-before-fix.md](docs/reproduce-before-fix.md)：在临时副本中回退三处校验以复现 1/3 fail。
- [evidence/test.txt](evidence/test.txt) 与 [evidence/run.txt](evidence/run.txt)：脚本复跑结果（12/12）。
- [evidence/d90-perf.txt](evidence/d90-perf.txt)：D90 执行计划与耗时。
- 重跑 `run_project.sh` 会重写这些证据文件并改变 manifest 哈希；需要重新生成 manifest。

## 未完成 / 未验证

- 没有真实接收人复现，不能声称团队交接通过。
- 只演练 3 个缺陷；未覆盖并发删 owner（当前实现有行锁，但本轮测试是顺序场景）。
- 未修复项：登录无速率限制、无分页、无备份恢复、无部署；审计仅覆盖任务状态变更。
- 快照来自本人项目，不能代表陌生大型代码库的接手难度。
