// 路由模块 —— 学习习惯打卡与目标跟踪
//1.导入路由相关函数 createRouter, createWebHashHistory
import { createRouter, createWebHashHistory } from 'vue-router'

//2.登录标记的 localStorage 键名(登录页写入,守卫与页头读取)
const AUTH_KEY = 'habit-token'
const USER_KEY = 'habit-user'

//3.路由表:登录页独立,业务页挂在 HabitLayout 下并全部懒加载
const routes = [
  {
    path: '/login',
    name: 'habit-login',
    component: () => import('@/views/habit/HabitLogin.vue'),
    meta: { title: '登录' },
  },
  {
    path: '/',
    name: 'habit-shell',
    component: () => import('@/layouts/HabitLayout.vue'),
    children: [
      {
        path: '',
        name: 'habit-board',
        component: () => import('@/views/habit/HabitBoard.vue'),
        meta: { title: '今日打卡' },
      },
      {
        path: 'stats',
        name: 'habit-stats',
        component: () => import('@/views/habit/HabitStats.vue'),
        meta: { title: '数据统计' },
      },
      {
        path: 'about',
        name: 'habit-about',
        component: () => import('@/views/habit/HabitAbout.vue'),
        meta: { title: '关于本题' },
      },
    ],
  },
  //兜底:其余路径一律进 404 页
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/habit/NotFound.vue'),
    meta: { title: '页面不存在' },
  },
]

//4.创建路由实例
const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

//全局前置守卫:没有登录标记时,除了登录页哪里都去不了
router.beforeEach((to) => {
  const authed = Boolean(localStorage.getItem(AUTH_KEY))

  //未登录 -> 打回登录页,并把原目标路径带上,登录成功后可回跳
  if (!authed && to.path !== '/login') {
    return `/login?redirect=${encodeURIComponent(to.fullPath)}`
  }

  //已登录还去登录页 -> 直接进打卡主页
  if (authed && to.path === '/login') {
    return '/'
  }

  return true
})

//全局后置守卫:按路由 meta.title 同步浏览器标题
router.afterEach((to) => {
  document.title = to.meta.title ? `${to.meta.title} · 习惯打卡` : '习惯打卡'
})

//导出路由实例
export default router
export { AUTH_KEY, USER_KEY }
