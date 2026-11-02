<template>
  <div class="about-page">
    <section class="card">
      <h2 class="section-title">这是什么</h2>
      <p>
        「学习习惯打卡与目标跟踪」是实训案例第 5 题：学生为每个学习习惯设一个每周目标天数
        （1–7 天），每天回到页面点一下格子完成打卡，系统据此算出本周完成率、连续打卡天数和按月铺开的热力日历。
        数据全部保存在这台浏览器的 localStorage 里，不上传服务器，刷新与关闭后依然存在。
      </p>
      <p class="live-line muted">
        当前本机已记录
        <span class="pill pill-green">{{ state.habits.length }} 个习惯</span>
        <span class="pill">{{ checkinTotal }} 次打卡</span>
        <span class="muted live-time">数据最近变化于 {{ lastSyncedAt }}</span>
      </p>
    </section>

    <section class="card">
      <h2 class="section-title">技术栈</h2>
      <ul class="pill-row">
        <li v-for="item in techStack" :key="item.name" class="pill" :class="item.cls">
          {{ item.name }}
        </li>
      </ul>
      <p class="muted">
        没有引入任何 UI 组件库、图表库或请求库：热力日历、柱状条、进度条全部用 CSS 网格与
        <code>:style</code> 高度换算实现，样式变量集中在 <code>src/styles/habit.css</code> 的
        <code>:root</code> token，组件内只用 <code>var(--xxx)</code> 消费。
      </p>
    </section>

    <section class="card">
      <h2 class="section-title">数据模型</h2>
      <p class="muted">
        两个集合就够了：习惯本身是数组，打卡记录是「习惯 id → 日期键数组」的字典。
        日期键统一为 <code>YYYY-MM-DD</code>，字典序即时间序，比较大小不需要造 Date 对象。
      </p>

      <div class="model-head">
        <button class="btn btn-sm" type="button" @click="modelOpen.habit = !modelOpen.habit">
          {{ modelOpen.habit ? '收起 Habit 结构' : '展开 Habit 结构' }}
        </button>
        <button class="btn btn-sm" type="button" @click="modelOpen.checkins = !modelOpen.checkins">
          {{ modelOpen.checkins ? '收起 checkins 结构' : '展开 checkins 结构' }}
        </button>
      </div>

      <pre v-if="modelOpen.habit">Habit {
  id: string,             // 新增时用 crypto.randomUUID()，兜底 habit-时间戳
  name: string,           // 必填，去首尾空格，最长 20 字，重名会被拒绝
  target: number,         // 每周目标天数，1–7 的整数
  color: string,          // 固定五色调色板之一
  createdAt: 'YYYY-MM-DD' // 建卡当天
}</pre>

      <pre v-if="modelOpen.checkins">checkins: {
  "habit-reading": ["2026-10-26", "2026-10-27"],   // 升序、去重的日期键数组
  "habit-english": []                                // 没打过卡就是空数组，不写 null
}

// 调色板（顺序固定，不在列表里的颜色会被兜底成第一个）
#2f6b52  #d97745  #6874b8  #b58a32  #b65c68</pre>
    </section>

    <section class="card">
      <h2 class="section-title">关键算法</h2>
      <ol class="algo-list">
        <li v-for="algo in algorithms" :key="algo.title" class="algo">
          <h3 class="algo-title">{{ algo.title }}</h3>
          <p>{{ algo.text }}</p>
          <pre>{{ algo.code }}</pre>
        </li>
      </ol>
    </section>

    <section class="card">
      <h2 class="section-title">组件拆分树</h2>
      <pre>{{ componentTree }}</pre>
      <p class="muted">
        拆分原则：容器组件（HabitList / HabitBoard）只管列表和状态，行组件（HabitRow）只吃 props、
        只发事件；MonthHeatmap 是纯展示组件，月份边界这类业务判断留在统计页。
      </p>
    </section>

    <section class="card">
      <h2 class="section-title">存储键与重置方式</h2>
      <table class="store-table">
        <caption>三个 localStorage 键，写入分别由 useHabits 的深度 watch 和登录页负责。</caption>
        <thead>
          <tr>
            <th scope="col">键名</th>
            <th scope="col">内容</th>
            <th scope="col">由谁写</th>
            <th scope="col">怎么清</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in storageRows" :key="row.key">
            <td><code>{{ row.key }}</code></td>
            <td>{{ row.value }}</td>
            <td>{{ row.writer }}</td>
            <td>{{ row.reset }}</td>
          </tr>
        </tbody>
      </table>
      <p class="muted">
        页面上的正规重置入口在打卡页：「恢复示例数据」调用 <code>resetData()</code> 写入一套演示记录，
        「清空全部数据」调用 <code>clearData()</code> 把两个集合清空；两者都会顺着 watch 落盘，刷新后保持。
        手工兜底可在浏览器 DevTools 的 Application → Local Storage 删键，或控制台执行
        <code>localStorage.removeItem('xiji-habit-tracker-v1')</code> 后刷新页面。
      </p>
    </section>

    <section class="card note-card">
      <h2 class="section-title">实现说明（{{ noteCount }} 字）</h2>
      <p class="note-text">{{ implNote }}</p>
    </section>
  </div>
