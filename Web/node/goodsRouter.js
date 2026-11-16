const db = require("./config/db"); // 导入数据库连接池对象
const express = require("express");
const router = express.Router(); // 创建路由对象
router.get("/list", async (req, res) => {
  let sql = "SELECT * FROM t_goods";
  const [data] = await db.execute(sql);
  res.send(data);
});

router.get("/:id", async (req, res) => {
  let sql = "SELECT * FROM t_goods WHERE id=" + req.params.id;
  const [data] = await db.execute(sql);
  if(data.length > 0) {
    res.send({
      code: 200,
      message: "查询成功",
      data: data[0]
    });
  } else {
    res.send({
      code: 404,
      message: "商品不存在"
    });
  }
});

module.exports = router; //导出
