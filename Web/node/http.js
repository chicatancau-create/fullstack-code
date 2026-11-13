const http = require("http");

// 创建服务器: 传入一个回调函数，每次有请求到达时调用
const server = http.createServer((req, res) => {
  // req: 请求对象（IncomingMessage）— 包含请求信息
  // res: 响应对象（ServerResponse）— 用于发送响应

  // 写入响应头
  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });

  // 写入响应体
  res.end("<h1>Hello, Node.js!</h1>");
});

// 监听端口
server.listen(3000, () => {
  console.log("服务器已启动: http://localhost:3000");
});