// 路由模块
//1.导入路由相关函数 createRouter, createWebHashHistory
import { createRouter, createWebHashHistory } from 'vue-router'
//2.导入路由控制的组件
import Login from '../components/Admin/Login.vue'
import Home from '../components/Admin/Home.vue'
import Users from '../components/Admin/Users.vue'
import UserDetail from '../components/Admin/UserDetail.vue'
import Placeholder from '../components/Admin/Placeholder.vue'
//3.创建路由实例
const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    // 路由重定向
    { path: '/', redirect: '/home/users' },
    { path: '/login', component: Login },
    {
      path: '/home',
      component: Home,
      children: [
        { path: 'users', component: Users },
        { path: 'users/:id', component: UserDetail },
        { path: 'rights', component: Placeholder, meta: { title: '权限管理' } },
        { path: 'goods', component: Placeholder, meta: { title: '商品管理' } },
        { path: 'orders', component: Placeholder, meta: { title: '订单管理' } },
        { path: 'sets', component: Placeholder, meta: { title: '系统设置' } },
      ],
    },
  ],
})

//全局前置守卫:没有登录标记时,除了登录页哪里都去不了
router.beforeEach((to) => {
  if (to.path !== '/login' && !localStorage.getItem('token')) return '/login'
})

//导出路由实例
export default router
