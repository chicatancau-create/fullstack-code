# 接收人复核记录（2026-11-08）

## 0. 执行身份与边界

| 项 | 内容 |
| --- | --- |
| 复核任务 | P1-6 项目 05 人类接收人 |
| 执行者 | AI 助手代行，按「首个接手人」视角从零复跑 |
| 是否人类 | **否** |
| 与交付方关系 | 同源（非独立第三方） |

本文件是**待签字的复现底稿**：所有命令均实际执行、输出为真实采集，但「人类接收人独立复现」的验收属性
（`handover.md` 交接清单最后一项 `[ ]`）**仍未达成**，需真实开发者复跑后补签。

- 环境：Windows 11 + Git Bash；Node **v22.22.2**；PostgreSQL **18.6**（`D:/PostgreSQL/18`，服务 `postgresql-x64-18` Running）
- 仓库：`E:/fullstack-code`，`main`，HEAD `8f0d436`；本项目工作区执行前**干净**
- 时点：2026-11-08 15:38–15:45（+08:00）

## 1. 按 README 走的实际过程

README 给出的入口：

```bash
export PGHOST=127.0.0.1 PGUSER=study PGDATABASE=study_lab_p05 PGPASSWORD=study-pass
npm ci
node scripts/migrate.mjs
node --test tests/regressions.test.js
bash scripts/run_project.sh
```

### 1.1 前置：库与依赖

- `study_lab_p05` **已存在**（本机同时存在 `study_lab` 共享库），未执行 `createdb`；为验证 README 的
  「从空库跑起」是否真的成立，另建独立临时库 `study_lab_p05_rv` 实测：

  ```
  createdb study_lab_p05_rv        → exit 0
  PGDATABASE=study_lab_p05_rv node scripts/migrate.mjs
                                    → migrated tables=members,sessions,tasks,users,workspaces
  PGDATABASE=study_lab_p05_rv node --test tests/regressions.test.js
                                    → pass 12 / fail 0
  dropdb study_lab_p05_rv          → exit 0（已清理，库列表恢复原状）
  ```

  结论：**空库 → 迁移 → 12/12 全链路可用**，README 该步骤可信。

- `node_modules` 已存在，未重跑 `npm ci`（避免改动 lock 与目录）。

### 1.2 主流程

```bash
PGDATABASE=study_lab_p05 bash scripts/run_project.sh
→ 12/12 pass, fail 0, duration_ms 3246
→ TAKEOVER PASS
→ exit 0
```

**结果：[通过]**（但证据采集有缺陷，见第 2 节 N1）

## 2. 复现出的缺陷

### N1（主要，建议修）证据采集对 Node 版本静默降级

`run_project.sh` 用固定文本匹配提取测试计数：

```bash
tests=$(grep -E '^ℹ (tests|pass|fail) ' evidence/test.txt | tr '\n' ' ')
```

- 项目声明 `engines: node >= 24`，`evidence/toolchain.txt` 记录的采集环境是 **Node v24.15.0**，
  其 `node --test` 默认 reporter 输出 `ℹ tests 12` 风格（spec）；
- 本机为 **Node v22.22.2**，默认 reporter 输出 TAP：`1..12` / `# tests 12` / `ok 1 - ...`（无 `ℹ`）；
- 因此 `grep` 全部落空，`run.txt` 变成：

  ```
  captured_at: 2026-11-08T15:41:22+08:00
  tests=                       ← 空
  before_fix=ℹ pass 1 ℹ fail 3
  after_fix=ℹ pass 7 ℹ fail 0
  TAKEOVER PASS                ← 仍然 PASS，exit 0
  ```

**危害**：脚本没有校验 Node 版本，格式不兼容时不会报错，只是**静默产出残缺证据**，并照常打印 `TAKEOVER PASS`。
一份 `tests=` 为空的证据文件仍会进入 manifest、被下游当作「已验证」。这是**门禁说谎**，比测试失败更危险，
因为它不会引起任何人注意。

对照：`before_fix` / `after_fix` 两行仍有值，是因为它们读的是**早已存在的**历史文件，
正好掩盖了「本次采集失败」这一事实。

### N2（次要）同一份证据被写两次

- `scripts/d90_perf.mjs:87` 内部 `fs.writeFileSync('evidence/d90-perf.txt', ...)`；
- `scripts/run_project.sh:16` 又把同一脚本 stdout `tee` 到 `evidence/d90-perf-run.txt`。

实测 `cmp evidence/d90-perf.txt evidence/d90-perf-run.txt` → **内容完全相同**。
两个文件都进 manifest，等于同一事实记两遍，让「9 个 artifacts」显得比实际更充实。

### N3（已知项，非缺陷）重跑必然使 manifest 失效

执行 `run_project.sh` 后 `node scripts/manifest.mjs verify evidence/manifest.json` 报 5 处 `HASH MISMATCH`
（`toolchain/test/run/d90-perf/d90-perf-run`），exit 1。README 第 58 行已声明此行为并要求重新生成 manifest，
**属知情设计**，但缺少一键「重跑 + 重签 manifest」脚本，接手动重跑容易留下红 manifest。

## 3. 反向验证：修复是否真的有效

只看 `after-fix.txt` 不足以证明测试有牙齿——测试可能根本没覆盖该路径。做法：**抽掉一处修复，看测试是否变红**。

