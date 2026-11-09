import { retrieve } from './rag.mjs';

const queries = [
  { q: '退款多久到账', tenant: 'A', gold: 'a1' },
  { q: '电子发票怎么开', tenant: 'A', gold: 'a2' },
  { q: '取消已支付订单', tenant: 'A', gold: 'a3' },
  { q: '顺丰物流单号', tenant: 'A', gold: 'a4' },
  { q: '积分抵扣规则', tenant: 'A', gold: 'a5' },
  { q: '企业月结账期', tenant: 'B', gold: 'b1' },
  { q: '批量上传 CSV', tenant: 'B', gold: 'b2' },
  { q: '子账号权限', tenant: 'B', gold: 'b5' },
  { q: '对公转账核销', tenant: 'B', gold: 'b4' },
  { q: '合同续约提醒', tenant: 'B', gold: 'b3' },
];
let recall = 0;
let precision = 0;
let leaks = 0;
for (const item of queries) {
  const hits = retrieve(item.q, item.tenant, 3);
  const goldHit = hits.some((h) => h.id === item.gold);
  const wrongTenant = hits.filter((h) => h.tenant !== item.tenant).length;
  if (goldHit) recall++;
  precision += hits.length ? (goldHit ? 1 : 0) / hits.length : 0;
  leaks += wrongTenant;
  console.log(`${goldHit ? 'HIT ' : 'MISS'} q=${item.q} tenant=${item.tenant} top=${hits.map((h) => h.id).join(',')}`);
}
console.log(`recall@3=${(recall / queries.length * 100).toFixed(0)}% precision@3=${(precision / queries.length * 100).toFixed(0)}% cross_tenant_leaks=${leaks}`);
if (leaks > 0) throw new Error('tenant leak');
console.log('RAG RETRIEVAL PASS');
