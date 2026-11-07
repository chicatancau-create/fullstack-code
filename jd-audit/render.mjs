import fs from 'node:fs';
const file = 'E:/OBsidian/全栈工程师学习资料库/04-资源与评估/data/jd-samples-2026-11-07.json';
const data = JSON.parse(fs.readFileSync(file, 'utf8'));
const samples = data.samples;
const KW = {
  Java: /java\b/i, Go: /golang|\bgo\b/i, Python: /python/i, Node: /node\.?js|nodejs/i,
  TypeScript: /typescript/i, JavaScript: /javascript/i, React: /react/i, Vue: /vue/i,
  SQL: /mysql|postgres|\bsql\b/i, Redis: /redis/i, MongoDB: /mongodb/i,
  MQ: /kafka|rabbitmq|消息队列|\bmq\b/i, Docker: /docker/i, Kubernetes: /kubernetes|\bk8s\b/i,
  AI: /llm|\brag\b|agent|大模型|智能体|\bai\b/i,
};
const byCompany = {};
for (const j of samples) byCompany[j.company] = (byCompany[j.company] || 0) + 1;
const counts = Object.entries(KW).map(([name, re]) => [name, samples.filter((j) => re.test(j.requirements)).length]);
const rows = samples.map((j, i) => `| S-${String(i + 1).padStart(2, '0')} | ${j.company} | ${j.title.replace(/\|/g, '/')} | ${j.location || '—'} | ${j.experience || '—'} | [原文](${j.url}) | ${j.updated || '—'} |`).join('\n');
const companyRows = Object.entries(byCompany).sort((a, b) => b[1] - a[1]).map(([c, n]) => `| ${c} | ${n} |`).join('\n');
const kwRows = counts.map(([k, n]) => `| ${k} | ${n} | ${(n / samples.length * 100).toFixed(0)}% |`).join('\n');
const md = `# 官方 JD 扩充样本（2026-11-07）

**样本：${samples.length} 份｜公司：${Object.keys(byCompany).length} 家｜采集方式：官方招聘 API / 官方 ATS 接口｜采集日期：2026-11-07**

> 本文件是 [[真实JD样本与差距记录|人工逐条样本]] 的扩充，不替代原有 12 份逐条摘录与“必需/优先”频次统计。
>
> 数据来源：腾讯官方 \`careers.tencent.com\` 查询与详情 API（33 份）；GitLab、Cloudflare、Datadog、Stripe、MongoDB、Elastic、Mozilla、Canonical 的官方 Greenhouse 招聘板（24 份）；原有 6 份美团/Thoughtworks/字节跳动人工样本。原始文本（HTML 已剥离）见 [data/jd-samples-2026-11-07.json](data/jd-samples-2026-11-07.json)。
>
> **口径边界**：本表只证明“采集时官方页面/接口存在这些岗位与要求文本”，不证明仍在招聘、不证明投递可达；国际岗位的经验要求可能高于 3 年，不能代表中国应届市场。关键词统计是**全文提及**，不是“必需项”频次；Greenhouse 描述可能含公司介绍/福利等非要求文本，百分比只作技术栈覆盖参考。

## 一、样本清单

| # | 公司 | 岗位 | 地点 | 经验 | 官方 URL | 更新 |
| --- | --- | --- | --- | --- | --- | --- |
${rows}

## 二、公司分布

| 公司 | 样本数 |
| --- | --- |
${companyRows}

## 三、技术关键词覆盖（分母 ${samples.length}，全文提及）

| 关键词 | 命中 | 占比 |
| --- | --- | --- |
${kwRows}

## 四、能力域映射（自动口径，待人工复核）

| 关键词组 | 能力域 | 说明 |
| --- | --- | --- |
| Java / Go / Python / Node / TypeScript | M02/M06 | 语言与后端框架；需结合项目证据验证 |
| React / Vue / JavaScript | M03/M05 | 前端框架与工程化 |
| SQL / Redis / MongoDB | M07 | 数据建模、查询、缓存；SQL 命中低与海外岗位描述习惯有关 |
| MQ / Kubernetes / Docker | M08/M12 | 分布式与交付；本批样本提及率低，不能据此降低学习优先级 |
| AI / LLM / RAG / Agent | M15 + AI 专项 | 腾讯样本大量 AI 全栈岗位；M16 仍未决策 |

## 五、未完成

- 未逐条人工核对 ${samples.length} 份原文与“必需/优先”分类；原 12 份的人工频次仍是差距分析的基准。
- 未验证岗位是否仍开放、是否接受中国候选人、是否远程；未投递、未联系招聘方。
- 未把 ${samples.length} 份全部映射到课程/实验/项目；只做了关键词级映射。
- 国际公司样本占 ${samples.filter((j) => /Greenhouse/.test(j.source)).length} 份，不能代表中国岗位市场。
`;
fs.writeFileSync('E:/OBsidian/全栈工程师学习资料库/04-资源与评估/真实JD样本与差距记录-官方API扩充2026-11-07.md', md);
console.log(`rows=${samples.length} companies=${Object.keys(byCompany).length} bytes=${Buffer.byteLength(md)}`);
