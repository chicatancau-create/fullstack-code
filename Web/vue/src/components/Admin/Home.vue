<template>
  <header class="top">
    <VueLogo :size="34" />
    <span class="title">商城后台管理系统</span>
    <a class="logout" @click="logout">退出</a>
  </header>
  <div class="body">
    <aside class="menu">
      <RouterLink to="/home/users">用户管理</RouterLink>
      <RouterLink to="/home/rights">权限管理</RouterLink>
      <RouterLink to="/home/goods">商品管理</RouterLink>
      <RouterLink to="/home/orders">订单管理</RouterLink>
      <RouterLink to="/home/sets">系统设置</RouterLink>
    </aside>
    <main class="content">
      <RouterView />
    </main>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import VueLogo from './VueLogo.vue'

const router = useRouter()
const logout = () => {
  localStorage.removeItem('token')
  router.push('/login')
}
</script>

<style scoped>
.top {
  display: flex;
  align-items: center;
  height: 60px;
  padding: 0 20px;
  background: #666;
  color: #fff;
}
.top .title {
  margin-left: 12px;
  font-size: 20px;
}
.logout {
  margin-left: auto;
  color: #fff;
  cursor: pointer;
}
.body {
  display: flex;
  min-height: calc(100vh - 60px);
}
.menu {
  width: 250px;
  background: #f2f2f2;
}
.menu a {
  display: block;
  padding: 22px 0;
  text-align: center;
  color: #333;
  text-decoration: none;
}
.menu a.router-link-active {
  background: #fff;
}
.content {
  flex: 1;
  padding: 20px;
}
</style>
