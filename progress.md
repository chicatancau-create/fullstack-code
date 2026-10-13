# 进度记录

> 用途：记录这个学习仓库**已经做到哪一步**、当前结构是什么样、下一步做什么。
> 报错与排查过程写在 [errors.md](errors.md)，不写在这里。

> ⚠️ **本文件是 2026-10-12 重建的。** 原 `progress.md` 被整文件零填充（1907 字节全 `0x00`），
> 且它在 git 里的两个 blob 对象（`e2a7b7f7`、`804938ae`）同样被清零，**旧内容无法恢复**。
> 下面每一条都是重建当天用命令实测出来的，不是回忆。

## 当前结构（2026-10-12 实测）

| 目录 | 内容 | 状态 |
|---|---|---|
| `Web/vue/` | Vue 3 + Vite 课堂练习，`src/App.vue` 挂当前在写的那个案例 | 在用 |
| `Web/js自学/` | `javaScript基础语法.html`、`循环与数组.html` 两页可运行的笔记 | 2026-10-12 重写（原件丢失） |
| `Cpp/` | `c.cpp`（C++）+ `EnvironmentTest.c`（C），各自一个同名 exe | 可编译 |
| `Python/` | `main.py`、`EnvironmentTest.py` + `.venv` | venv 2026-10-12 重建 |
| `Harmony/` | `MyApplication/`（606 个文件） | 未受影响 |

## 提交记录

| 哈希 | 日期 | 说明 |
|---|---|---|
| `9d9762d` | 2026-09-18 | 首次提交：建立统一学习仓库并迁入既有练习 |
| `59ba534` | 2026-09-18 | 记录首次提交哈希与源码清点 |

`git log` 可读，但仓库有 **7 个 loose object 被清零**（见下），所以 `git reset` / 读 HEAD 树会失败。

## 关于「C/Cpp 目录放置颠倒」这条提示

旧提交信息里留了这个疑问。现在实测的结论是：**只有一个 `Cpp/` 目录，没有 `C/` 目录**
（`git status` 里那批 `D C/...` 就是当年把 `C/` 改名成 `Cpp/` 留下的记录）。
`Cpp/` 里同时放着 `EnvironmentTest.c`（C 源码）和 `c.cpp`（C++ 源码），
`.vscode/tasks.json` 两条都用 `g++.exe` 编译 —— 所以「颠倒」指的应该是 **C 文件混在 Cpp 目录里**，
不是目录名写反。要分干净就再建一个 `C/`，把 `.c` 挪过去。

## 2026-10-12 零填充事件与处置

- **现象**：`Web/vue` 里 `npm run dev` 报 `failed to load config ... SyntaxError: Invalid or unexpected token`，
  而 `vite.config.js` 本身干净。
- **判据**：数整文件的非零字节数（`sum(1 for b in data if b) == 0`），**不要看 mtime**，mtime 会骗人。
- **范围**：`E:\fullstack-code` 4787 个文件里 **715 个整文件全零**；`Python\.venv` 764 个里 658 个（86%）；
  `.git` 的 index + 7 个 object。
- **根因**：E:/F:/G: 三个分区都在同一块无 DRAM 缓存的 NVMe（YMTC PC41Q-1TB-B）上，
  近 30 天 **9 次 Kernel-Power 41 非正常关机**；`chkdsk E: /scan` 未发现一致性问题、坏扇区 0 KB，
  盘体 Wear=0。即「尺寸和目录项落了盘、数据页没落盘」。
- **处置**：删掉全零文件 → 能从 git blob 原样捞回的已捞回（`Web/vue/README.md`、`errors.md`、`Cpp/.vscode/tasks.json`）→
  可再生的重建（`node_modules` 重装、`.venv` 重建、两个 exe 重编译并跑通、`favicon.ico` 重生成）→
  丢内容的两处重写（`Web/js自学/` 两页、`progress.md` 本文件）。
- **确认无法恢复**：`Web\js自学` 两页的原始笔记、旧 `progress.md`、旧根 `README.md` 的历史版本。

## 2026-10-13 Git 仓库重建

- **背景**：10-12 事件中被清零的 7 个 git 对象内容不可恢复，`git fsck --full` 报
  `object corrupt or missing`；`git show` / `git diff --cached` / `git reset` 触及它们一律中断。
  损坏对象在 HEAD 中对应：`a6be4cfc`→`README.md`、`4461e111`→`js自学/javaScript基础语法.html`、
  `6183b501`→`js自学/循环与数组.html`、`1635963f`→`Web/vue/package-lock.json`、
  `df36fcfb`→`Web/vue/public/favicon.ico`、`e2a7b7f7`→`progress.md`，另有 dangling `804938ae`（更早的 progress.md）。
- **修法**：旧对象已无法修复，故**重建历史**。重建前把整个 `.git` 打包备份到
  `.workbuddy-ai/backup/dotgit-20261013.tar.gz`，旧提交信息与文件清单留存于 `.workbuddy-ai/backup/old-history.txt`。
- **顺带修复**：根 `README.md` 之前被 CodeWeave 项目的 vite 配置**误覆盖**，已按本仓库实际内容重写。
- **结果**：`git fsck` 干净、工作区一次性提交；旧提交 `9d9762d` / `59ba534` 不再存在于历史中。
- **回滚**：解压备份 tarball 覆盖回 `.git` 即可恢复到重建前状态。

## 下一步

- [ ] `Web/vue` 跟课继续（第 4 章 组件基础（下）：自定义指令已过，接下来是引用静态资源）
- [ ] 决定 `Cpp/` 要不要拆成 `C/` + `Cpp/`
- [x] ~~决定 git 怎么处理~~ → 已于 2026-10-13 重建历史（见上）
- [ ] E 盘上的唯一副本要挪走（这台机器还会再咬人）
