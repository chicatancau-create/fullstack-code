import { launchBrowser } from './headless.mjs';

const url = process.argv[2] || 'https://chicatancau-create.github.io/learning-blog-demo/';
const browser = await launchBrowser({ port: 9451 });
try {
  await browser.page.viewport(1280, 900);
  await browser.page.goto(url + 'posts/http-cache');
  await browser.page.waitFor("document.querySelector('h1')?.textContent.includes('HTTP 缓存')", { timeout: 10000 });
  const heading = await browser.page.eval("document.querySelector('h1')?.textContent");
  console.log('heading=' + heading);
  console.log('PUBLIC DEEP LINK PASS');
} finally {
  await browser.close();
}
