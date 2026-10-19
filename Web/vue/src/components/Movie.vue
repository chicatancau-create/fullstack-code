<template>
  <!-- 电影列表：先占位，等有电影了再换成真正的电影名 -->
  <RouterLink to="/movie/1">电影1</RouterLink>
  <RouterLink to="/movie/2">电影2</RouterLink>
  <RouterLink to="/movie/3">电影3</RouterLink>
  <!-- 电影子路由出口：访问 /movie/1、/movie/2 … 时 MovieDetails 渲染在这里 -->
  <RouterView />
</template>

<style scoped>
a {
  display: inline-block;
  padding: 3px 14px;
  margin: 0 5px;
  border: 1px solid #333;
  border-radius: 12px;
  background-color: #fff;
  color: #e91e63;
  font-size: 18px;
  text-decoration: none;
}
</style>
