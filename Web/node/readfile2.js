const fs = require('fs/promises');
fs.readFile('./wofule.txt', 'utf8')
    .then(data => {
        console.log(data);
    })
    .catch(err => {
        console.log(err);
    })
    .finally(() => {
        console.log('读取文件操作完成');
    }); 