const fs = require('fs/promises');

async function appendFile() {
    await fs.appendFile('./wofule.txt', `${new Date().toLocaleString()}\n`, 'utf8');
    console.log('File appended successfully');
}

appendFile();
