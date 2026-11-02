<template>
  <div class="habit-app">
    <!-- 键盘用户的跳转入口：聚焦时才可见，样式在 habit.css 的 .skip-link -->
    <a class="skip-link" href="#main-content">跳到主要内容</a>
    <AppHeader />
    <main id="main-content" class="wrap page-body">
      <RouterView />
    </main>
  </div>
</template>

<script setup>
import AppHeader from '@/components/habit/AppHeader.vue'
</script>

<style scoped>
.habit-app {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* 内容区撑满剩余高度，内容少的页面也不会让页脚顶上来 */
.page-body {
  flex: 1;
  padding-top: 20px;
  padding-bottom: 40px;
}

@media (max-width: 720px) {
  .page-body {
    padding-top: 14px;
    padding-bottom: 28px;
  }
}
</style>
