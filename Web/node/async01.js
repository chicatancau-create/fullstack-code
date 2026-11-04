console.log("1. 同步代码");

setTimeout(() => {
  console.log("4. 宏任务（setTimeout）");
}, 0);

Promise.resolve().then(() => {
  console.log("3. 微任务（Promise）");
});

console.log("2. 同步代码");