#!/usr/bin/env bash
# 项目 02 证据采集：迁移、真实 DB 测试、备份恢复。
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
if [ -z "${PGPASSWORD:-}" ]; then echo "缺少 PGPASSWORD" >&2; exit 2; fi
fails=0
node --check src/app.js > evidence/syntax.txt 2>&1; rc=$?; echo "syntax exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))
node scripts/migrate.mjs > evidence/migrate.txt 2>&1; rc=$?; echo "migrate exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))
node --test tests/*.test.js > evidence/test.txt 2>&1; rc=$?; echo "test exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))
node scripts/backup.mjs > evidence/backup.txt 2>&1; rc=$?; echo "backup exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))
bash scripts/deploy_local.sh > evidence/deploy.log 2>&1; rc=$?; echo "deploy exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))
bash scripts/rollback_check.sh > evidence/rollback.log 2>&1; rc=$?; echo "rollback exit=$rc"; [ "$rc" -eq 0 ] || fails=$((fails + 1))
{
  echo "captured_at: $(date -Is)"
  echo "migrate: $(tail -1 evidence/migrate.txt)"
  echo "test: $(grep -E '^ℹ (tests|pass|fail) ' evidence/test.txt | tr '\n' ' ')"
  echo "backup: $(grep 'RESTORE PASS' evidence/backup.txt || tail -1 evidence/backup.txt)"
  echo "gate_failures: $fails"
} | tee evidence/run.txt
exit "$fails"
