import fs from 'node:fs';
const file = 'E:/OBsidian/全栈工程师学习资料库/04-资源与评估/data/jd-samples-2026-11-07.json';
const out = 'E:/OBsidian/全栈工程师学习资料库/04-资源与评估/data/jd-url-check-2026-11-07.json';
const samples = JSON.parse(fs.readFileSync(file, 'utf8')).samples;
const results = [];
let cursor = 0;
async function worker() {
  while (cursor < samples.length) {
    const job = samples[cursor++];
    let status = 0; let error = '';
    try {
      const res = await fetch(job.url, { method: 'HEAD', redirect: 'follow', headers: { 'user-agent': 'Mozilla/5.0' } });
      status = res.status;
    } catch (e) { error = e.message; }
    results.push({ url: job.url, company: job.company, status, error });
  }
}
await Promise.all(Array.from({ length: 6 }, worker));
results.sort((a, b) => a.url.localeCompare(b.url));
const summary = results.reduce((acc, r) => { const k = String(r.status || 'ERR'); acc[k] = (acc[k] || 0) + 1; return acc; }, {});
fs.writeFileSync(out, JSON.stringify({ checked_at: new Date().toISOString(), method: 'HEAD redirect=follow', total: results.length, summary, results }, null, 2));
console.log(JSON.stringify({ total: results.length, summary }));
