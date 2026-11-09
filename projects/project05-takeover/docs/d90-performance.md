# D90：性能定位报告

## 基线

- 数据：`study_lab_p05` 独立库，10,000 条任务，5,000 条 `done`，单一工作区。
- 环境：本机 PostgreSQL，单连接，数据已缓存；QEMU/容器不计入本报告。
- 原始输出：[evidence/d90-perf.txt](evidence/d90-perf.txt)。

## 诊断 1：状态过滤是否走索引

同一 SQL：

```sql
SELECT id, title, status FROM p02.tasks
WHERE workspace_id = $1 AND status = 'done' ORDER BY id;
```

| 计划 | 访问方式 | 执行时间 | Buffer |
| --- | --- | ---: | --- |
| 默认 | `Index Scan using p02_tasks_workspace_status_idx` + Sort | 1.04 ms | hit=79 |
| 强制关索引/位图 | `Seq Scan` + Sort | 1.37 ms | hit=74 |

单变量：仅切换 `enable_indexscan/enable_bitmapscan`，SQL、数据、连接不变。
结论：当前 10k 规模、全缓存下索引略快但差距小；索引仍避免全表过滤，规模增大时会拉开。
该结果不能外推为生产容量结论。

## 诊断 2：50 条状态更新的语句数

| 方式 | 3 轮耗时（ms） | 中位数 |
| --- | --- | ---: |
| 50 条逐条 `UPDATE`，同一事务 | 12.78, 11.17, 10.44 | 11.17 ms |
| 1 条 `UPDATE ... WHERE id = ANY($1)` | 1.41, 1.33, 1.02 | 1.33 ms |

单变量：同一批 50 个 id、同一事务边界、同一连接，只改“逐条 vs 集合”。
结论：集合更新约快 8 倍；但 D88 接口仍需逐项结果与逐项审计，因此保留逐项事务，
把集合更新作为后续“全成功才提交”的可选优化，不改变当前契约。

## 限制

- 全缓存、单机、单连接，未计网络/并发/锁竞争。
- 未做 100 万行、冷缓存、并发写、VACUUM 前后对比。
- 计划受统计信息影响；强制关索引只用于对照，不代表生产建议。
