const fs = require('fs');
fs.readFile('./wofule.txt', 'utf8', (err, data) => {
    if (err) {
        console.error('Error reading file:', err);
        return;
    }else{
        console.log('File contents:', data);
    }
})

try {
  const data = fs.readFileSync("./wofule.txt", "utf8");
  console.log("同步读取:", data);
} catch (e) {
  console.error("读取失败:", e.message);
}