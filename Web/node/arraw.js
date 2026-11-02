// function add(a, b) {
//     return a + b;
// }
let add = (a, b) => a + b;
let add2 = a => a + 2;
console.log(add(2, 3)); 
console.log(add2(5)); 

const createUser = (name, age) => {
    const id = Date.now();
    return { id, name, age };
}
console.log(createUser('zs', 18));