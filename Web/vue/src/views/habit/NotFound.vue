<template>
  <div class="notfound-page wrap">
    <section class="card notfound-card">
      <p class="code">404</p>
      <h1 class="section-title">页面不存在</h1>
      <p class="desc">
        没有找到路径 <code>{{ attemptedPath }}</code> 对应的页面，可能是地址写错了，
        或者这一页还没有挂进路由表。
      </p>
      <p class="muted">
        本题只有三个业务页：今日打卡、数据统计、关于本题。其余地址一律落到这里。
      </p>
      <div class="actions">
        <RouterLink class="btn btn-primary" to="/">返回打卡页</RouterLink>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

// 展示用户真正尝试访问的路径，方便排查拼写错误；回跳带的是 query，这里只显示 pathname
const attemptedPath = computed(() => route.path || '/')
</script>

<style scoped>
.notfound-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 70vh;
  padding-top: 24px;
  padding-bottom: 40px;
}

.notfound-card {
  width: 100%;
  max-width: 520px;
  text-align: center;
}

.code {
  color: var(--accent);
  font-size: 52px;
  font-weight: 700;
  line-height: 1.2;
  letter-spacing: 2px;
}

.section-title {
  /* 继承全局 ▍ 前缀样式，这里只改居中与间距 */
  text-align: center;
  font-size: 15px;
  margin-bottom: 10px;
}

.desc {
  margin-bottom: 6px;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 10px;
  margin-top: 18px;
}

/* .btn 是 inline-flex，链接形式去掉下划线 */
.actions a {
  text-decoration: none;
}
</style>
