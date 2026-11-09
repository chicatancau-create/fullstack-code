#!/usr/bin/env bash
# 项目 03 一键验证：迁移 -> 真实 PostgreSQL 测试 -> 并发压测 -> 备份恢复。
# 仅使用本地 study_lab 的 p03 schema 与合成数据。
set -euo pipefail
cd "$(dirname "$0")/.."

export PGHOST=${PGHOST:-127.0.0.1}
export PGPORT=${PGPORT:-5432}
export PGUSER=${PGUSER:-study}
export PGDATABASE=${PGDATABASE:-study_lab}
export P03_API_KEY=${P03_API_KEY:-test-key}
export P03_PROVIDER_SECRET=${P03_PROVIDER_SECRET:-test-provider-secret}
if [ -z "${PGPASSWORD:-}" ]; then
  echo "需要 PGPASSWORD（本地合成账号密码），例如：PGPASSWORD=study-pass bash scripts/run_project.sh" >&2
  exit 2
fi

mkdir -p evidence
echo "node $(node -v) pg=$(node -p "require('pg/package.json').version")" | tee evidence/toolchain.txt

node scripts/migrate.mjs | tee evidence/migrate.txt

set +e
node --test --test-concurrency=1 tests/*.test.js 2>&1 | tee evidence/test.txt
tests_rc=${PIPESTATUS[0]}
set -e
if [ "$tests_rc" -ne 0 ]; then
  echo "FAIL tests rc=$tests_rc" | tee evidence/run.txt
  exit 1
fi

node scripts/load.mjs 2>&1 | tee evidence/load.txt
node scripts/mq_check.mjs 2>&1 | tee evidence/mq.txt
node scripts/mq_runtime_check.mjs 2>&1 | tee evidence/mq-runtime.txt
node scripts/worker_runtime_check.mjs 2>&1 | tee evidence/worker-runtime.txt
node scripts/fault_inject.mjs 2>&1 | tee evidence/fault-injection.txt
npm sbom --sbom-format=cyclonedx > evidence/sbom.json
npm audit --omit=dev --audit-level=high > evidence/audit.txt 2>&1 || true
node scripts/backup.mjs 2>&1 | tee evidence/backup.txt

{
  echo "captured_at: $(date -Is)"
  echo "node: $(node -v)"
  echo "migrate=PASS"
  echo "tests=PASS"
  echo "load=PASS"
  echo "mq=PASS"
  echo "mq_runtime=PASS"
  echo "worker_split=PASS"
  echo "fault_injection=PASS"
  echo "sbom=evidence/sbom.json"
  echo "audit=evidence/audit.txt (本机 npmmirror 不支持 advisories 接口，结果以文件内容为准)"
  echo "backup_restore=PASS"
  echo "PROJECT03 PASS"
} | tee evidence/run.txt
