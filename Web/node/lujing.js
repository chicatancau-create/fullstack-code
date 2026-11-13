const path = require("path");

// === path.join: 拼接路径片段 ===
path.join("foo", "bar", "baz");
// → "foo/bar/baz"（Linux）或 "foo\bar\baz"（Windows）

path.join("/home", "user", "..", "docs");
// → "/home/docs"（.. 返回上一级）

path.join("src", "routes", "user.js");
// → "src/routes/user.js"

// === path.resolve: 解析为绝对路径 ===
// 从右向左拼接，直到遇到绝对路径（以 / 开头）或到达根目录
path.resolve("foo", "bar");
// → "/当前工作目录/foo/bar"

path.resolve("/home", "user", "docs");
// → "/home/user/docs"（遇到 /home 就停了）

path.resolve("src", "app.js");
// → "/当前工作目录/src/app.js"

// === 两个最常用的特殊变量 ===
// __dirname: 当前文件所在目录的绝对路径
// __filename: 当前文件的绝对路径
console.log(__dirname);
// → "/home/user/my-project/src"

console.log(__filename);
// → "/home/user/my-project/src/app.js"

// 实际用法: 拼接出同级文件的绝对路径
const configPath = path.join(__dirname, "config.json");
// → "/home/user/my-project/src/config.json"