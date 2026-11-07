# JD 采集与复核工具

2026-11-07 批次 7 使用的一次性脚本，保留以便复核：
- `collect2.mjs`：腾讯官方 Query/ByPostId API + 8 家官方 Greenhouse 板，生成资料库 `04-资源与评估/data/jd-samples-2026-11-07.json`。
- `repair.mjs`：修复人工样本解析边界（遇 `##` 停止），重算手工 6 份文本。
- `render.mjs`：生成扩充样本 Markdown（清单、公司分布、关键词全文提及统计）。
- `check-urls.mjs`：对 63 个 URL 做 HEAD，保存 `jd-url-check-2026-11-07.json`。

边界：URL 200 不代表岗位仍开放；关键词统计不是“必需项”频次；国际岗位不具中国应届市场代表性。