</template>

<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { STORAGE_KEY, useHabits } from '@/composables/useHabits'

const { state } = useHabits()

const techStack = [
  { name: 'Vue 3.5 + script setup 语法', cls: '' },
  { name: 'Vite 8', cls: '' },
  { name: 'vue-router 5.4（路由懒加载）', cls: '' },
  { name: '组合式 API：ref / reactive / computed / watch', cls: 'pill-green' },
  { name: 'CSS 变量 token + scoped style', cls: 'pill-green' },
  { name: 'localStorage 持久化', cls: 'pill-amber' },
  { name: '零第三方 UI / 图表库', cls: 'pill-amber' },
]

const algorithms = [
  {
    title: '周视图首日换算（周一为一周之首）',
    text:
      'JS 的 getDay() 把周日算作 0，直接当偏移会让热力条错位。统一先归一到周一正午（避开夏令时与跨日边界），' +
      '月历首行偏移用 (getDay() + 6) % 7 求得：周一为 0、周日为 6。格子总数向上取整到 7 的倍数，' +
      '跨月的空位保留 null 并照常渲染占位，这样 7 列网格永远对齐表头。',
    code: `const monday = startOfWeek(date)            // getDay() === 0 ? -6 : 1 - day
const leading = (first.getDay() + 6) % 7     // 周一开头的前导空位
const cellCount = Math.ceil((leading + daysInMonth) / 7) * 7`,
  },
  {
    title: '连续天数倒推（当前连续 / 最长连续）',
    text:
      '当前连续用倒推：以今天为指针，今天没打卡就先退回昨天（否则当天未打卡就一律为 0），' +
      '随后只要指针落在打卡集合里就继续往前退并累加。最长连续换成对升序去重数组的顺推，' +
      '相邻两个日期键相差一天就延长窗口，否则重置为 1，全程取最大值。',
    code: `// 当前连续：从今天（或昨天）沿 Set 往回走
if (!set.has(today)) cursor = addDays(cursor, -1)
while (set.has(key(cursor))) { streak += 1; cursor = addDays(cursor, -1) }

// 最长连续：升序去重后看相邻是否恰好差一天
current = dates[i] === nextOf(dates[i - 1]) ? current + 1 : 1`,
  },
  {
    title: '热力值聚合（一格一天，一天多习惯）',
    text:
      '遍历月历里的每一个日期键，问一遍「今天有几个习惯打了卡」：把每个习惯的打卡数组先转成 Set，' +
      '再做包含判断，避免对每天 × 每习惯的两层数组做 indexOf。计数结果同时驱动两样东西——' +
      '色阶分档（0 / 1 / 2 / 3+，单日上限更高时按 max 归一压回四档）和浮层里的习惯名清单。',
    code: `const membership = habits.map(h => ({ name: h.name, set: new Set(checkins[h.id]) }))
cells.forEach(key => {
  const hits = membership.filter(m => key && m.set.has(key))
  counts[key] = hits.length
  detail[key] = hits.map(({ name, color }) => ({ name, color }))
})`,
  },
]

