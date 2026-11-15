import { spawn, execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const BASE = 'http://127.0.0.1:4187';
const EDGE = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
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
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'habit-ov-'));
let child, cdp;
try {
  child = spawn(EDGE, ['--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`, '--no-first-run', '--no-default-browser-check', '--disable-gpu', '--window-size=1280,900'], { stdio: 'ignore' });
  let port = 0;
  for (let i = 0; i < 60; i++) { if (child.exitCode !== null) throw new Error('exited ' + child.exitCode);
    try { const p = Number(fs.readFileSync(path.join(profile, 'DevToolsActivePort'), 'utf8').split('\n')[0].trim()); if (p > 0) { port = p; break; } } catch (e) {} await sleep(500); }
  const v = await getJSON(`http://127.0.0.1:${port}/json/version`);
  cdp = new CDP(v.webSocketDebuggerUrl); await cdp.connect();
  const { targetId } = await cdp.send('Target.createTarget', { url: 'about:blank' });
  const PG = (await cdp.send('Target.attachToTarget', { targetId, flatten: true })).sessionId;
  await cdp.send('Page.enable', {}, PG); await cdp.send('Runtime.enable', {}, PG);
  const evl = async (e) => { const r = await cdp.send('Runtime.evaluate', { expression: e, returnByValue: true, awaitPromise: true }, PG);
    if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description || r.exceptionDetails.text); return r.result.value; };
  await cdp.send('Page.navigate', { url: BASE + '/#/login' }, PG); await sleep(1500);
  await evl(`localStorage.setItem('habit-token','xiaok');localStorage.setItem('habit-user','xiaok')`);
  for (const w of [1280, 1024, 960, 901, 820]) {
    await cdp.send('Emulation.setDeviceMetricsOverride', { width: w, height: 900, deviceScaleFactor: 1, mobile: false }, PG);
    await cdp.send('Page.navigate', { url: BASE + '/#/' }, PG); await sleep(1300);
    console.log(`\n### vw=${w}`);
    console.log(await evl(`(() => {
      const out = [];
      [...document.querySelectorAll('.habit-row')].forEach((row, i) => {
        const s = row.querySelector('.stats'), a = row.querySelector('.row-actions');
        const sr = s.getBoundingClientRect(), ar = a.getBoundingClientRect();
        const inner = [...s.children].map(c => c.getBoundingClientRect().right);
        const contentRight = Math.max(...inner);
        out.push('row' + i + ' statsBox=' + Math.round(sr.left) + '..' + Math.round(sr.right) +
          ' contentRight=' + Math.round(contentRight) + ' actionsLeft=' + Math.round(ar.left) +
          ' 内部溢出=' + Math.round(contentRight - sr.right) +
          (contentRight > ar.left ? '  <== 被操作列盖住 ' + Math.round(contentRight - ar.left) + 'px' : ''));
      });
      const row0 = document.querySelector('.habit-row');
      out.push('row0 grid=' + getComputedStyle(row0).gridTemplateColumns + '  overflow=' + getComputedStyle(row0.querySelector('.stats')).overflow);
      return out.join('\\n'); })()`));
  }
  cdp.close();
} finally {
  if (child) { try { execFileSync('taskkill', ['/PID', String(child.pid), '/T', '/F'], { stdio: 'ignore' }); } catch (e) {} }
  try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 5, retryDelay: 300 }); } catch (e) {}
}
process.exit(0);
