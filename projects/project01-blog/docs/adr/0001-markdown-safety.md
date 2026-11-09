# ADR 0001：Markdown 安全渲染

- 状态：接受
- 日期：2026-11-07

## 背景

博客内容以 Markdown 存储，需要支持标题、列表、代码和链接，但不能让内容里的 `<script>` 或 `javascript:` 链接变成可执行代码。

## 选项

1. `marked` + `dangerouslySetInnerHTML` + DOMPurify：灵活，但需要正确配置 sanitizer；一旦漏配就是 XSS。
2. 自写 Markdown 子集解析器：可控，但维护成本高，容易漏边界。
3. `react-markdown` 默认渲染：不启用 `rehype-raw`，原始 HTML 不作为 HTML 插入；链接经默认 URL 转换。

## 决定

采用 3。`react-markdown` 只渲染安全子集；不安装 `rehype-raw`；不使用 `dangerouslySetInnerHTML`。

## 代价

- 不支持 Markdown 内嵌原始 HTML/复杂组件；需要时再引入经过审查的 sanitizer，并补测试。
- 复杂表格/脚注等扩展需要额外插件，届时单独评估。

## 验证

`tests/app.test.tsx`：`<script>` 不产生 script 元素；`javascript:` 链接不会保留为可执行 href。E2E 只验证正常内容，不替代安全测试。
