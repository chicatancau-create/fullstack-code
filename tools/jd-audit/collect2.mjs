import fs from 'node:fs';

const DOC = 'E:/OBsidian/全栈工程师学习资料库/04-资源与评估/真实JD样本与差距记录.md';
const OUT = 'E:/OBsidian/全栈工程师学习资料库/04-资源与评估/data/jd-samples-2026-11-07.json';
const strip = (s) => String(s || '').replace(/<[^>]+>/g, ' ').replace(/&nbsp;/g, ' ').replace(/\s+/g, ' ').trim();

const tencent = [];
for (let page = 1; page <= 2; page++) {
  const url = `https://careers.tencent.com/tencentcareer/api/post/Query?timestamp=${Date.now()}&countryId=1&cityId=&bgIds=&productId=&categoryId=&parentCategoryId=&attrId=&keyword=${encodeURIComponent('全栈')}&pageIndex=${page}&pageSize=20&language=zh-cn&area=cn`;
  const list = await (await fetch(url, { headers: { 'user-agent': 'Mozilla/5.0', referer: 'https://careers.tencent.com/' } })).json();
  for (const post of list.Data?.Posts || []) {
    const detail = await (await fetch(`https://careers.tencent.com/tencentcareer/api/post/ByPostId?postId=${post.PostId}&language=zh-cn`, { headers: { 'user-agent': 'Mozilla/5.0', referer: 'https://careers.tencent.com/' } })).json();
    const d = detail.Data || {};
    if (!d.Requirement) continue;
    tencent.push({
      company: '腾讯', source: 'careers.tencent.com (official API)', title: d.RecruitPostName,
      location: d.LocationName, experience: d.RequireWorkYearsName || '', url: `https://careers.tencent.com/jobdesc.html?postId=${d.PostId}`,
      updated: String(d.LastUpdateTime || '').slice(0, 10), requirements: strip(d.Requirement), responsibilities: strip(d.Responsibility),
    });
  }
}

const boards = ['gitlab', 'cloudflare', 'datadog', 'stripe', 'mongodb', 'elastic', 'mozilla', 'canonical'];
const gh = [];
for (const board of boards) {
  const res = await fetch(`https://boards-api.greenhouse.io/v1/boards/${board}/jobs?content=true`);
  if (!res.ok) { console.log(`${board}: HTTP ${res.status}`); continue; }
  const jobs = (await res.json()).jobs || [];
  const matched = jobs.filter((j) => /(full.?stack|back.?end|front.?end|software engineer|software developer|web developer)/i.test(j.title));
  for (const job of matched.slice(0, 3)) {
    gh.push({
      company: board, source: 'Greenhouse official job board', title: job.title, location: job.location?.name || '',
      experience: '', url: job.absolute_url, updated: String(job.updated_at || '').slice(0, 10),
      requirements: strip(job.content).slice(0, 4000), responsibilities: '',
    });
  }
}

const md = fs.readFileSync(DOC, 'utf8');
const manualMeta = [
  ['JD-07', '美团', 'AI全栈工程师', '北京/上海/成都/深圳', '应届', 'https://zhaopin.meituan.com/web/position/detail?jobUnionId=4697320043&highlightType=campus', '2026-08-17'],
  ['JD-08', '美团', '全栈工程师', '北京/深圳', '应届', 'https://zhaopin.meituan.com/web/position/detail?jobUnionId=4697318475&highlightType=campus', '2026-08-17'],
  ['JD-09', 'Thoughtworks', 'Software Developer', '西安', '2 年以上', 'https://www.thoughtworks.com/zh-cn/careers/jobs/8330382', '2026-11-05'],
  ['JD-10', 'Thoughtworks', 'Senior Developer', '西安', '资深', 'https://www.thoughtworks.com/zh-cn/careers/jobs/8330381', '2026-11-05'],
  ['JD-11', '美团', '全栈开发工程师（个人清单STL）', '上海', '2 年', 'https://zhaopin.meituan.com/web/position/detail?jobUnionId=4830252619', '2026-10-10'],
  ['JD-12', '字节跳动', 'AI全栈开发工程师（抖音精选）', '深圳', '正式/社招', 'https://jobs.bytedance.com/experienced/position/6948774351315700005/detail', '—'],
];
const manual = manualMeta.map(([id, company, title, location, experience, url, updated]) => {
  const start = md.indexOf(`### ${id} `);
  const end = md.indexOf('\n### ', start + 4);
  const section = md.slice(start, end === -1 ? md.length : end);
  return { company, source: 'official career page (manual excerpt)', title, location, experience, url, updated, requirements: strip(section.replace(/^###.*$/m, '')), responsibilities: '' };
});

const all = [...tencent, ...gh, ...manual];
const seen = new Set();
const unique = all.filter((j) => !seen.has(j.url) && seen.add(j.url));
fs.writeFileSync(OUT, JSON.stringify({ collected_at: new Date().toISOString(), method: 'official APIs/pages; requirement text captured verbatim (HTML stripped)', samples: unique }, null, 2));

const KW = {
  Java: /java\b/i, Go: /golang|\bgo\b/i, Python: /python/i, Node: /node\.?js|nodejs/i,
  TypeScript: /typescript/i, JavaScript: /javascript/i, React: /react/i, Vue: /vue/i,
  SQL: /mysql|postgres|\bsql\b/i, Redis: /redis/i, MongoDB: /mongodb/i,
  MQ: /kafka|rabbitmq|消息队列|\bmq\b/i, Docker: /docker/i, Kubernetes: /kubernetes|\bk8s\b/i,
  AI: /llm|\brag\b|agent|大模型|智能体|\bai\b/i,
};
const byCompany = {};
for (const j of unique) byCompany[j.company] = (byCompany[j.company] || 0) + 1;
const counts = {};
for (const [name, re] of Object.entries(KW)) counts[name] = unique.filter((j) => re.test(j.requirements)).length;
console.log(`total=${unique.length} companies=${Object.keys(byCompany).length}`);
console.log(JSON.stringify(byCompany));
console.log(JSON.stringify(counts));
console.log(`tencent=${tencent.length} greenhouse=${gh.length} manual=${manual.length}`);