const componentTree = `HabitLayout  布局（页头 + .wrap 内容区 + RouterView）
├─ AppHeader        导航高亮 / 用户名 / 退出登录（读 habit-user）
├─ HabitBoard       打卡页：列表 + 表单 + 重置入口
│  ├─ HabitForm     新增与编辑习惯（v-model、名称与目标校验、调色板单选）
│  ├─ HabitList     列表容器，负责 v-for 与 key，空态提示
│  └─ HabitRow      单行：周视图 7 格开关、完成计数、编辑 / 删除事件
├─ HabitStats       统计页：数字卡 + 热力条 + 近 8 周柱状 + 明细表
│  └─ MonthHeatmap  月热力条（props 下发 / change-month 上报，纯展示）
└─ HabitAbout       关于页（本文件）

数据入口只有一个：useHabits() → reactive({ habits, checkins, storageError })`

const storageRows = computed(() => [
  {
    key: STORAGE_KEY,
    value: '{ habits, checkins } 业务数据',
    writer: 'useHabits 内的深度 watch，自动写入',
    reset: '打卡页「清空全部数据」/「恢复示例数据」',
  },
  {
    key: 'habit-token',
    value: '登录标记（存在即放行路由守卫）',
    writer: '登录页 submit 成功后写入',
    reset: '页头「退出登录」移除',
  },
  {
    key: 'habit-user',
    value: '用户名，供页头欢迎语',
    writer: '登录页 submit 成功后写入',
    reset: '页头「退出登录」移除',
  },
])

const implNote =
  '全页用 script setup 写成。useHabits 以 reactive 维护 habits 与 checkins，深度 watch 自动落盘，组件层不再碰存储。' +
  '统计派生集中在 stats.js 纯函数；比率先判分母为零再算，返回 0–1 小数，不会出现 NaN。' +
  '连续天数用倒推：今天未打卡先退一天再逐日累加；最长连续看升序去重后相邻是否差一天。' +
  '周视图首日为周一，前导空位据此折算并渲染占位，保证 7 列对齐。' +
  'MonthHeatmap 只收 props、只 emit 换月，未来月禁用由统计页判定；明细浮层靠 CSS 与 tabindex，不监听不碰 DOM。' +
  '登录页只写 token 与用户名，redirect 限单斜杠开头的站内路径。'

const modelOpen = reactive({
  habit: true,
  checkins: false,
})

const checkinTotal = computed(() =>
  state.habits.reduce(
    (sum, habit) => sum + (Array.isArray(state.checkins[habit.id]) ? state.checkins[habit.id].length : 0),
    0,
  ),
)

const noteCount = computed(() => implNote.replace(/\s/g, '').length)

function nowText() {
  return new Date().toLocaleTimeString('zh-CN', { hour12: false })
}

const lastSyncedAt = ref(nowText())

// 这一页是「活」的：习惯数或打卡数一变（在打卡页点了开关再切回来），就刷新最后变化时间
watch([() => state.habits.length, checkinTotal], () => {
  lastSyncedAt.value = nowText()
})
</script>

<style scoped>
.about-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* 全局 .card + .card 的 16px 与 flex gap 会叠加，统一交给 gap */
.about-page > .card + .card {
  margin-top: 0;
}

.about-page pre {
  margin-top: 10px;
}

.live-line {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  margin-top: 10px;
}

.live-time {
  font-size: 12px;
}

.pill-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 10px;
}

.pill-row .pill {
  padding: 2px 10px;
  font-size: 12px;
  line-height: 1.8;
}

.model-head {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.algo-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
  counter-reset: algo;
}

.algo {
  padding-left: 0;
}

.algo-title {
  color: var(--brand);
  font-size: 13.5px;
  font-weight: 700;
  line-height: 1.6;
}

.algo pre {
  font-size: 12.5px;
}

.store-table {
  margin-bottom: 10px;
}

.note-card .note-text {
  text-indent: 2ch;
  line-height: 1.9;
}

@media (max-width: 720px) {
  .about-page pre {
    font-size: 12px;
  }
}
</style>
