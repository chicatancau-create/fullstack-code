//编写用户路由模块
//包含 登录/login，注册/register，修改个人信息/updateInfo
const express = require("express");
const router = express.Router(); // 创建路由对象
router.post("/login", (req, res) => {
  res.send("用户登录");
});

router.post("/register", (req, res) => {
  res.send("用户注册");
});

router.post("/updateInfo", (req, res) => {
  res.send("更新用户信息");
});

module.exports = router; //导出
