# D89：兼容升级与迁移

## 变更

`migrations/002_task_events.sql` 新增 `p02.task_events` 追加表和两个索引，并为已有任务回填一条
`from_status = to_status = 当前状态` 的初始事件（每个任务只回填一次）。

## 旧新兼容矩阵

| 调用方 / 数据 | 旧版本行为 | 新版本行为 | 兼容性 |
| --- | --- | --- | --- |
| `PATCH /tasks/:taskId` | 更新状态，无审计 | 更新状态 + 写事件；响应多 `changed` | 兼容（新增字段，旧字段不变） |
| `PATCH /workspaces/:id/tasks/batch` | 404 | 逐项更新 | 新增能力 |
| 已有任务行 | 无事件 | 迁移回填一条同状态事件 | 追加，不改任务表 |
| 已有任务查询 | `SELECT id,title,status` | 同左 | 兼容 |
| 回滚到旧代码 | 可运行 | `task_events` 表保留但不再写入 | 向前兼容 |

## 验证

- `migrations/001` 后执行 `002`，在独立库 `study_lab_p05` 上通过。
- 回填使用 `DISTINCT ON (task.id)` + `NOT EXISTS`，多 owner 工作区也只回填一条。
- 002 可重复执行（`IF NOT EXISTS` + `NOT EXISTS`），不产生重复事件。
- 回滚限制：若已产生事件，旧代码不会读取；表保留不丢数据。若必须删除，先导出事件再 `DROP TABLE`。

## 未验证

- 未在旧版本进程与新表并存的滚动发布中验证；本项目为单实例本地服务。
- 未做大数据量迁移计时；回填仅按任务数线性扫描，10k 任务在 D90 初始化中瞬间完成。
