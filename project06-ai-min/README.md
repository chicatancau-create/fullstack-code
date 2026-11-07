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

## 证据

- `evidence/test.txt`：8/8 通过。
- `evidence/eval.txt`：golden set 5/5（mock），只验证行为分支，不代表模型质量。
- `evidence/run.txt`：本轮汇总。

## 未实现 / 未验证

- 未接真实模型；未测真实结构化输出成功率、拒答率、引用正确率、P95、成本。
- 无 RAG/Embedding/重排/跨租户检索/提示注入防护；无人工抽检。
- 无 Docker/Compose、CI、K8s、OTel、告警与部署。
- 工具只有本地合成订单查询；无权限模型与审计。
- golden set 仅 5 条，且与测试 mock 同源，不能当作独立评估集。
