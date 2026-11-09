export type Post = {
  slug: string;
  title: string;
  date: string;
  tags: readonly string[];
  summary: string;
  content: string;
};

export const posts: readonly Post[] = [
  {
    slug: 'http-cache',
    title: 'HTTP 缓存：max-age 与 ETag',
    date: '2026-11-01',
    tags: ['网络', 'HTTP'],
    summary: '新鲜期与验证器的分工，以及 304 为什么没有 body。',
    content: `# 新鲜期与验证器

\`Cache-Control: max-age=60\` 决定新鲜期；\`ETag\` 是验证器。

- 期内：直接用本地副本
- 过期：带 \`If-None-Match\` 询问
- 未变：返回 \`304\`

参考 [MDN HTTP 缓存](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Caching)。
`,
  },
  {
    slug: 'keyboard-path',
    title: '只用键盘走完主路径',
    date: '2026-11-03',
    tags: ['可访问性', '前端'],
    summary: '焦点顺序、跳转链接与错误提示的最小检查。',
    content: `# 键盘主路径

1. 第一次 \`Tab\` 到跳转链接
2. 焦点环必须可见
3. 错误提示用 \`role="alert"\`

不要用 \`outline: none\` 删除焦点。
`,
  },
  {
    slug: 'gdb-overflow',
    title: '用 gdb 定位一次越界写',
    date: '2026-11-05',
    tags: ['C', '调试'],
    summary: '守护页把越界变成 SIGSEGV，再定位到源码行。',
    content: `# 守护页 + gdb

\`\`\`c
arr[idx] = 123; // idx == len
\`\`\`

越界地址落在 \`PAGE_NOACCESS\`，gdb 输出 \`tests/fault_guard.c:78\`。
`,
  },
  {
    slug: 'sql-index',
    title: 'SQL 索引：最左前缀',
    date: '2026-11-06',
    tags: ['SQL', '数据库'],
    summary: '复合索引的列顺序为什么必须跟查询模式走。',
    content: `# 最左前缀

复合索引 \`(tenant, status, created_at)\` 能服务：

- \`WHERE tenant=? AND status=?\`
- \`ORDER BY created_at\`

但只查 \`status\` 通常用不上。用 \`EXPLAIN\` 看计划，不要凭感觉加索引。
`,
  },
  {
    slug: 'cors-preflight',
    title: 'CORS 预检：OPTIONS 先到',
    date: '2026-11-07',
    tags: ['网络', '浏览器'],
    summary: '非简单跨源请求为什么先发一次 OPTIONS。',
    content: `# 预检请求

带自定义头或非简单方法的跨源请求，浏览器会先发 \`OPTIONS\`。

- 预检失败：业务请求不会发出
- 预检成功：浏览器才发真实请求
- CORS 不是授权：服务端仍要做身份与对象级校验
`,
  },
];

export function findPost(slug: string): Post | undefined {
  return posts.find((post) => post.slug === slug);
}

export function searchPosts(query: string): readonly Post[] {
  const q = query.trim().toLowerCase();
  if (!q) return posts;
  return posts.filter((post) =>
    [post.title, post.summary, ...post.tags].some((text) => text.toLowerCase().includes(q)),
  );
}