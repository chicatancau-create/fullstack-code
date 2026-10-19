<template>
  <div>电影{{ id }}页面</div>
</template>

<script setup>
//动态路由参数通过 props 传进来（路由规则里写了 props: true）
const props = defineProps({
  id: String,
})
</script>
