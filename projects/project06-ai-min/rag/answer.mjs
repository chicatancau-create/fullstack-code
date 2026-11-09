import { getLlama, LlamaChatSession } from 'node-llama-cpp';
import { retrieve } from './rag.mjs';

const cases = [
  { q: '退款多久到账？', tenant: 'A', gold: 'a1' },
  { q: '电子发票怎么开？', tenant: 'A', gold: 'a2' },
  { q: '企业月结账期多久？', tenant: 'B', gold: 'b1' },
  { q: '火星今天天气如何？', tenant: 'A', gold: null },
];

const llama = await getLlama();
const model = await llama.loadModel({ modelPath: process.env.MODEL_PATH || 'D:/Models/qwen2.5-0.5b-instruct-q4_k_m.gguf' });
const grammar = await llama.createGrammarForJsonSchema({
  type: 'object',
  properties: { answer: { type: 'string' }, citations: { type: 'array', items: { type: 'string' } }, refused: { type: 'boolean' } },
  required: ['answer', 'citations', 'refused'], additionalProperties: false,
});
let citationHits = 0;
let refusals = 0;
for (const item of cases) {
  const hits = retrieve(item.q, item.tenant, 3);
  if (hits.length === 0) {
    console.log(`q=${item.q} refused=true guard=no_retrieval citations=- gold_ok=${item.gold === null}`);
    if (item.gold === null) citationHits++;
    refusals++;
    continue;
  }
  const context = hits.map((h) => `[${h.id}] ${h.title}：${h.text}`).join('\n');
  const prompt = `只根据资料回答，citations 填资料 id。资料无法回答时 refused=true 且 citations=[]。\n资料：\n${context}\n问题：${item.q}`;
  const contextObj = await model.createContext({ contextSize: 768 });
  const session = new LlamaChatSession({ contextSequence: contextObj.getSequence() });
  const started = performance.now();
  const raw = await session.prompt(prompt, { grammar, maxTokens: 160, temperature: 0 });
  const ms = Math.round(performance.now() - started);
  const out = JSON.parse(raw);
  let citations = out.citations.filter((id) => hits.some((h) => h.id === id));
  let fallback = false;
  if (!out.refused && citations.length === 0) { citations = [hits[0].id]; fallback = true; }
  const refused = out.refused === true;
  const citedGold = item.gold ? citations.includes(item.gold) : refused;
  if (citedGold) citationHits++;
  if (refused) refusals++;
  console.log(`q=${item.q} ms=${ms} refused=${refused} citations=${citations.join(',') || '-'} fallback=${fallback} gold_ok=${citedGold} answer=${out.answer.slice(0, 80)}`);
  await contextObj.dispose();
}
console.log(`citation_or_refusal_ok=${citationHits}/${cases.length} refusals=${refusals}`);
console.log('RAG ANSWER DONE');
await model.dispose();
await llama.dispose();
