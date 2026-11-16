const express = require("express");
const app = express();
app.use(express.json()); // 解析json格式的请求体
app.use("/", express.static("./public")); // 静态资源托管
app.use(express.urlencoded({ extended: true })); // 解析urlencoded格式的请求体
const goodsRouter = require("./goodsRouter"); // 导入路由模块
const cartRouter = require("./cartRouter"); // 导入路由模块
const userRouter = require("./userRouter"); // 导入路由模块

app.use("/api/goods", goodsRouter); // 挂载路由模块
app.use("/api/cart", cartRouter); // 挂载路由模块
app.use("/api/user", userRouter); // 挂载路由模块

app.post("/api/user/login", (req, res) => {
  if (req.body.username === "admin" && req.body.password === "123456") {
    res.send("登录成功");
  } else {
    res.send("登录失败");
  }
});
app.listen(3000, () => {
  console.log("server is running at port 3000");
});
