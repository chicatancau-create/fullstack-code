import fs from 'node:fs';

const now = new Date().toISOString();
const tencent = [];
for (let page = 1; page <= 4; page++) {
  const url = `https://careers.tencent.com/tencentcareer/api/post/Query?timestamp=${Date.now()}&countryId=1&cityId=&bgIds=&productId=&categoryId=&parentCategoryId=&attrId=&keyword=${encodeURIComponent('全栈')}&pageIndex=${page}&pageSize=20&language=zh-cn&area=cn`;
  const res = await fetch(url, { headers: { 'user-agent': 'Mozilla/5.0', referer: 'https://careers.tencent.com/' } });
  const json = await res.json();
  const posts = json?.Data?.Posts || [];
  for (const p of posts) {
    if (!p.Requirement) continue;
    tencent.push({
      company: '腾讯', source: 'careers.tencent.com', title: p.RecruitPostName, location: p.LocationName,
      experience: p.RequireWorkYearsName || '', url: `https://careers.tencent.com/jobdesc.html?postId=${p.PostId}`,
      updated: (p.LastUpdateTime || '').slice(0, 10), requirements: p.Requirement.replace(/<[^>]+>/g, ' ').trim(),
      responsibilities: (p.Responsibility || '').replace(/<[^>]+>/g, ' ').trim(),
    });
  }
  if (posts.length < 20) break;
}
const seen = new Set();
const tencentUnique = tencent.filter((j) => !seen.has(j.url) && seen.add(j.url));

const boards = ['gitlab', 'grafana', 'hashicorp', 'cloudflare', 'datadog', 'stripe', 'mongodb', 'elastic', 'mozilla', 'canonical'];
const gh = [];
for (const board of boards) {
  try {
    const res = await fetch(`https://boards-api.greenhouse.io/v1/boards/${board}/jobs?content=true`);
    if (!res.ok) { console.log(`${board}: HTTP ${res.status}`); continue; }
    const json = await res.json();
    const jobs = (json.jobs || []).filter((j) => /(full.?stack|back.?end|front.?end|software engineer|software developer|web developer)/i.test(j.title));
    for (const j of jobs.slice(0, 3)) {
      gh.push({
        company: board, source: 'boards-api.greenhouse.io', title: j.title, location: j.location?.name || '',
        experience: '', url: j.absolute_url, updated: (j.updated_at || '').slice(0, 10),
        requirements: (j.content || '').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim(),
      });
    }
    console.log(`${board}: jobs=${(json.jobs || []).length} matched=${jobs.length}`);
  } catch (error) { console.log(`${board}: ${error.message}`); }
}
fs.writeFileSync('raw.json', JSON.stringify({ collected_at: now, tencent: tencentUnique, greenhouse: gh }, null, 2));
console.log(`tencent=${tencentUnique.length} greenhouse=${gh.length} total=${tencentUnique.length + gh.length}`);
