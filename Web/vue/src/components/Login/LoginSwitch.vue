<template>
  <button @click="current = Login">登录</button>
  <button @click="current = Register">注册</button>
  <!-- 动态组件:current 指向哪个组件,这里就渲染哪个 -->
  <component :is="current" />
</template>

<script setup>
import { shallowRef } from 'vue'
import Login from './Login.vue'
import Register from './Register.vue'

//默认显示登录页面
const current = shallowRef(Login)
</script>
