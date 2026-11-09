# ADR 001：回归测试使用独立数据库

## 状态
已采纳（2026-11-08）

## 背景
回归测试为重建 schema 会执行 `DROP SCHEMA p02 CASCADE`。快照默认 `study_lab`，与其他项目共享，误跑会清空他人数据。

## 决策
测试与 `run_project.sh` 默认使用 `study_lab_p05`；若 `PGDATABASE=study_lab`，测试启动即拒绝执行。

## 代价
需要预先建库与授权；CI 也必须单独提供该库。

## 回滚
若改为每测试事务回滚，可移除独立库，但需重写 schema 初始化方式。
