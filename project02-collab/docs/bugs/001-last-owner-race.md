# Bug 复盘 001：并发删除最后两个 Owner

- 日期：2026-11-07
- 严重度：高（数据不变量）
- 状态：已修复

## 现象

两个 Owner 同时请求删除自己，两个请求都返回成功，工作区最终 0 个 Owner。

## 根因

每个请求独立执行：

```sql
SELECT count(*) FROM p02.members WHERE workspace_id=$1 AND role='owner'; -- 都看到 2
DELETE FROM p02.members WHERE ...;
```

READ COMMITTED 下两个事务看不到对方未提交删除，删除不同行不冲突，写偏差提交。

## 修复

成员变更事务先 `SELECT id FROM p02.workspaces WHERE id=$1 FOR UPDATE`，再 count/删除；第二个事务等待，拿到锁后看到只剩 1 个 Owner，返回 409。

## 回归

测试并发删除两个 Owner：状态码排序 `[204,409]`，最终 `owner=1`。E07 保留无锁写偏差为对照。

## 遗留

没有测锁等待超时/死锁；未来多资源操作必须统一锁顺序。
