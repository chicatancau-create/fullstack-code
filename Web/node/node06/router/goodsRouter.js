const express = require('express')
// 创建路由对象
const router = express.Router()
// 导入db数据库连接池
const db = require('../config/db')

router.get("/list", async (req, res) => {
    const sql = "select * from t_goods"
    const [data] = await db.query(sql)
    res.send({
        code: 200,
        msg: "查询成功",
        data
    })
})

// 根据id查询商品
router.get("/:id", async (req, res) => {
    const sql = "select * from t_goods where id = ?"
    const [data] = await db.query(sql, [req.params.id])
    if (data.length === 0) {
        return res.send({ code: 404, msg: "商品不存在" })
    }
    res.send({ code: 200, msg: "查询成功", data: data[0] })
})

// 添加记录
router.post("/add", async (req, res) => {
    const { title, content, imagePath, price } = req.body //req.body获取post请求参数
    const sql = "insert into t_goods(title, content, imagePath, price) values(?, ?, ?, ?)"
    const [data] = await db.execute(sql, [title, content, imagePath, price])
    console.log(data)
    if (data.affectedRows > 0) {
        res.send("插入成功")
    } else {
        res.send("服务器错误")
    }
})

// 修改记录
router.post("/update", async (req, res) => {
    const { title, content, imagePath, price, id } = req.body
    const sql = "update t_goods set title = ?, content = ?, imagePath = ?, price = ? where id = ?"
    const [data] = await db.execute(sql, [title, content, imagePath, price, id])
    if (data.affectedRows > 0) {
        res.send("修改成功")
    } else {
        res.send("服务器错误")
    }
})

// 删除记录
router.post("/delete", async (req, res) => {
    const { id } = req.body
    const sql = "delete from t_goods where id = ?"
    const [data] = await db.execute(sql, [id])
    if (data.affectedRows > 0) {
        res.send("删除成功")
    } else {
        res.send("服务器错误")
    }
})

// 导出商品模块
module.exports = router
