#!/usr/bin/env bash
# B5-02：Hikari 连接池指标 + MySQL 行锁等待诊断（无 Docker/Testcontainers）。
set -euo pipefail
cd "$(dirname "$0")/.."

export DB_URL=${DB_URL:-jdbc:mysql://127.0.0.1:3307/p02j?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=utf8}
export DB_USER=${DB_USER:-study}
export DB_PASSWORD=${DB_PASSWORD:-study-pass}
MYSQL_BIN=${MYSQL_BIN:-D:/MySQL/server/bin}
mkdir -p evidence
: > evidence/diagnose.txt

mvn -B -ntp -DskipTests package > evidence/package-diag.txt 2>&1
java -jar target/project02-spring-1.0.0.jar > evidence/diag-app.log 2>&1 &
app_pid=$!
cleanup() { kill "$app_pid" 2>/dev/null || true; taskkill //PID "$app_pid" //F >/dev/null 2>&1 || true; }
trap cleanup EXIT
for i in $(seq 1 40); do curl -fsS http://127.0.0.1:8798/health >/dev/null 2>&1 && break; sleep 1; done

email="diag-pool-$(date +%s)@example.com"
curl -fsS -X POST http://127.0.0.1:8798/auth/register -H 'content-type: application/json' -d "{\"email\":\"$email\",\"password\":\"correct-horse-1\"}" >/dev/null
token=$(curl -fsS -X POST http://127.0.0.1:8798/auth/login -H 'content-type: application/json' -d "{\"email\":\"$email\",\"password\":\"correct-horse-1\"}" | python -X utf8 -c "import sys,json;print(json.load(sys.stdin)['token'])")
ws=$(curl -fsS -X POST http://127.0.0.1:8798/workspaces -H "authorization: Bearer $token" -H 'content-type: application/json' -d '{"name":"Lock Diagnostics"}')
wid=$(printf '%s' "$ws" | python -X utf8 -c "import sys,json;print(json.load(sys.stdin)['id'])")

node --input-type=module -e "
  const token = process.argv[1];
  const results = await Promise.all(Array.from({ length: 40 }, () => fetch('http://127.0.0.1:8798/workspaces', { headers: { authorization: 'Bearer ' + token } }).then((r) => r.status).catch(() => 0)));
  const counts = {};
  for (const status of results) counts[status] = (counts[status] || 0) + 1;
  console.log('HTTP statuses: ' + JSON.stringify(counts));
" "$token" >> evidence/diagnose.txt
curl -fsS -H "authorization: Bearer $token" http://127.0.0.1:8798/actuator/metrics/hikaricp.connections.active > evidence/pool-active.json
curl -fsS -H "authorization: Bearer $token" http://127.0.0.1:8798/actuator/metrics/hikaricp.connections.max > evidence/pool-max.json
curl -fsS -H "authorization: Bearer $token" http://127.0.0.1:8798/actuator/metrics/hikaricp.connections.idle > evidence/pool-idle.json
{
  echo "hikaricp.active: $(cat evidence/pool-active.json)"
  echo "hikaricp.max: $(cat evidence/pool-max.json)"
  echo "hikaricp.idle: $(cat evidence/pool-idle.json)"
} >> evidence/diagnose.txt

MYSQL_PWD=study-pass "$MYSQL_BIN/mysql" --protocol=tcp -h127.0.0.1 -P3307 -ustudy -e "SET SESSION innodb_lock_wait_timeout=10; START TRANSACTION; SELECT id FROM p02j.workspaces WHERE id=$wid FOR UPDATE; DO SLEEP(8); ROLLBACK;" >/dev/null 2>&1 &
locker=$!
sleep 1
set +e
MYSQL_PWD=study-pass "$MYSQL_BIN/mysql" --protocol=tcp -h127.0.0.1 -P3307 -ustudy -e "SET SESSION innodb_lock_wait_timeout=2; UPDATE p02j.workspaces SET name=name WHERE id=$wid" > evidence/locks.txt 2>&1
rc=$?
set -e
{
  echo "second_session_exit=$rc (1205=lock wait timeout expected)"
  cat evidence/locks.txt
  echo "--- data_locks (root) ---"
  "$MYSQL_BIN/mysql" --protocol=tcp -h127.0.0.1 -P3307 -uroot -e "SELECT OBJECT_SCHEMA, OBJECT_NAME, LOCK_TYPE, LOCK_MODE, LOCK_STATUS FROM performance_schema.data_locks LIMIT 10;" 2>&1 || true
} >> evidence/diagnose.txt
wait "$locker" 2>/dev/null || true
echo "DIAGNOSE DONE wid=$wid" >> evidence/diagnose.txt
