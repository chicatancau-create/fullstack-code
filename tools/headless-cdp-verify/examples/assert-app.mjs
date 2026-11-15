import { spawn, execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const BASE = process.env.VERIFY_BASE || 'http://127.0.0.1:4187';
const EDGE = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
// 截图落在工具目录下的 out/（已 gitignore），可用 SHOT_DIR 覆盖
const OUT = process.env.SHOT_DIR || fileURLToPath(new URL('../out', import.meta.url));
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

fs.mkdirSync(OUT, { recursive: true });
const getJSON = async (u) => (await fetch(u)).json();

class CDP {
  constructor(url) { this.url = url; this.id = 0; this.pending = new Map(); this.handlers = []; }
  connect() {
    return new Promise((res, rej) => {
      this.ws = new WebSocket(this.url);
      this.ws.onopen = res;
      this.ws.onerror = (e) => rej(new Error('ws error ' + (e.message || '')));
      this.ws.onmessage = (raw) => {
        const m = JSON.parse(raw.data);
        if (m.id && this.pending.has(m.id)) {
          const { resolve, reject } = this.pending.get(m.id);
          this.pending.delete(m.id);
          m.error ? reject(new Error(m.error.message)) : resolve(m.result);
        } else if (m.method) for (const h of this.handlers)
          if (h.method === m.method && (!h.sessionId || h.sessionId === m.sessionId)) h.fn(m.params);
      };
    });
  }
  send(method, params = {}, sessionId) {
    const id = ++this.id; const p = { id, method, params };
    if (sessionId) p.sessionId = sessionId;
    return new Promise((resolve, reject) => { this.pending.set(id, { resolve, reject }); this.ws.send(JSON.stringify(p)); });
  }
  on(method, fn, sessionId) { this.handlers.push({ method, fn, sessionId }); }
  close() { try { this.ws && this.ws.close(); } catch (e) {} }
}

let pass = 0, fail = 0, skipped = 0;
const results = [];
function check(name, ok, detail = '') {
  (ok ? pass++ : fail++);
  results.push(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? '  :: ' + detail : ''}`);
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? '  :: ' + detail : ''}`);
}
// 当前条件下无从执行的断言单独一档，既不算通过也不算失败
function skip(name, detail = '') {
  skipped++;
  results.push(`N/E   ${name}${detail ? '  :: ' + detail : ''}`);
  console.log(`N/E   ${name}${detail ? '  :: ' + detail : ''}`);
}

const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'habit-verify-'));
let child, cdp, PG;
const pageErrors = [];
const browserNoise = [];

