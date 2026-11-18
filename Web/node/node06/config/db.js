// 导入mysql2在依赖
const mysql = require("mysql2/promise");
// 创建连接池
const db = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "123qwe...",
  database: "shopdb",
  port: 3306,
});
module.exports = db;
