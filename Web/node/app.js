// 导入依赖文件
const express=require('express')
// 实例化对象
const app=express()
app.use(express.json())
app.use(express.static("public"))
app.use(express.urlencoded({extended:true}))
const fruits = [
    {
        fruitName: '苹果',
        fruitQuantity: 30,
        fruitPrice: 3.8
    },
    {
        fruitName: '西瓜',
        fruitQuantity: 240,
        fruitPrice: 1.8
    },
    {
        fruitName: '芒果',
        fruitQuantity: 60,
        fruitPrice: 7.8
    }
]

// 1. /api/fruits/list  查询全部水果
app.get('/api/fruits/list', (req, res)=>{
    res.send(fruits)
})

// 2. /api/fruits/:id  根据id查询（数组下标，从0开始）
app.get('/api/fruits/:id', (req, res)=>{
    let id = req.params.id
    let item = fruits[id]
    if(item){
        res.send(item)
    }else{
        res.send({msg:"没有这个水果"})
    }
})

app.get("/api/fruits/:id", (req, res)=>{
    res.send(products[req.params.id])
})

app.post('/app/products/login',(req,res)=>{
    if(req.body.username==="zs"&&req.body.password=="123456"){
        res.send("登录成功")
    }else{
        res.send("登录失败")
    }
})

app.get('/api/user',(req,res)=>{
    if(req.query.username==="zs"&&req.query.password=="123456"){
        res.send("登录成功")
    }else{
        res.send("登录失败")
    }
})

app.use((req,res)=>{
    res.status(404).redirect('404.html')
})
// 监听端口4000
app.listen(3000,()=>{
    console.log("server is running at port 3000.");
})

