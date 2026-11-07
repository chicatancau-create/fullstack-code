import { Link, useSearchParams } from 'react-router-dom';
import { searchPosts } from './posts';

export function Home() {
  const [params, setParams] = useSearchParams();
  const query = params.get('q') ?? '';
  const results = searchPosts(query);

  return (
    <section aria-labelledby="home-title">
      <h1 id="home-title">学习笔记</h1>
      <p className="lede">关于网络、可访问性与系统调试的短笔记。</p>

      <div className="search">
        <label htmlFor="search">搜索笔记</label>
        <input
          id="search"
          type="search"
          value={query}
          placeholder="标题、标签或摘要"
          onChange={(event) => {
            const next = event.target.value;
            setParams(next ? { q: next } : {});
          }}
        />
      </div>

      <p role="status">{results.length} 篇笔记</p>

      {results.length === 0 ? (
        <p role="status">没有匹配的笔记，换个关键词试试。</p>
      ) : (
        <ul className="post-list">
          {results.map((post) => (
            <li key={post.slug}>
              <h2><Link to={`/posts/${post.slug}`}>{post.title}</Link></h2>
              <p>{post.summary}</p>
              <p className="meta"><time dateTime={post.date}>{post.date}</time> · {post.tags.join(' / ')}</p>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}