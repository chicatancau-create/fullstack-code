const fs = require('fs/promises');
// fs.writeFile('./wofule.txt', 'Hello, World!', 'utf8')
// .then(() => {
//     console.log('File written successfully');
// })
async function writeFile() {
    await fs.writeFile('./wofule.txt', 'Hello, World!', 'utf8');
    console.log('File written successfully');
}
writeFile();