对象：T-01 会话过期。`src/app.js:36` 原为

```sql
WHERE s.token = $1 AND s.expires_at > now()
```

临时移除 `AND s.expires_at > now()` 后：

```
node --test --test-name-pattern="过期会话" tests/regressions.test.js
→ fail 1
→ Expected values to be strictly equal: 200 !== 401
→ exit 1
```

与 `evidence/before-fix.txt` 记录的 `200 !== 401` **完全一致**。

随即 `git restore` 还原，重跑完整回归：**12/12 pass，exit 0**，工作区回到干净。

结论：**T-01 的修复真实生效，对应测试不是空跑。** 该手法可复用于 T-02（应 200 !== 404）与 T-03（应 204 !== 409）。

## 4. 问题清单

| # | 问题 | 级别 | 证据 | 建议 |
| --- | --- | --- | --- | --- |
| N1 | Node 版本未校验，TAP/spec 格式差异导致 `run.txt` 的 `tests=` 静默为空，仍打印 PASS | **高（门禁说谎）** | 本次 `run.txt`；本机 v22.22.2 vs 声明 v24 | 见下方补丁 A |
| N2 | `d90-perf.txt` 与 `d90-perf-run.txt` 内容重复 | 低 | `cmp` 结果相同 | 见补丁 B |
| N3 | 重跑后 manifest 必然失效，无自动重签 | 低 | 5 处 HASH MISMATCH | 增加 `run_project.sh --resign` 或文档化步骤 |
| N4 | `evidence/toolchain.txt` 记录的 Node 版本（24.15.0）与本机不一致，但无任何告警 | 中 | 文件内容 | 由补丁 A 覆盖 |
| N5 | 手头无 server 入口，README 的 `npm ci && node scripts/migrate.mjs` 之后无「如何真正跑起来」的说明 | 低 | `handover.md` 已解释由调用方启动 | 补一个 `scripts/demo.mjs` 示例 |

已核对并**未发现**问题的项：`before-fix.txt` 的 1 pass / 3 fail 与 README 声明一致；三个缺陷的断言目标
（401/404/409）与 `docs/handover.md` 描述一致；`migrations/002_task_events.sql` 存在且被 manifest 收录。

## 5. 建议补丁（交交付方决定，本次未改代码）

**补丁 A — 版本前置校验 + 计数兼容**（修 N1/N4）

```bash
# run_project.sh 顶部，PGPASSWORD 检查之前
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
if [ "$NODE_MAJOR" -lt 24 ]; then
  echo "需要 Node >= 24（当前 $(node -v)）：低版本 reporter 输出 TAP，会破坏证据采集" >&2
  exit 3
fi
```

```bash
# 计数提取改为兼容两种 reporter
tests=$(grep -E '^([ℹ#] ?)(tests|pass|fail) ' evidence/test.txt | tr '\n' ' ')
```

两者建议同时做：只加版本校验会把低版本用户挡在门外；只改匹配则会掩盖「证据环境与声明不符」。

**补丁 B — 去掉重复证据**（修 N2）

`run_project.sh:16` 改为不 tee（让脚本自己写 `d90-perf.txt`），或反之，二者只留一个，并同步删掉 manifest 中的冗余条目。

## 6. 本次执行对仓库的影响

- 执行 `run_project.sh` 覆盖了 5 个证据文件，已用 `git restore -- project05-takeover/evidence/` **全部还原**；
- 反向验证修改过 `src/app.js` 一行，已 `git restore` **还原**；
- 收尾核验：`git status --short` 为空；`manifest verify` → `manifest OK: P05, 9 artifacts`；
  完整回归 12/12；
- 临时库 `study_lab_p05_rv` 已 `dropdb`；无残留进程、无残留临时文件。

**净变更：仅新增本文件。**

## 7. 结论

- 按 README 能跑起来，12/12 全绿，三个报告缺陷的修复**经反向验证真实有效**；
- 但「证据链」本身有一个会静默说谎的环节（N1）：在低于声明版本的 Node 上，脚本会产出残缺证据并报告 PASS；
- 交接清单第 5 项「真实接收人独立复现」**仍为未完成**，本文件只能作为底稿。

建议合并前先修 N1，再让真实接收人签字。

## 8. 交付方处置（复核后）

- N1 **已修**：`scripts/run_project.sh` 增加 Node ≥ 24 前置校验（exit 3），计数提取兼容 `ℹ `（spec）与 `# `（TAP）两种 reporter，提取为空时直接 `TAKEOVER FAIL`（exit 4）。
  本机实测：伪造 v22.22.2 → exit 3；Node v24.15.0 → `tests=ℹ tests 12 ℹ pass 12 ℹ fail 0`、`TAKEOVER PASS`、exit 0。
- N2/N3/N5 **未改**，保留为已知项；N4 由 N1 的前置校验覆盖。

## 9. 签署

> 由 AI 代行执行，不具独立第三方属性。请真实接收人复跑第 1、3 节后签署。

- 接收人姓名：______________________
- 身份：同学 / 同事 / 外部开发者（圈选）
- Node 版本：____________　PostgreSQL 版本：____________
- 实际复跑结果：`run_project.sh` exit ____，测试 ____/12
- 我独立发现的问题：____________________________________________
- 日期：______________________
- 签名：______________________