try {
  child = spawn(EDGE, [
    '--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--disable-gpu',
    '--disable-backgrounding-occluded-windows', '--disable-renderer-backgrounding',
    '--window-size=1280,900',
  ], { stdio: 'ignore' });

  let port = 0;
  for (let i = 0; i < 60; i++) {
    if (child.exitCode !== null) throw new Error('browser exited code=' + child.exitCode);
    try {
      const p = Number(fs.readFileSync(path.join(profile, 'DevToolsActivePort'), 'utf8').split('\n')[0].trim());
      if (p > 0) { port = p; break; }
    } catch (e) {}
    await sleep(500);
  }
  if (!port) throw new Error('no DevToolsActivePort in own profile');
  const version = await getJSON(`http://127.0.0.1:${port}/json/version`);
  console.log('BROWSER', version.Browser, '| BASE', BASE);

  cdp = new CDP(version.webSocketDebuggerUrl);
  await cdp.connect();
  const { targetId } = await cdp.send('Target.createTarget', { url: 'about:blank' });
  PG = (await cdp.send('Target.attachToTarget', { targetId, flatten: true })).sessionId;
  await cdp.send('Page.enable', {}, PG);
  await cdp.send('Runtime.enable', {}, PG);
  await cdp.send('Log.enable', {}, PG);
  cdp.on('Runtime.exceptionThrown', (p) => {
    const d = p.exceptionDetails?.exception?.description || p.exceptionDetails?.text || '';
    // Edge 内建组件的扩展消息通道噪声，与被测页面无关，单独归类
    (/Could not establish connection|Receiving end does not exist/i.test(d) ? browserNoise : pageErrors).push('EXC ' + d);
  }, PG);
  cdp.on('Log.entryAdded', (p) => { if (p.entry.level === 'error' && p.entry.source !== 'network') pageErrors.push('LOG ' + p.entry.text); }, PG);

  await cdp.send('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: 'light' }] }, PG);
  const setViewport = (w, h) => cdp.send('Emulation.setDeviceMetricsOverride', { width: w, height: h, deviceScaleFactor: 2, mobile: false }, PG);
  await setViewport(1280, 900);

  const evl = async (expression) => {
    const r = await cdp.send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }, PG);
    if (r.exceptionDetails) throw new Error('EVL ' + (r.exceptionDetails.exception?.description || r.exceptionDetails.text));
    return r.result.value;
  };
  const goto = async (hash) => { await cdp.send('Page.navigate', { url: BASE + hash }, PG); await sleep(1500); };
  const reload = async () => { await cdp.send('Page.reload', {}, PG); await sleep(1600); };
  const shot = async (name) => {
    const { data } = await cdp.send('Page.captureScreenshot', { format: 'png' }, PG);
    const p = path.join(OUT, name + '.png');
    fs.writeFileSync(p, Buffer.from(data, 'base64'));
    const sz = fs.existsSync(p) ? fs.statSync(p).size : 0;
    if (!sz) throw new Error('screenshot empty: ' + name);
    console.log('SHOT  ', name + '.png', sz, 'bytes');
  };
  const shotFull = async (name) => {
    const { data } = await cdp.send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: true }, PG);
    const p = path.join(OUT, name + '.png');
    fs.writeFileSync(p, Buffer.from(data, 'base64'));
    console.log('SHOT  ', name + '.png', fs.statSync(p).size, 'bytes (full page)');
  };
  const clickAt = async (selector, idx = 0) => {
    const box = await evl(`(() => { const e = document.querySelectorAll(${JSON.stringify(selector)})[${idx}];
      if (!e) return null; const r = e.getBoundingClientRect();
      return { x: r.left + r.width / 2, y: r.top + r.height / 2, d: e.disabled === true }; })()`);
    if (!box) return 'NO_TARGET';
    if (box.d) return 'DISABLED';
    for (const type of ['mousePressed', 'mouseReleased']) {
      await cdp.send('Input.dispatchMouseEvent', { type, x: box.x, y: box.y, button: 'left', clickCount: 1 }, PG);
    }
    await sleep(400);
    return 'OK';
  };
  const typeInto = async (selector, text) => {
    if (clickAt(selector) === 'NO_TARGET') return 'NO_TARGET';
    await sleep(200);
    await cdp.send('Input.insertText', { text }, PG);
    await sleep(300);
    return await evl(`document.querySelector(${JSON.stringify(selector)}).value`);
  };

  console.log('\n--- 1. 登录页与导航守卫 ---');
  await goto('/#/login');
  await evl(`localStorage.clear()`);
  await reload();
  check('未登录访问 /#/ 被守卫拦到 /#/login', (await evl('location.hash')).startsWith('#/login'), await evl('location.hash'));
  await goto('/#/stats');
  const bounced = await evl('location.hash');
  check('未登录访问 /#/stats 带 redirect 参数', bounced.startsWith('#/login?redirect='), bounced);
  check('登录页标题与副标题渲染', (await evl(`document.querySelector('.login-title')?.innerText`))?.includes('习惯打卡'), await evl(`document.querySelector('.login-sub')?.innerText`));
  await shot('01-login');

  console.log('\n--- 2. 空提交校验 ---');
  await clickAt('.login-btn');
  check('空提交被拦下（仍在登录页）', (await evl('location.hash')).includes('login'));
  // 精确等式：登录页有 username / password 两个必填项，空提交必须各给一条 role=alert 且两个输入都置 aria-invalid=true
  const loginErr = await evl(`(() => ({ nodes: document.querySelectorAll('.field-error[role=alert]').length,
    invalid: document.querySelectorAll('input[aria-invalid="true"]').length }))()`);
  check('空提交给出两个字段级错误且 aria-invalid 同步', loginErr.nodes === 2 && loginErr.invalid === 2,
    `field-error=${loginErr.nodes} aria-invalid=${loginErr.invalid}`);

  console.log('\n--- 3. 登录并回跳 ---');
  await goto('/#/login?redirect=%2Fstats');
  await typeInto('#habit-username', 'xiaok');
  await typeInto('#habit-password', 'demo1234');
  await clickAt('.login-btn');
  await sleep(1200);
  const landed = await evl('location.hash');
  check('登录后回跳到 redirect 指定的 /stats', landed === '#/stats', landed);
  check('登录态写入 localStorage', (await evl(`localStorage.getItem('habit-token')`)) === 'xiaok');
  check('页头显示用户名', (await evl(`document.querySelector('.user-name,.welcome,header')?.innerText`))?.includes('xiaok'));

  console.log('\n--- 4. 周视图打卡 ---');
  await goto('/#/');
  const rowCount0 = await evl(`document.querySelectorAll('.habit-row').length`);
  const checked0 = await evl(`document.querySelectorAll('.cell.checked').length`);
  check('周矩阵渲染出 4 个习惯行', rowCount0 === 4, 'rows=' + rowCount0);
  check('每行 7 个格子', (await evl(`document.querySelectorAll('.cell').length`)) === rowCount0 * 7, 'cells=' + await evl(`document.querySelectorAll('.cell').length`));
  // 与日期无关的不变量：未来格数应等于「本周剩余天数」，且这些格必须全部 disabled
  const futureInv = await evl(`(() => {
    const pad = (n) => String(n).padStart(2, '0');
    const key = (d) => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
    const now = new Date();
    const dow = (now.getDay() + 6) % 7;              // 周一=0 … 周日=6
    const expected = 6 - dow;                          // 本周还剩几天在今天之后
    const cells = [...document.querySelectorAll('.cell')];
    const future = cells.filter(c => /未来|不可/.test(c.title) || c.classList.contains('future'));
    const perRow = new Map();
    for (const row of document.querySelectorAll('.habit-row')) {
      const cs = [...row.querySelectorAll('.cell')];
      const f = cs.filter(c => c.classList.contains('future'));
      perRow.set(row.querySelector('.name')?.innerText ?? '?', { n: f.length, allDisabled: f.every(c => c.disabled) });
    }
    const counts = [...perRow.values()].map(v => v.n);
    return { expected, counts, allDisabled: [...perRow.values()].every(v => v.allDisabled), uniq: [...new Set(counts)] };
  })()`);
  check('未来格子数量等于本周剩余天数且全部 disabled',
    futureInv.uniq.length === 1 && futureInv.uniq[0] === futureInv.expected && futureInv.allDisabled,
    `expected=${futureInv.expected} perRow=${JSON.stringify(futureInv.counts)} allDisabled=${futureInv.allDisabled}`);
  check('今天格子有标记（每行恰好一个）', (await evl(`document.querySelectorAll('.cell.today').length`)) === rowCount0,
    'today=' + await evl(`document.querySelectorAll('.cell.today').length`) + ' rows=' + rowCount0);
  check('格子带 aria-pressed 语义', (await evl(`document.querySelectorAll('.cell[aria-pressed]').length`)) === rowCount0 * 7);
  await shot('02-board');

  const n0 = await evl(`document.querySelectorAll('.cell.checked').length`);
  const cellRef = await evl(`(() => { const rows=[...document.querySelectorAll('.habit-row')];
    for (let i=0;i<rows.length;i++){ const cells=[...rows[i].querySelectorAll('.cell')];
      const j=cells.findIndex(x=>!x.classList.contains('checked') && !x.classList.contains('future') && !x.disabled);
      if (j>=0) { const r=cells[j].getBoundingClientRect(); return {row:i, col:j, x:r.left+r.width/2, y:r.top+r.height/2, title:cells[j].title, pressed:cells[j].getAttribute('aria-pressed')}; } }
    return null; })()`);
  if (!cellRef) throw new Error('找不到一个可打卡的空格');
  check('空格子 aria-pressed=false', cellRef.pressed === 'false', String(cellRef.pressed));
  const cellPath = `document.querySelectorAll('.habit-row')[${cellRef.row}].querySelectorAll('.cell')[${cellRef.col}]`;
  for (const type of ['mousePressed', 'mouseReleased']) await cdp.send('Input.dispatchMouseEvent', { type, x: cellRef.x, y: cellRef.y, button: 'left', clickCount: 1 }, PG);
  await sleep(600);
  const checked1 = await evl(`document.querySelectorAll('.cell.checked').length`);
  check('点击空格子变为已打卡', checked1 === n0 + 1, `${n0} -> ${checked1} @row${cellRef.row}/col${cellRef.col} ${cellRef.title}`);
  const pressed1 = await evl(`(() => { const c=${cellPath}; return c.getAttribute('aria-pressed')+'/'+c.classList.contains('checked'); })()`);
  check('打卡后 aria-pressed 翻转为 true', pressed1 === 'true/true', String(pressed1));
  const title1 = await evl(`${cellPath}.title`);
  check('打卡后 title 文案随之更新', title1 !== cellRef.title && /已打卡/.test(title1), title1);
  await cdp.send('Input.dispatchMouseEvent', { type: 'mousePressed', x: cellRef.x, y: cellRef.y, button: 'left', clickCount: 1 }, PG);
  await cdp.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: cellRef.x, y: cellRef.y, button: 'left', clickCount: 1 }, PG);
  await sleep(500);
  check('再点一次取消打卡', (await evl(`document.querySelectorAll('.cell.checked').length`)) === n0, `${checked1} -> ${await evl(`document.querySelectorAll('.cell.checked').length`)}`);
  await cdp.send('Input.dispatchMouseEvent', { type: 'mousePressed', x: cellRef.x, y: cellRef.y, button: 'left', clickCount: 1 }, PG);
  await cdp.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: cellRef.x, y: cellRef.y, button: 'left', clickCount: 1 }, PG);
  await sleep(500);
  // 等式 + 回归锁：每行 3 段统计文字都非空且格式正确，并且各行进度条右边缘必须逐行相等
  // （右边缘相等这一条锁住的是实测过的缺陷：.stats 用 max-content 时「80%」列 24.75px、
  //  「100%」列 31.8px，中间 1fr 跟着变，四行量出 911/918 两档、错位 7px）
  const statsShape = await evl(`(() => { const rows=[...document.querySelectorAll('.habit-row')];
    const texts = rows.map(r => [...r.querySelectorAll('.stat-text')]);
    const filled = texts.every(ts => ts.length === 3 && ts.every(t => t.innerText.trim().length > 0));
    const fmt = texts.every(ts => /^\\d+%$/.test(ts[0].innerText.trim()) && /^连续 \\d+ 天$/.test(ts[1].innerText.trim()) && /^最长 \\d+ 天$/.test(ts[2].innerText.trim()));
    const bars = rows.map(r => Math.round(r.querySelector('.progress').getBoundingClientRect().right));
    const clipped = rows.map(r => { const s = r.querySelector('.stats'), a = r.querySelector('.row-actions');
      return [...s.querySelectorAll('.stat-text')].some(t => t.getBoundingClientRect().right > a.getBoundingClientRect().left + 1); });
    return JSON.stringify({ filled, fmt, uniqBars: [...new Set(bars)], clipped: clipped.filter(Boolean).length }); })()`);
  const ss = JSON.parse(statsShape);
  check('每行三段统计文字齐全且格式正确', ss.filled && ss.fmt, `filled=${ss.filled} fmt=${ss.fmt}`);
  check('各行进度条右边缘逐行相等（锁住 7px 错位回归）', ss.uniqBars.length === 1, 'barRights=' + JSON.stringify(ss.uniqBars));
  check('统计文字不被操作列压住', ss.clipped === 0, 'clippedRows=' + ss.clipped);
  const stored = await evl(`(() => { const d = JSON.parse(localStorage.getItem('xiji-habit-tracker-v1')); return Object.values(d.checkins).reduce((a,b)=>a+b.length,0); })()`);
  check('打卡写入 localStorage', stored > 0, 'records=' + stored);
  await shot('03-board-checked');

  console.log('\n--- 5. 持久化（含反向对照）---');
  await reload();
  const checkedAfterReload = await evl(`document.querySelectorAll('.cell.checked').length`);
  check('刷新后打卡状态保留', checkedAfterReload === checked1, `${checked1} -> ${checkedAfterReload}`);
  // 反向对照：抹掉存储，同一断言必须变红
  await evl(`localStorage.removeItem('xiji-habit-tracker-v1')`);
  await reload();
  const checkedAfterWipe = await evl(`document.querySelectorAll('.cell.checked').length`);
  const teeth = checkedAfterWipe !== checked1;
  check('反向对照：抹掉 localStorage 后同一断言确实失败（证明断言有牙齿）', teeth, `wiped=${checkedAfterWipe} vs ${checked1}`);
  await evl(`localStorage.setItem('habit-token','xiaok');localStorage.setItem('habit-user','xiaok')`);
  await reload();

  console.log('\n--- 6. 未来日期不可打卡 ---');
  const futureBefore = await evl(`document.querySelectorAll('.cell.checked').length`);
  const fbox = await evl(`(() => { const c = [...document.querySelectorAll('.cell.future')][0]; if(!c) return null; const r=c.getBoundingClientRect(); return {x:r.left+r.width/2,y:r.top+r.height/2,d:c.disabled}; })()`);
  if (!fbox) {
    // 今天是一周最后一天时本周没有未来格，这条断言无从执行 —— 明确标成未执行，不写成通过
    skip('未来格子点击不改变打卡数', '本周无未来日期格子（今天是该周最后一天），此断言在当前日期无从执行');  } else {
    if (!fbox.d) {
      for (const type of ['mousePressed', 'mouseReleased']) await cdp.send('Input.dispatchMouseEvent', { type, x: fbox.x, y: fbox.y, button: 'left', clickCount: 1 }, PG);
      await sleep(500);
    }
    check('未来格子点击不改变打卡数', (await evl(`document.querySelectorAll('.cell.checked').length`)) === futureBefore, `disabled=${fbox.d}`);
  }

  console.log('\n--- 7. 新增 / 编辑 / 删除习惯 ---');
  const rows0 = await evl(`document.querySelectorAll('.habit-row').length`);
  await clickAt('.btn-primary');
  await sleep(600);
  console.log('  FORM INPUTS:', await evl(`[...document.querySelectorAll('input,select,textarea')].map(i=>i.tagName+'['+i.type+']#'+i.id+' ph='+JSON.stringify(i.placeholder||'')+' aria='+JSON.stringify(i.getAttribute('aria-label')||'')).join(' ;; ')`));
  const nameSel = await evl(`(() => { const list=[...document.querySelectorAll('input')];
    const i = list.find(x => /名称|name/i.test((x.placeholder||'')+(x.id||'')+(x.getAttribute('aria-label')||'')) && x.type !== 'checkbox');
    if (!i) return -1; return list.indexOf(i); })()`);
  check('新增表单打开且有名称输入框', nameSel >= 0, 'inputIndex=' + nameSel);
  await shot('04-form');
  const nameBox = await evl(`(() => { const r = [...document.querySelectorAll('input')][${nameSel}].getBoundingClientRect(); return {x:r.left+6,y:r.top+r.height/2}; })()`);
  for (const type of ['mousePressed', 'mouseReleased']) await cdp.send('Input.dispatchMouseEvent', { type, x: nameBox.x, y: nameBox.y, button: 'left', clickCount: 1 }, PG);
  await sleep(300);
  await cdp.send('Input.insertText', { text: '每日一道算法题' }, PG);
  await sleep(400);
  const typed = await evl(`[...document.querySelectorAll('input')][${nameSel}].value`);
  check('名称输入框收到 v-model 值', typed === '每日一道算法题', JSON.stringify(typed));
  const submitIdx = await evl(`[...document.querySelectorAll('button')].findIndex(b => /保存|确定|添加|新增|提交/.test(b.innerText) && !/新增习惯/.test(b.innerText))`);
  await clickAt('button', submitIdx);
  await sleep(900);
  const rows1 = await evl(`document.querySelectorAll('.habit-row').length`);
  check('新增习惯后行数 +1', rows1 === rows0 + 1, `${rows0} -> ${rows1}`);
  check('新习惯出现在列表里', (await evl(`document.body.innerText.includes('每日一道算法题')`)));
  await shot('05-board-added');

  const delIdx = await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.trim()==='删除')`);
  await clickAt('button', delIdx);
  await sleep(400);
  const rowsAfterFirstDel = await evl(`document.querySelectorAll('.habit-row').length`);
  check('删除需要二次确认（第一次不删）', rowsAfterFirstDel === rows1, `${rows1} -> ${rowsAfterFirstDel}`);
  // 确认态会隐藏「编辑」按钮，DOM 顺序左移，只能按文案查，不能按索引查
  check('确认态按钮文案为「确认删除」', (await evl(`[...document.querySelectorAll('button')].some(b=>b.innerText.trim()==='确认删除')`)));
  // 确认态会隐藏该行的「编辑」按钮：处于确认态的那一行只剩 1 个按钮
  const confirmRowBtns = await evl(`(() => { const b=[...document.querySelectorAll('button')].find(x=>x.innerText.trim()==='确认删除');
    if (!b) return -1; return b.closest('.row-actions').querySelectorAll('button').length; })()`);
  check('确认态那一行只剩确认按钮（编辑让位）', confirmRowBtns === 1, 'buttons=' + confirmRowBtns);
  await clickAt('button', await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.trim()==='确认删除')`));
  await sleep(700);
  const rows2 = await evl(`document.querySelectorAll('.habit-row').length`);
  check('第二次确认行数 -1', rows2 === rows1 - 1, `${rows1} -> ${rows2}`);

  // 确认态会自动取消：进入确认态后不点第二次，等它超时回退（截图会耗时，故放在最后一步）
  await clickAt('button', await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.trim()==='删除')`));
  await sleep(400);
  await shot('06-delete-confirm');
  await sleep(2600);
  check('确认态超时后自动回退为「删除」', (await evl(`[...document.querySelectorAll('button')].some(b=>b.innerText.trim()==='删除')`)) && !(await evl(`[...document.querySelectorAll('button')].some(b=>b.innerText.trim()==='确认删除')`)));
  await clickAt('button', await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.trim()==='删除')`));
  await sleep(300);
  await clickAt('button', await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.trim()==='确认删除')`));
  await sleep(700);
  check('回退后仍可正常二次删除', (await evl(`document.querySelectorAll('.habit-row').length`)) === rows2 - 1, `${rows2} -> ${await evl(`document.querySelectorAll('.habit-row').length`)}`);


  console.log('\n--- 8. 周切换 ---');
  const week0 = await evl(`document.querySelector('.section-title')?.innerText`);
  const prevIdx = await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.includes('上一周'))`);
  await clickAt('button', prevIdx);
  await sleep(600);
  const week1 = await evl(`document.querySelector('.section-title')?.innerText`);
  check('上一周 → 周标题变化', week0 !== week1, `${JSON.stringify(week0)} -> ${JSON.stringify(week1)}`);
  await clickAt('button', prevIdx);
  await clickAt('button', prevIdx);
  await sleep(400);
  const backIdx = await evl(`[...document.querySelectorAll('button')].findIndex(b => /回到本周|本周/.test(b.innerText))`);
  if (backIdx >= 0) { await clickAt('button', backIdx); await sleep(600); }
  else { await clickAt('button', await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.includes('下一周'))`)); await sleep(400); await clickAt('button', await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.includes('下一周'))`)); await sleep(600); }
  check('能回到当前周', (await evl(`document.querySelector('.section-title')?.innerText`)) === week0, await evl(`document.querySelector('.section-title')?.innerText`));
  const nextDisabled = await evl(`[...document.querySelectorAll('button')].find(b => b.innerText.includes('下一周'))?.disabled`);
  check('本周时「下一周」被禁用', nextDisabled === true, 'disabled=' + nextDisabled);

  console.log('\n--- 9. 统计页 / 热力月历 ---');
  await goto('/#/stats');
  // 用精确类名 .stat-card，不要用 [class*=stat]（它会连 .stats-page/.stat-grid/.stat-label 一起数，实测报 23）
  const cards = await evl(`(() => { const c=[...document.querySelectorAll('.stat-card')];
    return { n: c.length, allFilled: c.every(x => x.querySelector('.stat-label')?.innerText.trim() && x.querySelector('.stat-value')?.innerText.trim()),
             nan: /NaN|undefined/.test(document.querySelector('.stat-grid').innerText) }; })()`);
  check('统计页恰好 4 张数字卡且标签与数值都非空', cards.n === 4 && cards.allFilled && !cards.nan,
    `n=${cards.n} allFilled=${cards.allFilled} 有NaN=${cards.nan}`);
  const hmCells = await evl(`document.querySelectorAll('.hm-cell').length`);
  check('热力月历为 7 的倍数格（周一开头整行）', hmCells % 7 === 0, 'cells=' + hmCells);
  // 色阶档数由当月实际分布算出来当基准，不再写 >= 3（数据均匀时会假红，写成 >=0 又恒真）。
  // aria-label 有三种真实形态（MonthHeatmap.vue 的 cellAriaLabel）：
  //   '空白格' / '<key> 尚未到来' / '<key>，<n> 个习惯完成打卡' / '<key>，没有打卡'
  // 注意：模板字符串里要写 \\d，写 \d 会被模板转义吃掉变成字面 d（本条第一次就栽在这）
  const heat = await evl(`(() => {
    const cells = [...document.querySelectorAll('.hm-cell:not(.is-blank)')];
    const rendered = [...new Set(cells.map(c => [...c.classList].find(x => /^heat-/.test(x)) || 'NONE'))].sort();
    const counts = cells.map(c => { const m = (c.getAttribute('aria-label') || '').match(/，(\\d+) 个习惯/); return m ? Number(m[1]) : 0; });
    const expect = [...new Set(counts.map(n => 'heat-' + (n >= 3 ? 3 : n)))].sort();
    return JSON.stringify({ rendered, expect, nCells: cells.length, maxCount: Math.max(...counts, 0) });
  })()`);
  const hh = JSON.parse(heat);
  check('热力色阶档数与当月分布的档数一致', hh.rendered.join() === hh.expect.join() && hh.nCells > 0,
    `渲染=${JSON.stringify(hh.rendered)} 应有=${JSON.stringify(hh.expect)} 格数=${hh.nCells} 单日最大=${hh.maxCount}`);
  const monthLabel = await evl(`document.querySelector('.heatmap')?.innerText.match(/\\d{4}年\\d{1,2}月/)?.[0]`);
  const nextBtnIdx = await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.includes('下一月'))`);
  const prevBtnIdx = await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.includes('上一月'))`);
  check('当前月时「下一月」禁用', (await evl(`[...document.querySelectorAll('button')][${nextBtnIdx}].disabled`)) === true);
  await clickAt('button', prevBtnIdx);
  await sleep(700);
  const monthLabel2 = await evl(`document.querySelector('.heatmap')?.innerText.match(/\\d{4}年\\d{1,2}月/)?.[0]`);
  check('上一月 → 月份切换', monthLabel !== monthLabel2, `${monthLabel} -> ${monthLabel2}`);
  check('翻到历史月后「下一月」解禁', (await evl(`[...document.querySelectorAll('button')][${nextBtnIdx}].disabled`)) === false);
  await shot('06b-stats-prevmonth');
  await clickAt('button', nextBtnIdx);
  await sleep(700);
  const monthLabel3 = await evl(`document.querySelector('.heatmap')?.innerText.match(/\\d{4}年\\d{1,2}月/)?.[0]`);
  check('下一月回到当前月并重新禁用', monthLabel3 === monthLabel && (await evl(`[...document.querySelectorAll('button')][${nextBtnIdx}].disabled`)) === true, `${monthLabel3} disabled=${await evl(`[...document.querySelectorAll('button')][${nextBtnIdx}].disabled`)}`);
  await shot('07-stats');
  await shotFull('07b-stats-full');

  const tipCell = await evl(`(() => { const c=[...document.querySelectorAll('.hm-cell.heat-2,.hm-cell.heat-3')][0]; if(!c) return null; const r=c.getBoundingClientRect(); return {x:r.left+r.width/2,y:r.top+r.height/2, aria:c.getAttribute('aria-label')}; })()`);
  if (tipCell) {
    await cdp.send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: tipCell.x, y: tipCell.y, button: 'none' }, PG);
    await sleep(600);
    const tipShown = await evl(`(() => { const c=[...document.querySelectorAll('.hm-cell.heat-2,.hm-cell.heat-3')][0]; const t=c && c.querySelector('[class*=tip]:not(.tip-below):not(.tip-right):not(.tip-left)'); if(!t) return 'NO_TIP_NODE'; const s=getComputedStyle(t); return s.visibility+'/'+s.opacity; })()`);
    check('悬停热力格显示当日明细浮层', /^visible\/(0\.)?[1-9]/.test(tipShown), `${tipCell.aria} -> ${tipShown}`);
    await shot('08-heatmap-hover');
  } else {
    skip('悬停热力格显示当日明细浮层', '当月没有任何 heat-2/heat-3 格子，无悬停目标，此断言无从执行');
  }
  const expandIdx = await evl(`[...document.querySelectorAll('button')].findIndex(b => b.innerText.trim()==='展开')`);
  if (expandIdx >= 0) {
    // 明细表在首屏之外，必须先滚进视口再点（否则真实指针落在 viewport 外，点了等于没点）
    await evl(`document.querySelectorAll('button')[${expandIdx}].scrollIntoView({block:'center'})`);
    await sleep(500);
    const before = await evl(`document.querySelectorAll('.month-detail').length`);
    await clickAt('button', expandIdx);
    await sleep(700);
    const detail = await evl(`(() => { const d=document.querySelector('.month-detail');
      return d ? 'chips=' + d.querySelectorAll('.chip').length + ' text=' + (d.innerText||'').replace(/\\s+/g,' ').trim().slice(0,40) : 'NO_DETAIL_NODE'; })()`);
    check('展开后 .month-detail 真的渲染出来', (await evl(`document.querySelectorAll('.month-detail').length`)) === before + 1, `${before} -> ${detail}`);
    check('该按钮文案由「展开」翻为「收起」', (await evl(`document.querySelectorAll('button')[${expandIdx}].innerText.trim()`)) === '收起',
      await evl(`document.querySelectorAll('button')[${expandIdx}].innerText.trim()`));
    await shot('08b-stats-expanded');
  } else { check('明细表可展开本月打卡明细', false, '找不到展开按钮'); }

  console.log('\n--- 10. 关于页 ---');
  await goto('/#/about');
  const aboutText = await evl(`document.body.innerText`);
  check('关于页含实现说明段', /实现说明|实现思路/.test(aboutText));
  const implLen = await evl(`(() => { const h=[...document.querySelectorAll('h2,h3')].find(x=>/实现说明/.test(x.innerText)); if(!h) return -1;
    let t='', n=h.nextElementSibling; while(n && !/^H[23]$/.test(n.tagName)){ t += n.innerText; n=n.nextElementSibling; }
    return t.replace(/\\s/g,'').length; })()`);
  check('实现说明 ≤300 字', implLen > 0 && implLen <= 300, 'chars=' + implLen);
  await shot('09-about');

  console.log('\n--- 11. 404 ---');
  await goto('/#/definitely-not-a-page');
  check('未知路由落到 404 页', /404|不存在/.test(await evl('document.body.innerText')), await evl(`document.querySelector('h1,h2,.section-title')?.innerText`));
  await shot('10-404');

  console.log('\n--- 12. 窄视口 390px ---');
  await setViewport(390, 844);
  await goto('/#/');
  await sleep(800);
  const overBoard = await evl(`document.documentElement.scrollWidth - document.documentElement.clientWidth`);
  check('打卡页 390px 无横向溢出', overBoard <= 0, 'OVER=' + overBoard);
  await shot('11-mobile-board');
  await goto('/#/stats');
  await sleep(900);
  const overStats = await evl(`document.documentElement.scrollWidth - document.documentElement.clientWidth`);
  check('统计页 390px 无横向溢出', overStats <= 0, 'OVER=' + overStats);
  await shot('12-mobile-stats');
  await setViewport(1280, 900);

  console.log('\n--- 13. 反向对照：证明断言机制会红 ---');
  check('负对照（预期 FAIL）：查询不存在的元素', (await evl(`!!document.querySelector('#__definitely_not_exists__')`)) === true, '这条必须显示 FAIL，否则说明断言是假的');

  console.log('\nPAGE ERRORS:', pageErrors.length ? pageErrors.slice(0, 8) : 'none');
  if (browserNoise.length) console.log('BROWSER NOISE (Edge 内建组件，非页面错误，已排除):', browserNoise.length, '条');
} catch (e) {
  fail++;
  results.push('ABORT ' + e.message);
  console.log('\n!!! ABORT:', e.message);
} finally {
  if (cdp) cdp.close();
  if (child) { try { execFileSync('taskkill', ['/PID', String(child.pid), '/T', '/F'], { stdio: 'ignore' }); } catch (e) {} }
  try { fs.rmSync(profile, { recursive: true, force: true, maxRetries: 5, retryDelay: 300 }); } catch (e) {}
  fs.writeFileSync(path.join(OUT, 'report.txt'), `BROWSER+断言结果\n${results.join('\n')}\n\nPASS=${pass} FAIL=${fail} NOT_EXECUTED=${skipped}`);
  console.log(`\n===== PASS=${pass}  FAIL=${fail}（含 1 条故意的负对照）  NOT_EXECUTED=${skipped} =====`);
  console.log('shots ->', OUT);
}
process.exit(fail > 1 ? 1 : 0);
