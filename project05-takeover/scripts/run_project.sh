#!/usr/bin/env bash
# 项目 05：受控仓库接手回归与证据。
set -euo pipefail
cd "$(dirname "$0")/.."
export PGHOST=${PGHOST:-127.0.0.1}
export PGPORT=${PGPORT:-5432}
export PGUSER=${PGUSER:-study}
export PGDATABASE=${PGDATABASE:-study_lab_p05}
if [ -z "${PGPASSWORD:-}" ]; then
  echo "需要 PGPASSWORD（本地合成账号密码）" >&2
  exit 2
fi
NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
if [ "$NODE_MAJOR" -lt 24 ]; then
  echo "需要 Node >= 24（当前 $(node -v)）：低版本 reporter 输出 TAP，会破坏证据采集" >&2
  exit 3
fi
mkdir -p evidence
echo "node $(node -v)" | tee evidence/toolchain.txt
node scripts/migrate.mjs | tee evidence/migrate.txt
node scripts/d90_perf.mjs | tee evidence/d90-perf-run.txt

set +e
node --test tests/regressions.test.js 2>&1 | tee evidence/test.txt
rc=${PIPESTATUS[0]}
set -e
tests_line=$(grep -E '^(ℹ |# )(tests|pass|fail) ' evidence/test.txt | tr '\n' ' ' || true)
{
  echo "captured_at: $(date -Is)"
  echo "tests=$tests_line"
  echo "before_fix=$(grep -E '^(ℹ |# )(pass|fail) ' evidence/before-fix.txt | tr '\n' ' ')"
  echo "after_fix=$(grep -E '^(ℹ |# )(pass|fail) ' evidence/after-fix.txt | tr '\n' ' ')"
} | tee evidence/run.txt
if [ -z "$(printf '%s' "$tests_line" | tr -d ' ')" ]; then
  echo "TAKEOVER FAIL: 测试计数提取为空（Node reporter 不兼容）" | tee -a evidence/run.txt
  exit 4
fi
if [ "$rc" -ne 0 ]; then
  echo "TAKEOVER FAIL rc=$rc" | tee -a evidence/run.txt
  exit 1
fi
echo "TAKEOVER PASS" | tee -a evidence/run.txt
