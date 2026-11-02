const arr01 = [1, 2, 3, 4, 5];
let [a, b] =arr01;
console.log(a, b);
let user = {id: 1793534543453, name: 'zs', age: 18};
let {name} = user;
console.log(name);
function handleRequest({method, url, body = {}}) {
    console.log(method, url, body);
}
handleRequest({method: 'GET', url: '/api/user', body: {json:true}});