<template>
  <div class="login-bg">
    <div class="card">
      <div class="badge">
        <VueLogo :size="86" />
      </div>
      <p class="row">
        <label>登录名称：</label>
        <input v-model="name" placeholder="请输入登录名称" />
      </p>
      <p class="row">
        <label>登录密码：</label>
        <input v-model="password" type="password" placeholder="请输入登录密码" />
      </p>
      <button class="submit" @click="login">登录</button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import VueLogo from './VueLogo.vue'

const router = useRouter()
const name = ref('')
const password = ref('')

const login = () => {
  if (name.value === 'admin' && password.value === '123456') {
    //存一个登录标记,路由守卫靠它放行
    localStorage.setItem('token', name.value)
    router.push('/home/users')
  } else {
    alert('登录名称或密码错误')
  }
}
</script>

<style scoped>
.login-bg {
  min-height: 100vh;
  padding-top: 170px;
  background: #333;
}
.card {
  position: relative;
  width: 500px;
  margin: 0 auto;
  padding: 70px 40px 50px;
  background: #fff;
}
/* 压在卡片上沿的那个白色圆徽章 */
.badge {
  position: absolute;
  top: -65px;
  left: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 130px;
  height: 130px;
  margin-left: -65px;
  border-radius: 50%;
  background: #fff;
}
.row {
  margin: 22px 0;
  text-align: right;
}
.row input {
  width: 240px;
  padding: 8px;
}
.submit {
  display: block;
  margin: 34px auto 0;
  padding: 10px 28px;
  border: none;
  border-radius: 6px;
  background: #888;
  color: #fff;
  cursor: pointer;
}
</style>
