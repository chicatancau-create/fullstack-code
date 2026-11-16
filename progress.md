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
| `Harmony/` | `MyApplication/`（606 个文件）；`yingye/`（2026-10-13 后新增） | 未受影响 |
| `Web/webgl自学/` | `浮空树脂小岛.html` 单文件实时 3D 沙盘（Three.js r169，全程序化贴图） | 2026-10-19 新增，headless Edge 实测可跑、无 console 报错 |
| `Web/node/` | Express + mysql2 课堂练习：app.js 挂 goods/cart/user 三路由，config/db.js 连本机 shopdb | 2026-11-16 归档，见下 |

## 提交记录

| 哈希 | 日期 | 说明 |
|---|---|---|
| `9d9762d` | 2026-09-18 | 首次提交：建立统一学习仓库并迁入既有练习 |
| `59ba534` | 2026-09-18 | 记录首次提交哈希与源码清点 |
| `18e82a1` | 2026-11-16 | chore(Web/node)：清理旧 node 练习文件 26 个 |
| `e8ae74e` | 2026-11-16 | feat(Web/node)：express+mysql2 商品/购物车/用户路由课堂练习 |

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

## 2026-10-19 仓库整理

本次只做「收口」：不改业务代码，把 git 跟踪范围与文档对齐到真实结构。**所有结论均为当日命令实测。**

### 发现并修复

| 问题 | 证据 | 处置 |
|---|---|---|
| `Harmony/yingye/` 完全没进任何文档 | 旧 README / progress 只写 `MyApplication`；而 `Harmony/.workbuddy-ai/memory/MEMORY.md` 记明 `yingye` 才是当前主工程 | README 补上两个工程，并标明 `yingye` 为主工程 |
| `MyApplication/src/` 是 `entry/src/main/ets/` 的**残缺副本**，却被 git 跟踪 | 3 个文件，SHA256 与 `entry/` 下同名文件逐一相同；`entry/` 有 12 个 ets，此目录只有 3 个 | `git rm --cached` 取消跟踪（磁盘文件保留，git 历史里仍可找回） |
| `MyApplication/.gitignore` 漏了 `.hvigor`、`.idea`、`local.properties`，导致构建缓存进了版本库 | `git ls-files` 在该项目下命中 **25 个** `.hvigor/cache`+`report` JSON，且每次构建都产生 diff 噪声 | 补齐忽略规则至与 `yingye/.gitignore` 一致；原 25 个文件 `git rm --cached` |
| 两个 Harmony 工程 `.gitignore` 规则不一致 | `MyApplication` 忽略 `/build`（实际不存在）、未忽略 `.hvigor`；`yingye` 反之 | 统一 |

### 验证（当日实跑）

- `Web/vue`：`npm run build` 通过（vite 8.3.4，30 modules，产出 `dist/`）。
- `Python`：`main.py` → `Hi, PyCharm`；`EnvironmentTest.py` → `Sum: 14`。
- `Cpp`：`g++ 15.2.0` 编译 `c.cpp`、`EnvironmentTest.c` 均成功，运行均输出 `Sum: 14`（临时产物已删，原 `c.exe`/`EnvironmentTestC.exe` 未动）。
- `git fsck --full`：无输出，仓库健康。

### 未处理（需本人决定，不擅自改动）

- **`yingye/entry/src/main/ets/pages/Index.ets` 有一处未完成的改动**：新增行 `.expandSafeArea({SafeAreaType })`
  引用了未导入的标识符，属半成品编辑，当前状态是 **git 未提交**。保留了原样。
- Harmony 两个工程**未做真实构建**：工程内无 `hvigorw` 包装脚本，只能在 DevEco Studio 里验证，本次未跑。
- `Harmony/MyApplication/oh-package-lock.json5` 有未提交改动（构建过程产生）。

## 2026-10-19 清理无用文件（当天第二轮）

用户确认只删「可再生」的东西，**备份、源码、记忆文件一律不动**。

| 删除 | 规模 | 为什么安全 |
|---|---|---|
| `Harmony/.workbuddy-ai/tmp/covers_raw/` | 19.22 MB / 12 张原图 | 成品 `music_cover_01~10.png` 已在 `yingye/.../resources/base/media/`，这里只是 1024×1024 中间产物 |
| `Harmony/MyApplication/src/` | 3 个 ets | 与 `entry/src/main/ets/` 同名文件逐字节相同，且 git 历史里仍可找回 |
| `Harmony/MyApplication/.preview/` | 0.53 MB / 105 文件 | 预览器缓存，DevEco 打开时自动重建 |
| `Harmony/MyApplication/.hvigor/` | 3.45 MB / 24 文件 | hvigor 构建缓存 |
| `Harmony/yingye/.hvigor/` | 4.79 MB / 21 文件 | 同上 |
| `Web/vue/dist/` | 0.09 MB | `npm run build` 产物 |

**刻意保留（删了不可恢复）**：`.workbuddy-ai/backup/`（git 重建前唯一回滚依据）、
`Harmony/.workbuddy-ai/memory/`（ArkTS 踩坑约定）、`Harmony/MyApplication/` 整个旧工程、
`Python/.venv`、`Web/vue/node_modules`、两个工程的 `oh_modules`。

### 验证

- 删除后 `Web/vue`（含当时新增的 `Movie.vue`/`MovieDetails.vue` 路由）`npm run build` 通过，exit 0。
- 随后再次删除 `dist/`，保持工作区干净。

## 2026-11-16 Web/node 课堂练习归档

- **结构**：`Web/node/` = app.js（express，端口 3000，挂 `/api/goods` `/api/cart` `/api/user`，含内联登录判断）+ goodsRouter/cartRouter/userRouter + `config/db.js`（mysql2 连接池，本机 shopdb）；`node_modules/` 不入库。
- **数据**：本机 MySQL `shopdb`，13 张表全带 `t_` 前缀（老师 dump 导入），`t_goods` 4 行（字段 id/title/content/imagePath/price）。
- **验收（当日实测）**：GET `/api/goods/list` → 200 四条；`/api/goods/1` → `{code:200, message:查询成功, data:华为P30}`；`/999` → `{code:404, 商品不存在}`；POST `/api/user/register` → 用户注册；POST `/api/cart/getCartById` `{"id":5}` → 查询用户ID是：5。
- **收口**：26 个旧练习文件删除入库（`18e82a1`）；新代码入库（`e8ae74e`）；goodsRouter.js 里旧 `.then` 版注释删除；六条踩坑记入 [errors.md](errors.md)，与本记录同笔 docs 提交。
- **已知边界（按用户要求保留原样）**：package.json 的 main 仍指向不存在的 index.js、无 start 脚本，启动用 `npx nodemon app`；`/:id` 用拼接 SQL（课堂写法，占位符数组写法课上后续再学）；**config/db.js 含本机数据库密码，仓库有公开远程（github/gitcode），推送前必须先处理**。

## 下一步

- [ ] Web/node 跟课继续（goods/cart/user 已连 MySQL，按课堂进度推进）
- [ ] 补完或撤回 `yingye/.../pages/Index.ets` 里的 `.expandSafeArea({SafeAreaType })` 半成品
- [ ] `Web/vue` 跟课继续（第 4 章 组件基础（下）：自定义指令已过，接下来是引用静态资源）
- [ ] 决定 `Cpp/` 要不要拆成 `C/` + `Cpp/`
- [x] ~~决定 git 怎么处理~~ → 已于 2026-10-13 重建历史（见上）
- [ ] E 盘上的唯一副本要挪走（这台机器还会再咬人）
