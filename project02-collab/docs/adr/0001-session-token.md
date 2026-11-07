# ADR 0001：不透明会话 token 存 PostgreSQL

- 状态：接受
- 日期：2026-11-07

## 背景

需要认证、注销和服务端撤销；没有引入外部身份提供商。

## 选项

1. JWT 自包含：无状态，但注销/撤销需要额外黑名单，过期前无法立即失效。
2. 不透明随机 token + `sessions` 表：每次请求查库，可立即撤销。
3. Cookie 会话：需要 CSRF 防护与 SameSite 配置；当前 API 客户端用 Bearer。

## 决定

采用 2。token 为 24 字节随机值，存 `sessions(token,user_id,expires_at)`；`Authorization: Bearer`。

## 代价

- 每个请求一次 session 查询；高流量时可加缓存，但缓存又引入失效问题。
- 没有刷新 token/滑动过期；1 小时后需重新登录。

## 验证

测试覆盖 login/me/logout 后 401；没有测并发撤销/令牌泄露。
