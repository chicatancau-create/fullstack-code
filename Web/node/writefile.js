const fs = require('fs');
fs.writeFile('./wofule.txt', 'Hello, World!', 'utf8', (err) => {
    if (err) {
        console.error(err.message);
    }else{
        console.log('File written successfully.');
    }
});