// 导入文件操作的依赖
const fs=require('fs')
// 定义一个函数，封装promise
const readFilePromise=(filename)=>{
    return new Promise((resolve,reject)=>{
        fs.readFile(filename,"utf-8",(error,data)=>{
            if(error){
                reject(error)
            }else{
                resolve(data)
            }
        })
    })
}

// 执行函数
// console.log(readFilePromise("config.json"));
readFilePromise("config.json")
// res表示是返回的结果
.then(res=>{
    console.log(res);    
})
.catch(error=>{
    console.log(error);
    
})
