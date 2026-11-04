const fs = require("fs");

// Node.js 回调的约定：第一个参数是错误对象，后续参数是结果
fs.readFile("config.json", "utf8", (err, data) => {
  if (err) {
    console.error("读取失败:", err.message);
    return;
  }
  console.log("文件内容:", data);
});

console.log("这行会先执行");