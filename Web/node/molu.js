const fsp = require("fs").promises;
const fs = require("fs");

(async () => {
  // === 创建目录 ===
  // recursive: true 类似 mkdir -p，父目录不存在时自动创建
  await fsp.mkdir("./uploads/avatars/2025", { recursive: true });

  // === 读取目录内容 ===
  const files = await fsp.readdir("./uploads");
  console.log(files); // ["a.txt", "b.jpg", "subdir"]

  // === 获取文件/目录信息 ===
  const stats = await fsp.stat("./uploads/a.txt");
  console.log(stats.isFile());      // true
  console.log(stats.isDirectory()); // false
  console.log(stats.size);          // 文件大小（字节）
  console.log(stats.mtime);         // 最后修改时间

  // === 判断路径是否存在 ===
  // 注意: fs.exists() 已废弃，用 fs.access() 或 fs.stat() 替代
  try {
    await fsp.access("./config.json");
    console.log("文件存在");
  } catch {
    console.log("文件不存在");
  }

  // === 递归读取目录下所有文件 ===
  async function readDirRecursive(dirPath) {
    const entries = await fsp.readdir(dirPath, { withFileTypes: true });
    const results = [];

    for (const entry of entries) {
      const fullPath = require("path").join(dirPath, entry.name);
      if (entry.isDirectory()) {
        // 递归处理子目录
        results.push(...await readDirRecursive(fullPath));
      } else {
        results.push(fullPath);
      }
    }
    return results;
  }

  const allFiles = await readDirRecursive("./src");
  console.log(allFiles);
})();
