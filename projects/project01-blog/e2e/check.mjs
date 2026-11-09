import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { launchBrowser } from './headless.mjs';

const PORT = 4173;
const BASE = `http://127.0.0.1:${PORT}`;
const evidence = path.resolve('evidence');
fs.mkdirSync(evidence, { recursive: true });
const axeSource = fs.readFileSync('node_modules/axe-core/axe.min.js', 'utf8');
const AXE_TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

const server = spawn(process.execPath, ['node_modules/vite/bin/vite.js', 'preview', '--port', String(PORT), '--strictPort', '--host', '127.0.0.1'], {
  stdio: ['ignore', 'pipe', 'pipe'],
});
server.stdout.resume();
server.stderr.resume();

async function waitForServer() {
  const end = Date.now() + 20000;
  while (Date.now() < end) {
    try {
      const response = await fetch(BASE);
      if (response.ok) return;
    } catch { /* 还没起来 */ }
    await new Promise((resolve) => setTimeout(resolve, 150));
  }
  throw new Error('preview 未就绪');
}

async function axe(page) {
  return page.eval(`(async () => {
    const r = await axe.run(document, { runOnly: { type: 'tag', values: ${JSON.stringify(AXE_TAGS)} } });
    return { violations: r.violations.map(v => ({ id: v.id, impact: v.impact, nodes: v.nodes.length })), incomplete: r.incomplete.length, passes: r.passes.length };
  })()`);
}

let browser;
try {
  await waitForServer();
  browser = await launchBrowser({ port: 9448 });
  const { page } = browser;
  await page.cdp.send('Page.addScriptToEvaluateOnNewDocument', { source: axeSource });

  await page.viewport(1280, 900);
  await page.goto(`${BASE}/`);
  const heading = await page.eval("document.querySelector('h1')?.textContent");
  if (heading !== '学习笔记') throw new Error(`首页标题错误: ${heading}`);
  const count = await page.eval("document.querySelectorAll('.post-list li').length");
  if (count !== 5) throw new Error(`列表数量错误: ${count}`);
  const homeAxe = await axe(page);

  await page.key('Tab');
  const first = await page.eval("document.activeElement?.textContent");
  if (first !== '跳到主要内容') throw new Error(`第一次 Tab 不是跳转链接: ${first}`);
  await page.key('Enter');
  const active = await page.eval('document.activeElement?.id');
  if (active !== 'main') throw new Error(`跳转后焦点不在 main: ${active}`);

  await page.eval("document.getElementById('search').focus()");
  await page.type('HTTP');
  await page.waitFor("document.body.innerText.includes('1 篇笔记')", { timeout: 5000 });
  await page.eval("document.querySelector('a[href=\"/posts/http-cache\"]').focus()");
  await page.key('Enter');
  await page.waitFor("document.querySelector('h1')?.textContent.includes('HTTP 缓存')", { timeout: 5000 });
  const postAxe = await axe(page);
  await page.shot(path.join(evidence, 'e2e-post.png'));

  await page.viewport(320, 720);
  await page.goto(`${BASE}/`);
  const mobile = await page.eval(`(() => {
    const de = document.documentElement;
    return Math.max(de.scrollWidth, document.body.scrollWidth) - innerWidth;
  })()`);
  const zoom = await page.eval(`(() => {
    document.documentElement.style.fontSize = '200%';
    const de = document.documentElement;
    return Math.max(de.scrollWidth, document.body.scrollWidth) - innerWidth;
  })()`);
  if (mobile > 0 || zoom > 0) throw new Error(`320/200% 溢出 mobile=${mobile} zoom=${zoom}`);

  const bad = [...homeAxe.violations, ...postAxe.violations].filter((v) => v.impact === 'serious' || v.impact === 'critical');
  if (bad.length > 0) throw new Error(`axe serious/critical: ${bad.map((v) => v.id).join(',')}`);

  fs.writeFileSync(path.join(evidence, 'axe.json'), JSON.stringify({ home: homeAxe, post: postAxe }, null, 2) + '\n');
  const lines = [
    `heading=${heading}`,
    `cards=${count}`,
    `first_tab=${first}`,
    `skip_focus=${active}`,
    'search=1 result',
    'navigate=/posts/http-cache',
    `axe_home=${homeAxe.violations.length} violations passes=${homeAxe.passes}`,
    `axe_post=${postAxe.violations.length} violations passes=${postAxe.passes}`,
    `mobile_overflow=${mobile} zoom_overflow=${zoom}`,
    'E2E PASS',
  ];
  fs.writeFileSync(path.join(evidence, 'e2e.txt'), lines.join('\n') + '\n');
  console.log(lines.join('\n'));
} catch (error) {
  console.error('E2E FAIL:', error.message);
  process.exitCode = 1;
} finally {
  if (browser) await browser.close();
  const exited = new Promise((resolve) => server.on('exit', resolve));
  server.kill('SIGTERM');
  await exited;
}