<template>
  <div class="detail">
    <button class="back" @click="$router.back()">后退</button>
    <p>用户{{ $route.params.id }}的详情页面</p>
  </div>
</template>

<style scoped>
.detail {
  padding-top: 10px;
  text-align: center;
}
.back {
  padding: 8px 24px;
  border: none;
  border-radius: 6px;
  background: #888;
  color: #fff;
  cursor: pointer;
}
.detail p {
  margin-top: 26px;
}
</style>
