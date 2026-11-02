<template>
  <header class="app-header">
    <div class="header-inner wrap">
      <!-- 左侧：校名胶囊 -->
      <span class="school-pill">
        <span class="school">湖南网络工程职业学院</span>
        <span class="college">信息工程学院</span>
      </span>

      <!-- 中间：三个业务页导航，当前页高亮成 accent 底白字胶囊 -->
      <nav class="nav" aria-label="主导航">
        <RouterLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="nav-link"
          :class="{ active: isActive(item.to) }"
          :aria-current="isActive(item.to) ? 'page' : undefined"
        >
          {{ item.label }}
        </RouterLink>
      </nav>

      <!-- 右侧：用户名 + 退出登录 -->
      <div class="user-area">
        <span class="welcome">欢迎，{{ displayName }}</span>
        <button class="btn btn-sm" type="button" @click="logout">退出登录</button>
      </div>
    </div>
  </header>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

// localStorage 键名与路由守卫、登录页保持一致
const AUTH_KEY = 'habit-token'
const USER_KEY = 'habit-user'

const route = useRoute()
const router = useRouter()

const navItems = [
  { to: '/', label: '打卡' },
  { to: '/stats', label: '统计' },
  { to: '/about', label: '关于' },
]

// 用户名用 ref 存：退出登录后要能立刻清空，不能是写死的常量
const userName = ref('')

// 没读到用户时给一个兜底称呼，避免出现「欢迎，」这种半截文案
const displayName = computed(() => userName.value || '同学')

// 当前路由判定：根路径要精确匹配，其余用前缀匹配以覆盖子路由
function isActive(to) {
  return to === '/' ? route.path === '/' : route.path.startsWith(to)
}

// 每次路径变化都重新读一遍，保证登录/退出后页头文案跟得上
function syncUserName() {
  userName.value = localStorage.getItem(USER_KEY) || ''
}

watch(() => route.path, syncUserName, { immediate: true })

function logout() {
  localStorage.removeItem(AUTH_KEY)
  localStorage.removeItem(USER_KEY)
  userName.value = ''
  router.push('/login')
}
</script>

<style scoped>
/* 白底卡片条：吸顶，滚动时导航常驻 */
.app-header {
  position: sticky;
  top: 0;
  z-index: 5;
  background: var(--card);
  border-bottom: 1px solid var(--line);
  box-shadow: var(--shadow-card);
}

.header-inner {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px 16px;
  padding-top: 10px;
  padding-bottom: 10px;
}

/* 中间导航占据剩余空间，把用户区推到最右 */
.nav {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.user-area {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px;
  margin-left: auto;
}

.nav-link {
  padding: 4px 14px;
  border-radius: var(--radius-pill);
  color: var(--brand);
  font-size: 13.5px;
  line-height: 1.7;
  text-decoration: none;
  transition: background-color 0.15s ease, color 0.15s ease;
}

.nav-link:hover {
  background: #eef2fa;
  text-decoration: none;
}

/* 当前路由：accent 底白字胶囊 */
.nav-link.active {
  background: var(--accent);
  color: #fff;
}

.welcome {
  color: var(--muted);
  font-size: 13px;
  white-space: nowrap;
}

/* 窄屏：导航换行，用户区不再靠右而是整行铺开，避免横向溢出 */
@media (max-width: 720px) {
  .header-inner {
    gap: 8px 10px;
    padding-top: 8px;
    padding-bottom: 8px;
  }

  .nav {
    order: 3;
    width: 100%;
  }

  .nav-link {
    flex: 1;
    padding: 4px 8px;
    text-align: center;
  }

  .user-area {
    gap: 8px;
  }

  .welcome {
    font-size: 12.5px;
    white-space: normal;
  }
}
</style>
