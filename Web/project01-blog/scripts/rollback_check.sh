#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
repo=$(pwd)
current=$(git -C /e/fullstack-code rev-parse --short HEAD)
previous=$(git -C /e/fullstack-code rev-parse --short HEAD~1)
tmp=$(mktemp -d)
cleanup() { kill "${preview_pid:-}" 2>/dev/null || true; taskkill //PID "${preview_pid:-0}" //F >/dev/null 2>&1 || true; rm -rf "$tmp"; }
trap cleanup EXIT
git -C /e/fullstack-code archive "$previous" Web/project01-blog | tar -x -C "$tmp"
cd "$tmp/Web/project01-blog"
npm ci --no-audit --no-fund >/dev/null 2>&1
npm run build >/dev/null 2>&1
node node_modules/vite/bin/vite.js preview --port 4174 --strictPort --host 127.0.0.1 > rollback.log 2>&1 &
preview_pid=$!
for i in $(seq 1 30); do code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:4174/); [ "$code" = "200" ] && break; sleep 1; done
{ echo "current=$current previous=$previous"; echo "rollback_status=$code"; test "$code" = "200" && echo "ROLLBACK PASS"; } | tee "$repo/evidence/rollback.txt"
