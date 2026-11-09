# P03 OWASP Top 10（2025）矩阵

> 复现与回归：`tests/security.test.js`（7 例）+ `tests/full.test.js`（OWASP 关键项）。
> 证据：`evidence/test.txt`、`evidence/fault-injection.txt`、`evidence/audit.txt`、`evidence/sbom.json`。

| 编号 | 风险 | 攻击面 | 实现 | 回归用例 | 结论 |
| --- | --- | --- | --- | --- | --- |
| A01 | 访问控制失效 | 详情/取消/发货/完成/退款/导出 | 所有订单查询与迁移按 `user_id` 过滤，跨用户 404 | 详情、取消、发货/完成/退款跨用户 | 已覆盖 |
| A02 | 安全配置错误 | 启动秘密、Header、CORS、调试 | 生产缺 `P03_API_KEY`/`P03_PROVIDER_SECRET` 直接拒绝启动；CSP/Frame/Permissions-Policy/CORP；Origin 白名单（`P03_ALLOWED_ORIGINS`），跨域 403 | 无秘密启动抛错；五个安全头；跨域 403/同源放行 | 已覆盖 |
| A03 | 供应链失效 | 依赖与镜像 | `npm sbom` 生成 CycloneDX；CI 固定 Node/镜像 tag；`npm audit` 结果留档 | `evidence/sbom.json`；`evidence/audit.txt`（本机 npmmirror 不支持 advisories 接口，如实留档） | 部分覆盖（审计受镜像限制） |
| A04 | 加密机制失效 | 回调验签、重放 | HMAC-SHA256 对**原始请求字节**验签；`timingSafeEqual`；5 分钟时间窗；事件指纹 | 重排/加空格篡改被拒，原始报文通过；过期 401；同事件异内容 409 | 已覆盖 |
| A05 | 注入 | SKU 查询、错误信息 | 全部参数化查询；500 不返回 SQL/异常细节 | `' OR 1=1 --` 返回 404 且不落单；畸形 JSON 400 | 已覆盖 |
| A06 | 不安全设计 | 状态机、金额、退款 | 7 态迁移矩阵；金额服务端计算；退款仅支付后回补一次 | 7×7 矩阵、退款回补、并发取消/支付 | 已覆盖 |
| A07 | 认证失效 | API Key、用户身份 | `timingSafeEqual` 比较 Key；用户 ID 正则校验；无浏览器会话 | 缺 Key/非法用户 401 | 已覆盖（Demo 无会话，撤销/限流不适用） |
| A08 | 完整性失效 | 事件重复/篡改 | `payment_events` 主键 + 指纹；Outbox 唯一键 | 重复投递不重复应用；同 ID 异内容 409 | 已覆盖 |
| A09 | 日志告警失效 | 审计、请求 ID | `audit_log` before/after + request_id；认证/验签/重放失败 `warn` 事件且不记录密钥原文；500 仅记 error_code | 认证失败日志含 `auth_failed`，不含密钥；`X-Request-Id` 回传 | 已覆盖 |
| A10 | 异常条件处理不当 | DB/MQ 超时、非法 ID | 统一错误体 + request_id；/ready 503；DB 不可达 500 且无半提交；RabbitMQ 不可达降级 DB Worker；Worker 重试/DLQ | 非法 ID 404；DB 断开/恢复；MQ 断开降级通知 | 已覆盖 |

## 明确不适用的检查

- CSRF：API 不使用 Cookie 会话，前端不携带 Cookie；跨域已由 Origin 白名单拒绝，故不适用。
- 点击劫持：接口只返回 JSON，CSP `frame-ancestors 'none'` + `X-Frame-Options: DENY`。
- 文件上传与开放重定向：本 Demo 无上传、无跳转参数，不适用。
- Redis 故障语义：本 Demo 未引入 Redis（`package.json` 无客户端依赖），以 RabbitMQ 不可用演练替代。
