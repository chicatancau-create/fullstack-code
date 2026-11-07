# 项目 01 自审记录

- 日期：2026-11-07
- 范围：`src/`、`tests/`、`e2e/`、README/ADR
- 方式：自审 + AI 辅助复审；不是外部评审，也不是团队协作

## 检查项

| 风险 | 结论 | 证据 |
| --- | --- | --- |
| Markdown XSS（`<script>` / `javascript:`） | 通过：无原始 HTML、无 `dangerouslySetInnerHTML` | `tests/app.test.tsx` |
| 搜索状态丢失/不可分享 | 通过：迁移到 `?q=` | `docs/bugs/001-search-state.md`、测试 |
| 键盘跳转链接 | 通过：Tab → Enter → main 获得焦点 | E2E `skip_focus=main` |
| 导航当前页 | 通过：`aria-current="page"` | 测试 |
| 404 | 通过 | 测试 |
| 生产构建 | 通过 | `evidence/build.txt` |
| 测试隔离 | 初次失败：未 cleanup 导致重复渲染；已修 | `tests/setup.ts` |
| 列表计数 | 初次把导航 li 算进文章数；已改为 `.post-list li` | 测试 |

## 未覆盖/残留

- 没有后端/数据库/认证；内容静态打包。
- 没有 SSR/SSG、代码分割、性能预算；JS 382 kB/gzip 120 kB。
- E2E 只跑 Edge headless；没有 Firefox/Safari、真实手机、读屏。
- 搜索是简单子串匹配；没有分词/高亮/服务端搜索。
- 未部署公网；没有 HTTPS/CDN/缓存头/监控。
- 没有外部评审；AI 复审意见需逐条验证。
