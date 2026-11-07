import fs from 'node:fs';
import path from 'node:path';

const docs = JSON.parse(fs.readFileSync(path.join(import.meta.dirname, 'corpus.json'), 'utf8'));

function tokens(text) {
  const lower = String(text).toLowerCase();
  const words = lower.split(/[^\p{L}\p{N}]+/u).filter(Boolean);
  const grams = [];
  for (const word of words) {
    if (/[\u4e00-\u9fff]/.test(word)) {
      for (let i = 0; i < word.length - 1; i++) grams.push(word.slice(i, i + 2));
      grams.push(word);
    } else grams.push(word);
  }
  return grams;
}

const index = docs.map((doc) => ({ doc, tf: tokens(`${doc.title} ${doc.text}`).reduce((m, t) => m.set(t, (m.get(t) || 0) + 1), new Map()) }));
const avgLen = index.reduce((sum, d) => sum + [...d.tf.values()].reduce((a, b) => a + b, 0), 0) / docs.length;
const df = new Map();
for (const { tf } of index) for (const term of tf.keys()) df.set(term, (df.get(term) || 0) + 1);

export function retrieve(query, tenant, k = 3) {
  const q = tokens(query);
  const scored = index
    .filter(({ doc }) => doc.tenant === tenant)
    .map(({ doc, tf }) => {
      const len = [...tf.values()].reduce((a, b) => a + b, 0);
      let score = 0;
      for (const term of q) {
        const f = tf.get(term) || 0;
        if (f === 0) continue;
        const idf = Math.log(1 + (docs.length - df.get(term) + 0.5) / (df.get(term) + 0.5));
        score += idf * ((f * 2.2) / (f + 1.2 * (0.25 + 0.75 * len / avgLen)));
      }
      return { ...doc, score };
    })
    .filter((d) => d.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, k);
  return scored;
}
