import fs from 'node:fs';
const DOC = 'E:/OBsidian/全栈工程师学习资料库/04-资源与评估/真实JD样本与差距记录.md';
const FILE = 'E:/OBsidian/全栈工程师学习资料库/04-资源与评估/data/jd-samples-2026-11-07.json';
const md = fs.readFileSync(DOC, 'utf8');
const data = JSON.parse(fs.readFileSync(FILE, 'utf8'));
const manualMeta = [
  ['JD-07', '美团', 'AI全栈工程师', '北京/上海/成都/深圳', '应届', 'https://zhaopin.meituan.com/web/position/detail?jobUnionId=4697320043&highlightType=campus', '2026-08-17'],
  ['JD-08', '美团', '全栈工程师', '北京/深圳', '应届', 'https://zhaopin.meituan.com/web/position/detail?jobUnionId=4697318475&highlightType=campus', '2026-08-17'],
  ['JD-09', 'Thoughtworks', 'Software Developer', '西安', '2 年以上', 'https://www.thoughtworks.com/zh-cn/careers/jobs/8330382', '2026-11-05'],
  ['JD-10', 'Thoughtworks', 'Senior Developer', '西安', '资深', 'https://www.thoughtworks.com/zh-cn/careers/jobs/8330381', '2026-11-05'],
  ['JD-11', '美团', '全栈开发工程师（个人清单STL）', '上海', '2 年', 'https://zhaopin.meituan.com/web/position/detail?jobUnionId=4830252619', '2026-10-10'],
  ['JD-12', '字节跳动', 'AI全栈开发工程师（抖音精选）', '深圳', '正式/社招', 'https://jobs.bytedance.com/experienced/position/6948774351315700005/detail', '—'],
];
const strip = (s) => s.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
const manual = manualMeta.map(([id, company, title, location, experience, url, updated]) => {
  const start = md.indexOf(`### ${id} `);
  const rest = md.slice(start + 4);
  const nextH3 = rest.indexOf('\n### ');
  const nextH2 = rest.indexOf('\n## ');
  const ends = [nextH3, nextH2].filter((n) => n !== -1);
  const section = md.slice(start, ends.length ? start + 4 + Math.min(...ends) : md.length);
  return { company, source: 'official career page (manual excerpt)', title, location, experience, url, updated, requirements: strip(section.replace(/^###.*$/m, '')), responsibilities: '' };
});
const keep = data.samples.filter((j) => !/manual excerpt/.test(j.source));
const samples = [...keep, ...manual];
fs.writeFileSync(FILE, JSON.stringify({ ...data, repaired_at: new Date().toISOString(), samples }, null, 2));
console.log('samples', samples.length, 'manual', manual.map((m) => `${m.company}:${m.requirements.length}`).join(' '));
