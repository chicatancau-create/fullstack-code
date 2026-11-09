import ReactMarkdown from 'react-markdown';

export function Markdown({ children }: { children: string }) {
  return (
    <div className="markdown">
      <ReactMarkdown
        components={{
          a: ({ href, children: linkChildren }) => {
            const external = Boolean(href && /^https?:/.test(href));
            return (
              <a href={href} {...(external ? { rel: 'noreferrer noopener', target: '_blank' } : {})}>
                {linkChildren}
              </a>
            );
          },
        }}
      >
        {children}
      </ReactMarkdown>
    </div>
  );
}