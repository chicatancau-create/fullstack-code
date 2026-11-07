# 项目 02 契约的 Java/Spring Boot/MySQL 迁移版

把项目 02 的认证、组织、成员、任务主路径迁移到 Java 技术栈，用同一套 API 语义验证跨栈能力。
这是**有界迁移**，不是重写整个产品；前端、邀请、最后 Owner 并发保护等未迁移。

## 技术栈（实测）

- JDK 25.0.2、Maven 3.9.16
- Spring Boot 3.5.16（Spring MVC + Spring Security 6.5.11 + JdbcTemplate + HikariCP）
- MySQL 8.4.13 LTS，便携版运行在 `127.0.0.1:3307`，无 Windows 服务、无开机自启
- JUnit 5 + MockMvc；真实 MySQL，无 H2/内存替身

## 与 Node 版的对齐范围

| 能力 | Node/Fastify（项目 02） | Java/Spring（本目录） |
| --- | --- | --- |
| 注册/登录/登出 | 201/200/204 | 201/200/200 |
| 会话 | 不透明令牌，哈希入库，TTL | 同左（12h） |
| 组织创建 | 201，创建者 owner | 同左 |
| 成员添加/列表 | owner/admin 规则 | owner 规则（子集） |
| 任务创建/列表 | 201，租户隔离，标题唯一 | 同左 |
| 跨租户访问 | 404 | 404 |
| 重复标题/成员 | 409 | 409 |
| 最后 Owner 并发保护 | 有（行锁 + 测试） | **未迁移** |
| 邀请流程 | 有 | **未迁移** |

## 运行

先启动便携 MySQL（已初始化，数据目录 `D:/MySQL/data`）：

```bash
D:/MySQL/server/bin/mysqld --basedir=D:/MySQL/server --datadir=D:/MySQL/data \
  --port=3307 --bind-address=127.0.0.1 --mysqlx=0 --console
```

再运行：

```bash
export DB_PASSWORD=study-pass          # 仅本地合成密码
mvn -B -ntp test
bash scripts/run_project.sh            # 测试 + 打包 + HTTP 冒烟 + JVM/MySQL 诊断
mvn spring-boot:run                    # http://127.0.0.1:8798
```

`schema.sql` 在启动时幂等建表；测试库为 `p02j_test`，运行库为 `p02j`。

## 证据

- [evidence/test.txt](evidence/test.txt)：`Tests run: 5, Failures: 0, Errors: 0`，真实 MySQL；含 actuator 鉴权测试。
- [evidence/security.txt](evidence/security.txt)：Spring Security 6.5.11（config/core/web）依赖树。
- [evidence/http.txt](evidence/http.txt)：health、注册、登录、建组织、建任务、列表、未登录 401。
- [evidence/jvm.txt](evidence/jvm.txt)：JVM 版本、G1 堆使用、线程快照（含 Hikari 与 MySQL 清理线程）。
- [evidence/mysql.txt](evidence/mysql.txt)：MySQL 8.4.13、`max_connections=151`、表行数。
- [evidence/diagnose.txt](evidence/diagnose.txt)：40 并发读 40/40 200；Hikari `max=10`、`idle=10`、采样时 `active=0`；
  第二个会话行锁等待 2s 超时（ERROR 1205），`performance_schema.data_locks` 显示 `X,REC_NOT_GAP`。
- [evidence/locks.txt](evidence/locks.txt)：锁等待原始错误。
- [evidence/run.txt](evidence/run.txt)：本轮时间与汇总。

## 已知限制

- Spring Security 仅用于无状态过滤链、CSRF 关闭与入口点；角色仍由业务 SQL 判定，未使用方法级 `@PreAuthorize`。
- 未使用 Testcontainers（本机无 Docker）；测试依赖手工启动的 3307 实例。
- 未做持续连接池耗尽压测、死锁注入与 `EXPLAIN` 对比；已有单次行锁等待与 Hikari 配置快照。
- 未迁移邀请、最后 Owner 并发保护、审计、备份恢复；这些仍以 Node/PostgreSQL 版为准。
- 未实现 Express/Nest 对照实现；[migration-comparison.md](docs/migration-comparison.md) 中的框架对比是分析，不是实测。
- Windows Git Bash 下用 `curl -d` 传中文 JSON 会被按本地代码页转换并导致 400；冒烟脚本使用 ASCII 字段。
- 便携 MySQL 不注册服务，重启机器后需手动启动；未做生产部署与备份。
