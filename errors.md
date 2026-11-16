# 错误清单

> 用途：记录**真实发生**的错误与排查过程。不写未发生的错误，不写助手代做的排查。
> 每条至少写清：现象 → 定位过程 → 根因 → 修法 → 复测结果。

## 记录模板

| 日期 | 语言/环境 | 现象（报错原文） | 定位过程 | 根因 | 修法 | 复测 |
|---|---|---|---|---|---|---|
| YYYY-MM-DD |  |  |  |  |  | 通过/未复测 |

## 历史记录

| 日期 | 语言/环境 | 现象（报错原文） | 定位过程 | 根因 | 修法 | 复测 |
|---|---|---|---|---|---|---|
| 2026-09-14 前 | Git | 提交时身份未配置导致失败 | 查看提交报错与 `git config` | `user.name` / `user.email` 未设置 | 配置本地仓库级用户信息 | 通过（提交 `7dfeb0a`） |
| 2026-09-14 前 | 文件路径 | 课程材料路径写错导致找不到文件 | 逐级确认目录与文件名 | 手工输入路径出错 | 用完整路径并核对目录层级 | 通过 |
| 2026-10-19 | Git / Harmony | 无报错，但每次构建后 `git status` 都冒出 `.hvigor/` 缓存 diff，干扰「有没有真的改动源码」的判断 | `git ls-files Harmony/MyApplication` 发现 25 个 `.hvigor/cache`、`.hvigor/report` 文件在版本库中 | `MyApplication/.gitignore` 只写了 `/build`，漏了 `.hvigor`（该工程真正的缓存目录名） | 补齐 `.hvigor`、`.idea`、`local.properties`、`**/build` 等规则；对这 25 个文件执行 `git rm --cached` | 通过（规则对齐 `yingye`，缓存不再进版本库） |
| 2026-10-19 | Git / Harmony | `MyApplication/src/` 长期存在但没人说得清用途，且**修改后不生效**（真正被编译的是 `entry/src/main/ets/`） | 逐文件 SHA256 比对：该目录 3 个文件与 `entry/` 下同名文件完全相同 | 编辑器按路径新建文件时落到了项目根 `src/`，而非模块内的 `entry/src/`；随后被误提交 | `git rm --cached -r` 取消跟踪（磁盘保留，历史仍可找回），并在 README 写明两个 Harmony 工程各自的入口 | 通过（`git ls-files` 该路径已无记录） |
| 2026-11-16 | Node / PowerShell | `nodemon : 无法加载文件 ...\nodemon.ps1，因为在此系统上禁止运行脚本` `UnauthorizedAccess / PSSecurityException` | 课堂机终端直接敲 `nodemon` 即报 | PowerShell 执行策略默认禁止 .ps1 | 改用 `npx nodemon app`（或 `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`） | 通过 |
| 2026-11-16 | Node / Express | `Error: Cannot find module './goodsRouter'` `MODULE_NOT_FOUND`，nodemon 崩溃 | 对照 app.js 的 require 与磁盘文件清单 | app.js 引用了 goodsRouter 但文件不存在 | 新建 goodsRouter.js（仿 cartRouter 的 Router 写法） | 通过 |
| 2026-11-16 | Node / Express | `ReferenceError: userRouter is not defined`（app.js:11） | 看 app.js：有 `app.use("/api/user", userRouter)` 无 require | 挂载路由前漏了导入 | 补 `const userRouter = require("./userRouter");` 一行 | 通过 |
| 2026-11-16 | Node / MySQL | `ER_PARSE_ERROR` errno 1064，sql `SELECT * FROM t_goods WHERE id=?1` | 看 goodsRouter.js 的 SQL 拼接 | `?` 占位符与字符串拼接混用，`?` 被当字面量 | 拼接写法去掉 `?`（占位符写法应配 `db.execute(sql, [id])`，二选一） | 通过 |
| 2026-11-16 | Node / MySQL | `Error: Table 'shopdb.goods' doesn't exist` errno 1146，一请求服务就退 | Navicat 核对真实表名 | 老师 dump 的表带 `t_` 前缀；`/list` 无 catch，错即崩进程 | SQL 表名 `goods`→`t_goods` | 通过（/list 返回 4 条） |
| 2026-11-16 | Node / Express | 启动即 `SyntaxError`，nodemon 等待文件变动 | 看 goodsRouter.js 的 res.send 参数 | 传对象时键值对没包 `{}` | 两处 `res.send(` 补花括号 | 通过（/1 → code 200；/999 → code 404 商品不存在） |

## 待复测

（暂无）
