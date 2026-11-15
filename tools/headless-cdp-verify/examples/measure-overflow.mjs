import { spawn, execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const BASE = process.env.VERIFY_BASE || 'http://127.0.0.1:4187';
const EDGE = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
const SIZES = [[390, 844], [480, 900], [720, 900], [901, 900], [1024, 900], [1280, 900]];
const ROUTES = ['/#/', '/#/stats', '/#/about', '/#/login'];
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
  on(method, fn, sessionId) { this.handlers.push({ method, fn, sessionId }); }
  close() { try { this.ws && this.ws.close(); } catch (e) {} }
}

const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'habit-measure-'));
let child, cdp;
try {
  child = spawn(EDGE, ['--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`, '--no-first-run', '--no-default-browser-check', '--disable-gpu', '--window-size=1280,900'], { stdio: 'ignore' });
  let port = 0;
  for (let i = 0; i < 60; i++) {
    if (child.exitCode !== null) throw new Error('browser exited code=' + child.exitCode);
    try { const p = Number(fs.readFileSync(path.join(profile, 'DevToolsActivePort'), 'utf8').split('\n')[0].trim()); if (p > 0) { port = p; break; } } catch (e) {}
    await sleep(500);
  }
  const v = await getJSON(`http://127.0.0.1:${port}/json/version`);
  cdp = new CDP(v.webSocketDebuggerUrl);
  await cdp.connect();
  const { targetId } = await cdp.send('Target.createTarget', { url: 'about:blank' });
  const PG = (await cdp.send('Target.attachToTarget', { targetId, flatten: true })).sessionId;
  await cdp.send('Page.enable', {}, PG);
  await cdp.send('Runtime.enable', {}, PG);
  const evl = async (e) => { const r = await cdp.send('Runtime.evaluate', { expression: e, returnByValue: true, awaitPromise: true }, PG);
    if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description || r.exceptionDetails.text); return r.result.value; };

  await cdp.send('Emulation.setDeviceMetricsOverride', { width: 1280, height: 900, deviceScaleFactor: 1, mobile: false }, PG);
  await cdp.send('Page.navigate', { url: BASE + '/#/login' }, PG);
  await sleep(1500);
  await evl(`localStorage.setItem('habit-token','xiaok');localStorage.setItem('habit-user','xiaok')`);

  let bad = 0;
  for (const [w, h] of SIZES) {
    await cdp.send('Emulation.setDeviceMetricsOverride', { width: w, height: h, deviceScaleFactor: 1, mobile: false }, PG);
    for (const route of ROUTES) {
      if (route === '/#/login') await evl(`localStorage.removeItem('habit-token')`);
      await cdp.send('Page.navigate', { url: BASE + route }, PG);
      if (route === '/#/login') { await evl(`localStorage.setItem('habit-token','xiaok');localStorage.setItem('habit-user','xiaok')`); }
      await sleep(1200);
      const m = await evl(`(() => { const de=document.documentElement;
        const over = de.scrollWidth - de.clientWidth;
        const wide = [...document.querySelectorAll('body *')].filter(e => { const r=e.getBoundingClientRect(); return r.right > de.clientWidth + 1 && r.width > 0; })
          .slice(0,4).map(e => e.tagName.toLowerCase()+'.'+(typeof e.className==='string'? e.className.trim().split(/\\s+/).slice(0,2).join('.') : '')+'@'+Math.round(e.getBoundingClientRect().right));
        const clipped = [...document.querySelectorAll('body *')].filter(e => e.scrollWidth - e.clientWidth > 2 && getComputedStyle(e).overflowX !== 'visible' && getComputedStyle(e).overflowX !== 'auto' && getComputedStyle(e).overflowX !== 'scroll')
          .slice(0,4).map(e => 'CLIP:'+e.tagName.toLowerCase()+'.'+(typeof e.className==='string'? e.className.trim().split(/\\s+/)[0] : ''));
        let cover = 0, coverAt = '';
        for (const row of document.querySelectorAll('.habit-row')) {
          const s = row.querySelector('.stats'), a = row.querySelector('.row-actions');
          if (!s || !a) continue;
          const ar = a.getBoundingClientRect();
          const sameLine = [...row.querySelectorAll('.identity,.cells,.stats,.row-actions')].some(e => { const r = e.getBoundingClientRect();
            return e !== a && !e.contains(a) && r.top < ar.bottom - 2 && r.bottom > ar.top + 2; });
          if (!sameLine) continue;
          for (const c of s.children) { const cr = c.getBoundingClientRect();
            if (cr.right > ar.left + 1 && cr.width > 0 && cr.top < ar.bottom - 2 && cr.bottom > ar.top + 2) {
              if (cr.right - ar.left > cover) { cover = cr.right - ar.left; coverAt = c.className + '→' + Math.round(cr.right - ar.left); } } }
        }
        return { over, hash: location.hash, wide: wide.join(' '), clipped: clipped.join(' '), cover: Math.round(cover), coverAt }; })()`);
      const ok = m.over <= 0 && m.cover <= 0;
      if (!ok) bad++;
      console.log(`${ok ? 'OK  ' : 'BAD '}  ${String(w).padStart(4)}px  ${m.hash.padEnd(9)} over=${String(m.over).padStart(4)} cover=${String(m.cover).padStart(3)}${m.coverAt ? '(' + m.coverAt + ')' : ''}  ${m.wide}${m.clipped ? '  ' + m.clipped : ''}`);
    }
  }
  console.log(bad ? `\n${bad} 个「视口 x 路由」组合不合格(溢出或遮挡)` : '\n全部视口 x 路由组合无溢出且无遮挡');
  cdp.close();
  process.exitCode = bad ? 1 : 0;
} catch (e) {
  console.log('ABORT', e.message);
  process.exitCode = 2;
} finally {
  if (child) { try { execFileSync('taskkill', ['/PID', String(child.pid), '/T', '/F'], { stdio: 'ignore' }); } catch (e) {} }
  try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 5, retryDelay: 300 }); } catch (e) {}
}
process.exit(process.exitCode ?? 0);
