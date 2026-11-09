# Bug 001：回归测试会清空共享数据库

## 现象
测试在每个用例前执行 `DROP SCHEMA IF EXISTS p02 CASCADE` 后重建；若按 README 使用共享 `study_lab`，会删除其他项目/手工数据。

## 根因
测试初始化默认沿用应用库；文档未限定专用测试库，也没有防误跑保护。

## 修复
默认与 CI 改为 `study_lab_p05`；测试检测到 `PGDATABASE=study_lab` 时直接抛错；README/handover 写明建库与隔离要求。

## 回归
`PGDATABASE=study_lab_p05 node --test tests/regressions.test.js` → 7/7；共享库不再被测试触碰。

## 预防
破坏性测试必须在独立库/独立 schema；启动前校验目标库名。
