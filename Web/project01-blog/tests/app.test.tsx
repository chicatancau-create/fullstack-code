import { describe, expect, it } from 'vitest';
import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter, useLocation } from 'react-router-dom';
import { App } from '../src/App';
import { Markdown } from '../src/Markdown';

function Locations() {
  const location = useLocation();
  return <output data-testid="location">{location.pathname + location.search}</output>;
}

function renderAt(path: string) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <App />
      <Locations />
    </MemoryRouter>,
  );
}

describe('项目 01 博客', () => {
  it('首页列出五篇笔记', () => {
    const { container } = renderAt('/');
    expect(screen.getByRole('heading', { level: 1, name: '学习笔记' })).toBeInTheDocument();
    expect(container.querySelectorAll('.post-list li')).toHaveLength(5);
    expect(screen.getByText('5 篇笔记')).toBeInTheDocument();
  });

  it('搜索过滤并把 q 写入 URL', async () => {
    renderAt('/');
    fireEvent.change(screen.getByLabelText('搜索笔记'), { target: { value: 'HTTP' } });
    await waitFor(() => expect(screen.getByText('1 篇笔记')).toBeInTheDocument());
    expect(screen.getByTestId('location')).toHaveTextContent('?q=HTTP');
    expect(document.querySelectorAll('.post-list li')).toHaveLength(1);
  });

  it('无匹配显示空状态', async () => {
    renderAt('/');
    fireEvent.change(screen.getByLabelText('搜索笔记'), { target: { value: 'zzz' } });
    expect(await screen.findByText('没有匹配的笔记，换个关键词试试。')).toBeInTheDocument();
  });

  it('详情页渲染 Markdown 外链并移动焦点', async () => {
    renderAt('/posts/http-cache');
    const heading = await screen.findByRole('heading', { level: 1, name: /HTTP 缓存/ });
    expect(heading).toHaveFocus();
    const link = screen.getByRole('link', { name: 'MDN HTTP 缓存' });
    expect(link).toHaveAttribute('target', '_blank');
    expect(link).toHaveAttribute('rel', 'noreferrer noopener');
  });

  it('Markdown 不执行原始 HTML 或 javascript: 链接', () => {
    const { container } = render(<Markdown>{'<script>alert(1)</script>\n\n[bad](javascript:alert(1))'}</Markdown>);
    expect(container.querySelector('script')).toBeNull();
    const link = container.querySelector('a');
    if (link) expect(link.getAttribute('href') || '').not.toContain('javascript:');
  });

  it('未知路由显示 404', () => {
    renderAt('/nope');
    expect(screen.getByRole('heading', { level: 1, name: '页面不存在' })).toBeInTheDocument();
  });

  it('导航有 aria-current 与跳转链接', () => {
    renderAt('/about');
    expect(screen.getByRole('link', { name: '关于' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getByRole('link', { name: '跳到主要内容' })).toHaveAttribute('href', '#main');
  });
});