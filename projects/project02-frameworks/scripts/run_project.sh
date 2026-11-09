#!/usr/bin/env bash
# B5-03：Express 5 / NestJS 12 同契约测试与启动测量。
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence

{
  echo "node $(node -v)"
  echo "npm $(npm -v)"
  node -p "const p=require('./package.json'); JSON.stringify({express:p.dependencies.express,nest:p.dependencies['@nestjs/core'],typescript:p.devDependencies.typescript})"
} | tee evidence/versions.txt

rm -rf dist
npm run test:all 2>&1 | tee evidence/test.txt
node scripts/boot.mjs 2>&1 | tee evidence/boot.txt

{
  echo "captured_at: $(date -Is)"
  echo "contract=express+nest"
  echo "tests=$(grep -E '^ℹ (tests|pass|fail) ' evidence/test.txt | tr '\n' ' ')"
  echo "FRAMEWORKS PASS"
} | tee evidence/run.txt
