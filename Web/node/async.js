console.log("开始");

// setTimeout 是异步操作：1 秒后执行回调
setTimeout(() => {
  console.log("延迟任务完成");
}, 1000);

console.log("结束");