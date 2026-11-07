export function About() {
  return (
    <section aria-labelledby="about-title">
      <h1 id="about-title">关于这个博客</h1>
      <p>这是一个不使用后端的最小博客：内容来自本地 Markdown，搜索状态放在 URL 上。</p>
      <h2>设计取舍</h2>
      <ul>
        <li>Markdown 只渲染安全子集，不启用原始 HTML，不使用 <code>dangerouslySetInnerHTML</code>。</li>
        <li>搜索词放在 <code>?q=</code>，可分享、可前进后退；代价是 URL 会变长。</li>
        <li>移动优先、单列列表；桌面端限制阅读宽度。</li>
      </ul>
    </section>
  );
}