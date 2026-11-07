# Express 5 / NestJS 12 同契约对照

同一组 HTTP 行为分别用 Express 5.3.0 与 NestJS 12.4.0 实现，跑同一套 Node 测试，
并测量“应用构造 + 监听 + 关闭”的本机开销。用于比较生命周期、校验与错误链，不是业务产品。

## 运行

```bash
npm ci
npm run test:all        # tsc 编译 Nest -> node --test 同时跑两个框架
bash scripts/run_project.sh   # 测试 + 启动/关闭测量，写入 evidence/
```

## 共享契约（两边都必须一致）

| 场景 | 期望 |
| --- | --- |
| `GET /health` | 200 `{status:"ok"}` + `X-Content-Type-Options: nosniff` |
| `POST /echo {text}` | 200 `{text}` |
| `POST /echo {}` / 超长 / 多余字段 | 400 `{error:"invalid"}` |
| 非法 JSON | 400 `{error:"invalid"}` |
| `GET /boom`（同步抛错） | 500 `{error:"internal_error"}`，不泄露堆栈 |
| `GET /async-boom`（异步抛错） | 500 `{error:"internal_error"}` |
| 未知路径 / 错误方法 | 404 `{error:"not_found"}` |

## 实测差异

- **默认状态码**：Nest 的 `@Post` 默认 201，首次测试因此失败；显式 `@HttpCode(HttpStatus.OK)` 后才与 Express 的 200 一致。
  这属于框架默认约定，不是 bug。
- **校验**：Nest 用 DTO + `class-validator` + `ValidationPipe(whitelist, forbidNonWhitelisted)`，
  多余字段自动 400；Express 需手写字段与键数量检查，否则会默默接受 `admin: true`。
- **异常链**：Express 5 会自动捕获 async handler 的 rejection；Nest 需要全局 `ExceptionFilter` 把未知异常映射为统一错误体。
- **启动开销**（本机回环，5 次，含构造与监听；非进程冷启动）：
  Express 中位 0.67ms（首次 14.13ms）；Nest 中位 2.23ms（首次 60.02ms）。
  关闭中位：Express 0.14ms，Nest 0.23ms。
- **代码量**：Express 单文件约 50 行；Nest 需要模块、控制器、DTO、过滤器与 tsconfig，约 60 行 + 编译步骤。
- **测试方式**：两者都可用 `app.listen(0)` + 原生 fetch；Nest 的 `listen()` 返回 Promise，
  不能像 Express 那样假定同步返回 server，测量脚本为此做了分支。

## 证据

- [evidence/test.txt](../evidence/test.txt)：2 个顶层测试（每个框架一组断言）全部通过。
- [evidence/boot.txt](../evidence/boot.txt)：5 次采样与中位数。
- [evidence/versions.txt](../evidence/versions.txt)：Node/npm 与框架版本。
- [evidence/run.txt](../evidence/run.txt)：本轮时间与汇总。

## 未验证

- 两者都未接数据库、认证、限流或生产中间件；本对照只覆盖生命周期与错误链。
- 未做吞吐/并发压测、内存占用、冷启动（新进程）测量。
- 未做 Nest 的 Express/Fastify adapter 切换、拦截器/守卫/管道全链路。
