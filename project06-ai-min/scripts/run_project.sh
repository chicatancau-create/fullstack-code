#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
echo "node $(node -v)" | tee evidence/toolchain.txt
npm ci --no-audit --no-fund > evidence/install.txt 2>&1
npm test 2>&1 | tee evidence/test.txt
node scripts/eval.mjs 2>&1 | tee evidence/eval.txt
{
  echo "captured_at: $(date -Is)"
  echo "tests=$(grep -E '^ℹ (tests|pass|fail) ' evidence/test.txt | tr '\n' ' ')"
  echo "eval=$(grep 'golden_set=' evidence/eval.txt)"
  echo "AI-MIN PASS"
} | tee evidence/run.txt
