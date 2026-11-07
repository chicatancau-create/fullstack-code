#!/usr/bin/env bash
# 项目 01 本地 HTTPS 部署：构建 + vite preview + 自签名反代。仅本机。
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
tls=$(mktemp -d)
cleanup() { kill "${gateway_pid:-}" "${preview_pid:-}" 2>/dev/null || true; taskkill //PID "${gateway_pid:-0}" //F >/dev/null 2>&1 || true; taskkill //PID "${preview_pid:-0}" //F >/dev/null 2>&1 || true; rm -rf "$tls"; }
trap cleanup EXIT
npm ci --no-audit --no-fund >/dev/null 2>&1
npm run build > evidence/deploy-build.log 2>&1
openssl req -x509 -newkey rsa:2048 -nodes -days 2 -keyout "$tls/key.pem" -out "$tls/cert.pem" \
  -subj "//CN=127.0.0.1" -addext "subjectAltName=IP:127.0.0.1,DNS:localhost" >/dev/null 2>&1
node node_modules/vite/bin/vite.js preview --port 4173 --strictPort --host 127.0.0.1 > evidence/preview.log 2>&1 &
preview_pid=$!
TLS_KEY="$tls/key.pem" TLS_CERT="$tls/cert.pem" HTTPS_PORT=9445 APP_URL="http://127.0.0.1:4173" node scripts/https_gateway.mjs > evidence/https-gateway.log 2>&1 &
gateway_pid=$!
for i in $(seq 1 30); do curl -fsS --cacert "$tls/cert.pem" https://127.0.0.1:9445/ >/dev/null 2>&1 && break; sleep 1; done
{
  echo "== https home"
  curl -sS --cacert "$tls/cert.pem" -o /dev/null -D - https://127.0.0.1:9445/ | grep -Ei "^HTTP|strict-transport|x-content"
  echo "== tls"
  echo | openssl s_client -connect 127.0.0.1:9445 -tls1_2 2>/dev/null | grep -E "Protocol|Cipher" | head -2
} | tee evidence/deploy.txt
echo "DEPLOY PASS" | tee -a evidence/deploy.txt
