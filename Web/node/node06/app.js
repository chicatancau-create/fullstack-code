const express = require('express')
const app = express()
app.use(express.json())
// 导入商品模块
const goodsRouter = require('./router/goodsRouter')
// 导入用户模块
const userRouter=require('./router/userRouter')


// 主路由
app.use('/goods', goodsRouter)
app.use('/user',userRouter)
app.get('/', (req, res) => { res.send("OK") })
app.listen(3000, () => {
    console.log("server is running at port 3000.");
})