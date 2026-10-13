<template>
  <div class="about-container">
    <h3>About组件</h3>
    <RouterLink to="/about/tab1">tab1</RouterLink>
    <RouterLink to="/about/tab2">tab2</RouterLink>
    <hr />
    <RouterView></RouterView>
  </div>
</template>

<style scoped>
.about-container {
  min-height: 150px;
  width: 300px;
  background-color: #f2f2f2;
  padding: 15px;
  margin: 0 auto;
  /* 外面 .view 是居中的,这里按投影改回靠左 */
  text-align: left;
}
.about-container a {
  border: 1px solid #ccc;
  border-radius: 5px;
  padding: 5px 10px;
  color: #000;
  margin: 0 5px;
  text-decoration: none;
}
.about-container a.router-link-active {
  color: #000;
  background-color: #fff;
}
</style>
