#!/usr/bin/env bash
# 项目 01 证据采集：typecheck / 组件测试 / 构建 / E2E。
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence

if [ ! -d node_modules/vite ]; then
  npm ci --no-audit --no-fund
fi

fails=0
NO_COLOR=1 npx tsc --noEmit > evidence/typecheck.txt 2>&1
rc=$?; echo "typecheck exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))

NO_COLOR=1 npx vitest run > evidence/test.txt 2>&1
rc=$?; echo "test exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))

NO_COLOR=1 npx vite build > evidence/build.txt 2>&1
rc=$?; echo "build exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))

node e2e/check.mjs > evidence/e2e-run.txt 2>&1
rc=$?; echo "e2e exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))

{
  echo "captured_at: $(date -Is)"
  echo "typecheck: $(grep -c 'error TS' evidence/typecheck.txt) errors"
  echo "test: $(grep -E 'Tests|Test Files' evidence/test.txt | tr '\n' ' ')"
  echo "build: $(grep -E 'built in|modules transformed' evidence/build.txt | tail -1)"
  echo "e2e: $(grep 'E2E PASS' evidence/e2e-run.txt || tail -1 evidence/e2e-run.txt)"
  echo "gate_failures: $fails"
} | tee evidence/run.txt

exit "$fails"
