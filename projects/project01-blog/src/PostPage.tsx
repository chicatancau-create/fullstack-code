import { useEffect, useRef } from 'react';
import { Link, useParams } from 'react-router-dom';
import { Markdown } from './Markdown';
import { findPost } from './posts';
import { NotFound } from './NotFound';

export function PostPage() {
  const { slug = '' } = useParams();
  const post = findPost(slug);
  const heading = useRef<HTMLHeadingElement>(null);

  useEffect(() => {
    heading.current?.focus();
  }, [slug]);

  if (!post) return <NotFound />;

  return (
    <article aria-labelledby="post-title">
      <h1 id="post-title" tabIndex={-1} ref={heading}>{post.title}</h1>
      <p className="meta"><time dateTime={post.date}>{post.date}</time> · {post.tags.join(' / ')}</p>
      <Markdown>{post.content}</Markdown>
      <p className="back"><Link to="/">返回首页</Link></p>
    </article>
  );
}