import { spawn, execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const BASE = 'http://127.0.0.1:4187';
const EDGE = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const OUT = process.env.SHOT_DIR || fileURLToPath(new URL('../out', import.meta.url));
fs.mkdirSync(OUT, { recursive: true });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const getJSON = async (u) => (await fetch(u)).json();
class CDP {
  constructor(url) { this.url = url; this.id = 0; this.pending = new Map(); this.handlers = []; }
  connect() { return new Promise((res, rej) => { this.ws = new WebSocket(this.url); this.ws.onopen = res; this.ws.onerror = (e) => rej(new Error('ws ' + e.message));
    this.ws.onmessage = (raw) => { const m = JSON.parse(raw.data);
      if (m.id && this.pending.has(m.id)) { const { resolve, reject } = this.pending.get(m.id); this.pending.delete(m.id); m.error ? reject(new Error(m.error.message)) : resolve(m.result); }
      else if (m.method) for (const h of this.handlers) if (h.method === m.method && (!h.sessionId || h.sessionId === m.sessionId)) h.fn(m.params); }; }); }
  send(method, params = {}, sessionId) { const id = ++this.id; const p = { id, method, params }; if (sessionId) p.sessionId = sessionId;
    return new Promise((resolve, reject) => { this.pending.set(id, { resolve, reject }); this.ws.send(JSON.stringify(p)); }); }
  close() { try { this.ws && this.ws.close(); } catch (e) {} }
}
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'habit-shots-'));
let child, cdp;
try {
  child = spawn(EDGE, ['--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`, '--no-first-run',
    '--no-default-browser-check', '--disable-gpu', '--disable-backgrounding-occluded-windows', '--window-size=1280,900'], { stdio: 'ignore' });
  let port = 0;
  for (let i = 0; i < 60; i++) { if (child.exitCode !== null) throw new Error('exited ' + child.exitCode);
    try { const p = Number(fs.readFileSync(path.join(profile, 'DevToolsActivePort'), 'utf8').split('\n')[0].trim()); if (p > 0) { port = p; break; } } catch (e) {} await sleep(500); }
  const v = await getJSON(`http://127.0.0.1:${port}/json/version`);
  cdp = new CDP(v.webSocketDebuggerUrl); await cdp.connect();
  const { targetId } = await cdp.send('Target.createTarget', { url: 'about:blank' });
  const PG = (await cdp.send('Target.attachToTarget', { targetId, flatten: true })).sessionId;
  await cdp.send('Page.enable', {}, PG); await cdp.send('Runtime.enable', {}, PG);
  await cdp.send('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: 'light' }] }, PG);
  const evl = async (e) => { const r = await cdp.send('Runtime.evaluate', { expression: e, returnByValue: true, awaitPromise: true }, PG);
    if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description || r.exceptionDetails.text); return r.result.value; };
  const setVp = (w, h) => cdp.send('Emulation.setDeviceMetricsOverride', { width: w, height: h, deviceScaleFactor: 2, mobile: false }, PG);
  const shot = async (name) => { const { data } = await cdp.send('Page.captureScreenshot', { format: 'png' }, PG);
    const p = path.join(OUT, name); fs.writeFileSync(p, Buffer.from(data, 'base64')); console.log(name, fs.statSync(p).size, 'bytes'); };
  const goto = async (h) => { await cdp.send('Page.navigate', { url: BASE + h }, PG); await sleep(1600); };
  const click = async (pred) => {
    const box = await evl(`(() => { const b=[...document.querySelectorAll('button')].find(${pred}); if(!b||b.disabled) return null;
      b.scrollIntoView({block:'center'}); return 'queued'; })()`);
    if (!box) return false; await sleep(350);
    const r = await evl(`(() => { const b=[...document.querySelectorAll('button')].find(${pred}); const q=b.getBoundingClientRect(); return {x:q.left+q.width/2,y:q.top+q.height/2}; })()`);
    for (const t of ['mousePressed', 'mouseReleased']) await cdp.send('Input.dispatchMouseEvent', { type: t, x: r.x, y: r.y, button: 'left', clickCount: 1 }, PG);
    await sleep(450); return true;
  };

  await setVp(1280, 900);
  // 干净种子态：抹掉一切本地数据后重载，让应用自己重新播种
  await goto('/#/login');
  await evl(`localStorage.clear()`);
  await cdp.send('Page.reload', {}, PG); await sleep(2200);
  await shot('01-login.png');

  await evl(`localStorage.setItem('habit-token','xiaok');localStorage.setItem('habit-user','xiaok')`);
  await goto('/#/');
  console.log('board habits =', await evl(`document.querySelectorAll('.habit-row').length`));
  await shot('02-board.png');

  await goto('/#/stats');
  console.log('stats cards  =', await evl(`document.body.innerText.match(/习惯总数\\s*(\\d+)/)?.[1]`));
  await shot('07-stats.png');

  await goto('/#/about');
  await evl(`window.scrollTo(0,0)`); await sleep(400);
  await shot('09-about.png');

  // 删除二次确认态：只点第一次，不真正删除，数据不变
  await goto('/#/');
  await click(`b => b.innerText.trim()==='删除'`);
  await sleep(250);
  console.log('confirm row buttons =', await evl(`[...document.querySelectorAll('.row-actions')].filter(a=>a.querySelectorAll('button').length===1).length`));
  await shot('06-delete-confirm.png');
  await sleep(2600);   // 让确认态自动回退，避免把 UI 状态留在截图之外

  await setVp(390, 844);
  await goto('/#/');
  await evl(`window.scrollTo(0,0)`); await sleep(500);
  console.log('mobile habits =', await evl(`document.querySelectorAll('.habit-row').length`));
  await shot('11-mobile-board.png');
  await goto('/#/stats');
  await evl(`window.scrollTo(0,0)`); await sleep(500);
  await shot('12-mobile-stats.png');

  console.log('final check, habits =', await evl(`(() => { const d=JSON.parse(localStorage.getItem('xiji-habit-tracker-v1')); return d.habits.length; })()`));
  cdp.close();
} finally {
  if (child) { try { execFileSync('taskkill', ['/PID', String(child.pid), '/T', '/F'], { stdio: 'ignore' }); } catch (e) {} }
  try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 5, retryDelay: 300 }); } catch (e) {}
}
process.exit(0);
