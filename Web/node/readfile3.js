const fs = require('fs/promises');
async function rf() {
    try {
        const data = await fs.readFile('./wofule.txt', 'utf8');
        console.log(data);
    } catch (err) {
        console.log(err);
    } finally {
        console.log('读取文件操作完成');
    }
}
rf();