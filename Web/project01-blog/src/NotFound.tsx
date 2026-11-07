import { Link } from 'react-router-dom';

export function NotFound() {
  return (
    <section aria-labelledby="notfound-title">
      <h1 id="notfound-title">页面不存在</h1>
      <p>链接可能已失效，或者地址写错了。</p>
      <p><Link to="/">回到首页</Link></p>
    </section>
  );
}