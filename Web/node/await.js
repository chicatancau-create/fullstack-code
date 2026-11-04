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


async function readFile(filename) {
   try{
    console.log("优先执行。");    
    let result=await readFilePromise(filename) 
    console.log(result);   
    console.log("最终步骤。");
   }catch(error){
    console.log(error);    
   }
        
}

readFile("config.json")