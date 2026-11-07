#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
repo=$(pwd)
export PGHOST=${PGHOST:-127.0.0.1}
export PGPORT=${PGPORT:-5432}
export PGUSER=${PGUSER:-study}
export PGDATABASE=${PGDATABASE:-study_lab}
if [ -z "${PGPASSWORD:-}" ]; then echo "需要 PGPASSWORD" >&2; exit 2; fi
current=$(git -C /e/fullstack-code rev-parse --short HEAD)
previous=$(git -C /e/fullstack-code rev-parse --short HEAD~1)
tmp=$(mktemp -d)
cleanup() { kill "${app_pid:-}" 2>/dev/null || true; taskkill //PID "${app_pid:-0}" //F >/dev/null 2>&1 || true; rm -rf "$tmp"; }
trap cleanup EXIT
git -C /e/fullstack-code archive "$previous" project02-collab | tar -x -C "$tmp"
cd "$tmp/project02-collab"
npm ci --no-audit --no-fund >/dev/null 2>&1
PORT=8795 node src/server.js > rollback-app.log 2>&1 &
app_pid=$!
for i in $(seq 1 30); do code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8795/workspaces); [ "$code" = "401" ] && break; sleep 1; done
{ echo "current=$current previous=$previous"; echo "rollback_status=$code (old version has no /health, /workspaces 401 proves auth chain)"; } | tee "$repo/evidence/rollback.txt"
test "$code" = "401" && echo "ROLLBACK PASS" | tee -a "$repo/evidence/rollback.txt"
