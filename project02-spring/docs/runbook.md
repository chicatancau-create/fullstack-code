# 本地运行手册（Java/MySQL 迁移版）

## MySQL（便携版）

启动：

```bash
D:/MySQL/server/bin/mysqld --basedir=D:/MySQL/server --datadir=D:/MySQL/data \
  --port=3307 --bind-address=127.0.0.1 --mysqlx=0 --console
```

检查：

```bash
D:/MySQL/server/bin/mysqladmin --protocol=tcp -h127.0.0.1 -P3307 -uroot ping
D:/MySQL/server/bin/mysql --protocol=tcp -h127.0.0.1 -P3307 -ustudy -pstudy-pass -e "SELECT VERSION();"
```

停止：在 mysqld 控制台按 Ctrl+C；或 `D:/MySQL/server/bin/mysqladmin ... -uroot shutdown`。
便携版未注册 Windows 服务，机器重启后需手动启动。

## 应用

```bash
export DB_PASSWORD=study-pass
mvn -B -ntp test                 # 使用 p02j_test
mvn -B -ntp -DskipTests package
java -jar target/project02-spring-1.0.0.jar   # 使用 p02j，端口 8798
```

## 证据采集

`bash scripts/run_project.sh` 会依次执行测试、打包、启动、HTTP 冒烟、JVM/MySQL 诊断并写入 `evidence/`。
脚本退出即停止应用；MySQL 保持运行。

## 故障排查

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `Access denied` | 密码/用户名不符 | 使用本地合成账号；不要把密码写进仓库 |
| `Unknown database 'p02j'` | 未建库 | 用 root 建 `p02j`、`p02j_test` 并授权 |
| 400 且日志无业务异常 | Git Bash 中文 JSON 被转码 | 改用 ASCII 或 UTF-8 文件 `--data-binary` |
| 端口 8798 占用 | 上次进程未退出 | `jps -l` 找 PID，确认后结束 |
| 测试连到错误库 | 未激活 test profile | 检查 `application-test.properties` |

## 边界

无 Docker/CI/K8s、无备份恢复、无 TLS、无限流；仅供本地合成数据验证。
