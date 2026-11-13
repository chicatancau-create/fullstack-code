console.log("开始");

// setTimeout 是异步操作：1 秒后执行回调
setTimeout(() => {
  console.log("延迟任务完成");
}, 1000);

function pr() {
  return new Promise((resolve, reject) => {
    // 模拟异步操作，1 秒后执行 resolve 
    setTimeout(() => {
      resolve(100)
    }, 1000);
  });
}

async function fs() {
  let result = await pr();
  console.log(result);
}
fs();

console.log("结束");