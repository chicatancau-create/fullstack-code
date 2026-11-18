const express = require("express");
const router = express.Router(); // 创建路由对象
router.post("/list", (req, res) => {
  res.send("查询用户列表");
});

router.post("/getCartById", (req, res) => {
  res.send("查询用户ID是：" + req.body.id);
});

module.exports = router; //导出
