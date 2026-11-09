# 迁移对照：Fastify/PostgreSQL → Spring Boot/MySQL

> 本页的 Java 部分有本仓库测试与运行证据；NestJS 部分只是对照分析，**未实现、未实测**。

## 运行模型

| 维度 | Fastify (Node 24) | Spring Boot 3.5 (JDK 25) |
| --- | --- | --- |
| 进程模型 | 单线程事件循环 + libuv 线程池 | 线程池（Tomcat，每请求一线程） |
| 启动 | 毫秒级 | 本机约 1.9s（实测日志） |
| 依赖注入 | 手工组装/插件 | 容器管理，构造器注入 |
| 请求校验 | JSON Schema（Fastify schema） | Bean Validation（本迁移版用手写校验） |
| 错误处理 | `setErrorHandler` | `@RestControllerAdvice` |
| 数据访问 | `pg` + 手写 SQL | JdbcTemplate + 手写 SQL |
| 迁移 | 自写 migrate 脚本 | 启动时 `schema.sql`（幂等 DDL） |
| 测试 | node:test + inject（无需端口） | JUnit + MockMvc（无需端口） |
| 连接池 | `pg.Pool` | HikariCP |
| 部署单元 | node + 源码/产物 | 可执行 jar + JVM |

## 本迁移实际遇到的差异

1. **状态码与响应形状**：Java 版创建接口显式返回 201，保持与 Node 契约一致；列表/错误体保持 `{error}`。
2. **时间与字符集**：MySQL 连接串需要 `serverTimezone=UTC&characterEncoding=utf8`；PostgreSQL 不需要。
3. **唯一约束错误**：MySQL 抛 `DuplicateKeyException`，Node 根据 `error.code = 23505` 判断；都映射为 409。
4. **会话实现**：两端都用不透明令牌 + SHA-256 哈希入库，避免 JWT 撤销问题。
5. **Windows 工具链**：Git Bash 下 `curl -d` 传中文 JSON 会被转成 GBK，导致服务端 400；Node 测试直接用 UTF-8 字符串，不受影响。跨栈冒烟应使用 ASCII 或 `--data-binary @utf8.json`。

## Express / Nest 对照（分析，未实测）

| 维度 | Express | NestJS | 本迁移的 Spring Boot |
| --- | --- | --- | --- |
| 结构 | 极简，约定少 | 模块/控制器/提供者，约定强 | 容器 + 注解，约定强 |
| 学习成本 | 低 | 中（装饰器、DI、RxJS 可选） | 中高（Spring 生态） |
| 校验 | 自行接 zod/Joi | DTO + class-validator | DTO + Bean Validation |
| 测试 | supertest | TestingModule + supertest | MockMvc + Spring Test |
| 类型安全 | TS 编译期 | TS 编译期 + 装饰器元数据 | Java 编译期 |
| 事务 | 手工 BEGIN/COMMIT | 手工或 TypeORM/Prisma | `@Transactional` |
| 适合 | 小服务、边缘 API | 中大型团队、明确分层 | 企业后端、强类型与生态集成 |

结论：本项目规模下，Fastify 最省代码；Spring Boot 的强类型、事务与诊断工具更完整，但启动与构建成本更高。
NestJS 处于两者之间，本页不声称已掌握 NestJS 运行时行为。

## 未验证

- NestJS 实现与对照测试。
- Testcontainers、Docker、CI。
- 高并发下 Tomcat 线程池、HikariCP、MySQL 锁等待的容量与调优。
- MySQL 复制、备份恢复、PITR。
