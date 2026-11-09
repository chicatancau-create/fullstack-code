# project06-ai-min：最小 LLM 应用骨架

> **边界**：本机没有可用的真实 LLM 端点，本项目的测试与评估全部针对**本地 mock 服务**。
> 它证明客户端工程行为（结构化输出、工具调用、超时/429 重试、拒答、密钥、版本、成本记录），
> **不证明**真实模型质量、RAG、引用正确率或生产可用性。

## 能力

- `POST /chat`：调用 OpenAI 兼容的 `/v1/chat/completions`，要求 JSON 输出并做形状校验。
- 工具调用：模型返回 `tool_call` 时执行本地 `lookup_order`（合成数据），最多一轮，再把结果回传。
- 超时（默认 2s）与 429/5xx 重试一次；非法输出直接 502，不盲目重试。
- 拒答：`refused=true` 原样返回，不重试。
- Prompt 版本 `v1` 通过请求头与响应返回；`GET /prompt` 可查。
- 成本：优先用上游 `usage`，否则按字符估算；响应 `cost_usd`。
- 密钥只从 `LLM_API_KEY` 读取；缺失返回 503，日志不打印密钥。

## 运行

```bash
npm ci
npm test                       # 8 个测试，本地 mock
node scripts/eval.mjs          # 5 条 golden set，本地 mock
bash scripts/run_project.sh    # 安装 + 测试 + 评估 + 证据
```

真实模型（未验证）：

```bash
export LLM_BASE_URL=https://your-endpoint LLM_API_KEY=... LLM_MODEL=...
npm start                      # 127.0.0.1:8800
```

## RAG 基线（BM25，非 embedding）

- 12 条合成语料，租户 A/B；BM25 检索 + 租户过滤，`rag/eval.mjs`：**recall@3=100%、precision@3=82%、跨租户泄漏=0**。
- 本地 0.5B 回答 3 条可答问题，模型本身**不输出 citations**；用“检索结果引用回填 + 无检索则拒答”
  守卫后，引用/拒答正确 4/4（3 条回填、1 条 no_retrieval 拒答）。
- 未实现 embedding/重排/多跳；语料与查询为合成数据，指标不能外推到真实知识库。
- 证据：`evidence/rag.txt`、`evidence/rag-answer.txt`。

## 本地真实模型验证（0.5B，CPU）

本机无 API key，使用 `node-llama-cpp` + Qwen2.5-0.5B-Instruct Q4（469MB，模型文件不入库）：

```bash
# 下载到 D:/Models（或设 MODEL_PATH）
curl -L -o D:/Models/qwen2.5-0.5b-instruct-q4_k_m.gguf   https://hf-mirror.com/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf
npm run real        # 无语法约束：4 条输出 0/4 是严格 JSON
npm run real:app    # 本地 server + JSON grammar：4/4 返回 200，耗时 0.4–0.8s/条
```

- 约束解码（JSON Schema grammar）让 0.5B 输出合法结构；原始模型会输出无引号键或代码围栏，0/4 严格可解析。
- 真实输出仍暴露问题：tool_call 未生成、无资料问题置信度偏高、提示注入输出“已越权”（仅结构校验，无内容防护）。
- 模型只在本机 CPU 运行；不是生产模型，不代表真实 LLM 质量。

## 证据

- `evidence/test.txt`：8/8 通过。
- `evidence/eval.txt`：golden set 5/5（mock），只验证行为分支，不代表模型质量。
- `evidence/real-model.txt`：无语法约束的原始输出（0/4 严格 JSON）。
- `evidence/real-app.txt`：本地 server + grammar 的 4 条真实请求/响应与耗时。
- `evidence/run.txt`：本轮汇总。

## 未实现 / 未验证

- 已接本地 0.5B 模型做工程验证；未接生产 LLM，未测引用正确率、真实拒答率与生产成本。
- 无 RAG/Embedding/重排/跨租户检索/提示注入防护；无人工抽检。
- 无 Docker/Compose、CI、K8s、OTel、告警与部署。
- 工具只有本地合成订单查询；无权限模型与审计。
- golden set 仅 5 条，且与测试 mock 同源，不能当作独立评估集。
