//数据库连接文件
const mysql = require("mysql2/promise");//引入mysql模块

//实例化连接池对象
const pool = mysql.createPool({
  host: "localhost", //数据库地址
  user: "root", //数据库用户名
  password: "123qwe...", //数据库密码
  database: "shopdb", //数据库名称
  port: 3306, //数据库端口号
  connectionLimit: 20, //连接池中连接的最大数量
});

//导出连接池对象
module.exports = pool;
