<template>
  <h1>App根组件</h1>
  <nav>
    <router-link to="/home">首页</router-link>
    <router-link to="/about">关于</router-link>
  </nav>
  <div class="view">
    <router-view />
  </div>
</template>

<style scoped>
h1 {
  text-align: center;
}
nav {
  padding-bottom: 10px;
  border-bottom: 1px solid #ccc;
  text-align: center;
}
nav a {
  margin: 0 4px;
  padding: 4px 8px;
  color: #333;
  text-decoration: none;
}
/* 当前路由对应的链接会被自动加上 .router-link-active */
nav a.router-link-active {
  background: #333;
  color: #fff;
}
.view {
  min-height: 200px;
  padding: 40px 0;
  background: #eee;
  text-align: center;
}
</style>
