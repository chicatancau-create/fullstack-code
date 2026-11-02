<template>
  <div class="login-shell">
    <section class="card login-card">
      <span class="login-mark">习惯</span>
      <h1 class="login-title">登录 习惯打卡</h1>
      <p class="muted login-sub">演示环境：任意用户名和密码均可登录</p>

      <form class="login-form" novalidate @submit.prevent="submit">
        <div class="field">
          <label for="habit-username">用户名</label>
          <input
            id="habit-username"
            v-model="form.username"
            name="habit-username"
            type="text"
            autocomplete="username"
            placeholder="请输入你的名字"
            :class="{ 'is-invalid': errors.username }"
            :aria-invalid="errors.username ? 'true' : 'false'"
            :aria-describedby="errors.username ? 'habit-username-error' : undefined"
          />
          <p v-if="errors.username" id="habit-username-error" class="field-error" role="alert">
            {{ errors.username }}
          </p>
        </div>

        <div class="field">
          <label for="habit-password">密码</label>
          <div class="pwd-row">
            <input
              id="habit-password"
              v-model="form.password"
              name="habit-password"
              :type="showPassword ? 'text' : 'password'"
              autocomplete="current-password"
              placeholder="演示环境不校验密码内容"
              :class="{ 'is-invalid': errors.password }"
              :aria-invalid="errors.password ? 'true' : 'false'"
              :aria-describedby="errors.password ? 'habit-password-error' : undefined"
            />
            <button class="btn btn-sm pwd-toggle" type="button" @click="showPassword = !showPassword">
              {{ showPassword ? '隐藏' : '显示' }}
            </button>
          </div>
          <p v-if="errors.password" id="habit-password-error" class="field-error" role="alert">
            {{ errors.password }}
          </p>
        </div>

        <button class="btn btn-primary login-btn" :class="{ 'is-ready': canSubmit }" type="submit">
          登录
        </button>

        <p class="muted login-hint">
          <span v-if="canSubmit">回车即可登录，数据只存在这台浏览器里。</span>
          <span v-else>用户名和密码都填好才能登录。</span>
        </p>

        <p v-if="externalBlocked" class="pill pill-amber login-note" role="alert">
          跳转参数不是站内路径，已忽略并在登录后回到首页。
        </p>
        <p v-if="storageTip" class="pill pill-red login-note" role="alert">{{ storageTip }}</p>
      </form>
    </section>
  </div>
</template>

<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

// 与页头、路由守卫一致的登录态键；本页只写这两个键，业务数据仍由 useHabits 负责
const AUTH_KEY = 'habit-token'
const USER_KEY = 'habit-user'
const LOGIN_PATH = '/login'
const FALLBACK_PATH = '/'

const route = useRoute()
const router = useRouter()

const form = reactive({ username: '', password: '' })
const errors = reactive({ username: '', password: '' })
// 「显示密码」是纯 UI 开关，ref 足够
const showPassword = ref(false)
const storageTip = ref('')

const canSubmit = computed(
  () => Boolean(form.username.trim()) && Boolean(form.password.trim()),
)

/**
 * 只接受站内绝对路径：必须以单个 '/' 开头。
 * '//' 是协议相对地址（会被解析成 http://外站），'\/'、含协议的字符串同样拒绝，防开放重定向。
 */
function resolveRedirect() {
  const raw = typeof route.query.redirect === 'string' ? route.query.redirect.trim() : ''
  if (!raw) return ''
  if (!raw.startsWith('/') || raw.startsWith('//') || raw.includes('\\') || raw.includes(':')) return ''
  // 指回登录页会造成「登录→又被踢回登录」的死循环，按默认首页处理
  if (raw === LOGIN_PATH || raw.startsWith(`${LOGIN_PATH}?`)) return ''
  return raw
}

const redirectTarget = computed(() => resolveRedirect())

const externalBlocked = computed(() => {
  const raw = typeof route.query.redirect === 'string' ? route.query.redirect.trim() : ''
  return Boolean(raw) && !redirectTarget.value
})

// 用户开始补货就撤掉该字段的报错，避免红色提示一直挂着
watch(
  () => form.username,
  (value) => {
    if (value.trim()) errors.username = ''
  },
)

watch(
  () => form.password,
  (value) => {
    if (value.trim()) errors.password = ''
  },
)

function validate() {
  errors.username = form.username.trim() ? '' : '请填写用户名'
  errors.password = form.password.trim() ? '' : '请填写密码'
  return canSubmit.value
}

function submit() {
  storageTip.value = ''
  if (!validate()) return

  const username = form.username.trim()
  try {
    localStorage.setItem(AUTH_KEY, username)
    localStorage.setItem(USER_KEY, username)
  } catch {
    storageTip.value = '浏览器存储不可用，登录状态无法保存，刷新后需要重新登录。'
  }

  router.push(redirectTarget.value || FALLBACK_PATH)
}
</script>

<style scoped>
/* 居中卡片 */
.login-shell {
  display: grid;
  place-items: center;
  min-height: 100vh;
  padding: 24px 16px;
  background: var(--bg);
}

.login-card {
  width: 100%;
  max-width: 380px;
  padding: 24px 26px 22px;
}

.login-mark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  margin-bottom: 10px;
  border-radius: 12px;
  background: var(--brand);
  color: #fff;
  font-size: 15px;
  font-weight: 700;
}

.login-title {
  color: var(--brand);
  font-size: 19px;
  font-weight: 700;
  line-height: 1.5;
}

.login-sub {
  margin-top: 2px;
  margin-bottom: 18px;
  font-size: 12.5px;
}

.pwd-row {
  display: flex;
  gap: 8px;
  align-items: center;
}

.pwd-toggle {
  flex: none;
}

.field-error {
  margin-top: 2px;
  color: var(--danger);
  font-size: 12px;
  line-height: 1.6;
}

.is-invalid {
  border-color: var(--danger);
}

.login-btn {
  width: 100%;
  margin-top: 4px;
}

.login-btn.is-ready {
  box-shadow: 0 3px 10px rgba(59, 111, 212, 0.24);
}

.login-hint {
  margin-top: 10px;
  font-size: 12px;
  text-align: center;
}

.login-note {
  display: block;
  margin-top: 10px;
  padding: 5px 10px;
  font-size: 12px;
  line-height: 1.7;
  white-space: normal;
}

@media (max-width: 720px) {
  .login-shell {
    min-height: 100vh;
    padding: 16px 12px;
  }

  .login-card {
    padding: 20px 18px 18px;
  }
}
</style>
