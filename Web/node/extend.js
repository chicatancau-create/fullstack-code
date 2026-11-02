// === 展开运算符 ===

// 展开数组
const nums = [1, 2, 3];
const combined = [...nums, 4, 5];
console.log(combined); // [1, 2, 3, 4, 5]

// 展开对象（合并配置时极为常用）
const defaults = { port: 3000, host: "localhost" };
const custom = { port: 8080 };
const config = { ...defaults, ...custom };
console.log(config); // { port: 8080, host: "localhost" }

// === 剩余参数 ===

// 收集多余参数
function sum(first, ...rest) {
  return first + rest.reduce((a, b) => a + b, 0);
}
console.log(sum(1, 2, 3, 4)); // 10

// 配合解构使用
const { name, ...others } = { name: "Alice", age: 25, role: "admin" };
console.log(name);   // "Alice"
console.log(others); // { age: 25, role: "admin" }