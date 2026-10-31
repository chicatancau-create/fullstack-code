// 路由模块
//1.导入路由相关函数 createRouter, createWebHashHistory
import { createRouter, createWebHashHistory } from 'vue-router'
//2.导入路由控制的组件
import Home from '../Home.vue'
import About from '../About.vue'
import Tab1 from '../Tab1.vue'
import Tab2 from '../Tab2.vue'
import Movie from '../Movie.vue'
import MovieDetails from '../MovieDetails.vue'
//3.创建路由实例
const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    // 路由重定向
    { path: '/', redirect: '/home' },
    { path: '/home', component: Home },
    {
      path: '/about',
      component: About,
      children: [
        { path: 'tab1', component: Tab1 },
        { path: 'tab2', component: Tab2 },
      ],
    },
    {
      path: '/movie',
      component: Movie,
      children: [
        // 动态路由：:id 匹配到的值会作为 props.id 传给 MovieDetails
        { path: ':id', component: MovieDetails, props: true },
      ],
    },
  ],
})
//导出路由实例
export default router
