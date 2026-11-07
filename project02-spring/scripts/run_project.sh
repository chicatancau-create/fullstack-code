#!/usr/bin/env bash
# 批次 5：Java/Spring Boot/MySQL 同契约迁移验证 + JVM/MySQL 诊断证据。
set -euo pipefail
cd "$(dirname "$0")/.."

export DB_URL=${DB_URL:-jdbc:mysql://127.0.0.1:3307/p02j?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=utf8}
export DB_USER=${DB_USER:-study}
export DB_PASSWORD=${DB_PASSWORD:-study-pass}
MYSQL_BIN=${MYSQL_BIN:-D:/MySQL/server/bin}
mkdir -p evidence
email="java-owner-$(date +%s)@example.com"
echo "java $(java -version 2>&1 | head -1)" | tee evidence/toolchain.txt
echo "maven $(mvn -version 2>&1 | head -1)" | tee -a evidence/toolchain.txt

mvn -B -ntp test 2>&1 | tee evidence/test.txt
mvn -B -ntp -DskipTests package 2>&1 | tee evidence/package.txt

java -jar target/project02-spring-1.0.0.jar > evidence/app.log 2>&1 &
app_pid=$!
cleanup() { kill "$app_pid" 2>/dev/null || true; taskkill //PID "$app_pid" //F >/dev/null 2>&1 || true; }
trap cleanup EXIT
for i in $(seq 1 40); do
  curl -fsS http://127.0.0.1:8798/health >/dev/null 2>&1 && break
  sleep 1
done

{
  echo "health: $(curl -fsS http://127.0.0.1:8798/health)"
  curl -fsS -X POST http://127.0.0.1:8798/auth/register -H 'content-type: application/json' -d "{\"email\":\"$email\",\"password\":\"correct-horse-1\"}"; echo
  token=$(curl -fsS -X POST http://127.0.0.1:8798/auth/login -H 'content-type: application/json' -d "{\"email\":\"$email\",\"password\":\"correct-horse-1\"}" | python -X utf8 -c "import sys,json;print(json.load(sys.stdin)['token'])")
  ws=$(curl -fsS -X POST http://127.0.0.1:8798/workspaces -H "authorization: Bearer $token" -H 'content-type: application/json' -d '{"name":"Java Migration"}')
  echo "workspace: $ws"
  id=$(printf '%s' "$ws" | python -X utf8 -c "import sys,json;print(json.load(sys.stdin)['id'])")
  task=$(curl -fsS -X POST http://127.0.0.1:8798/workspaces/$id/tasks -H "authorization: Bearer $token" -H 'content-type: application/json' -d '{"title":"contract-task"}')
  echo "task: $task"
  echo "tasks: $(curl -fsS http://127.0.0.1:8798/workspaces/$id/tasks -H "authorization: Bearer $token")"
  echo "unauth_status: $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8798/workspaces)"
} | tee evidence/http.txt

jpid=$(jps -l | awk '/project02-spring-1.0.0.jar/ {print $1; exit}')
{
  echo "jps: $(jps -l | grep project02-spring || true)"
  jcmd "$jpid" VM.version
  jcmd "$jpid" GC.heap_info
  jcmd "$jpid" Thread.print | grep -E '^"' | head -20
} > evidence/jvm.txt 2>&1
echo "jvm_pid=$jpid" | tee -a evidence/jvm.txt

"$MYSQL_BIN/mysql" --protocol=tcp -h127.0.0.1 -P3307 -ustudy -pstudy-pass -e "
  SELECT VERSION() AS mysql_version;
  SHOW VARIABLES LIKE 'max_connections';
  SELECT COUNT(*) AS users FROM p02j.users;
  SELECT COUNT(*) AS tasks FROM p02j.tasks;
" > evidence/mysql.txt 2>&1

{
  echo "captured_at: $(date -Is)"
  echo "tests: $(grep -E 'Tests run: [0-9]+, Failures' evidence/test.txt | tail -1)"
  echo "http=health+register+login+workspace+task"
  echo "jvm=version+heap+threads"
  echo "mysql=version+max_connections+counts"
  echo "JAVA-MYSQL PASS"
} | tee evidence/run.txt
