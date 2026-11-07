import { NavLink, Outlet, Link } from 'react-router-dom';

export function Layout() {
  return (
    <>
      <a className="skip" href="#main">跳到主要内容</a>
      <header className="site-header">
        <div className="wrap">
          <Link className="brand" to="/">学习笔记</Link>
          <nav aria-label="主导航">
            <ul>
              <li><NavLink to="/" end>首页</NavLink></li>
              <li><NavLink to="/about">关于</NavLink></li>
            </ul>
          </nav>
        </div>
      </header>
      <main id="main" tabIndex={-1}>
        <div className="wrap"><Outlet /></div>
      </main>
      <footer className="site-footer">
        <div className="wrap"><p>项目 01 · React/TS · 本地构建 · 无追踪脚本</p></div>
      </footer>
    </>
  );
}