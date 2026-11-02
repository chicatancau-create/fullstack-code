<template>
  <div class="stats-page">
    <p v-if="state.storageError" class="pill pill-red banner" role="alert">
      {{ state.storageError }}
    </p>

    <!-- 顶部四张数字卡 -->
    <section class="stat-grid" aria-label="总体概览">
      <article v-for="card in statCards" :key="card.key" class="card stat-card">
        <p class="stat-label">{{ card.label }}</p>
        <p class="stat-value" :class="card.cls">
          {{ card.value }}<span class="stat-unit">{{ card.unit }}</span>
        </p>
        <p class="muted stat-note">{{ card.note }}</p>
      </article>
    </section>

    <p class="muted streak-line">
      整体连续打卡 {{ summary.currentStreak }} 天 · 历史最长 {{ summary.bestStreak }} 天
      <span class="muted streak-hint">（当天任意一个习惯打卡即算一天）</span>
    </p>

    <!-- 月热力条：父页持有 monthDate，月份边界在这里判定后下发 -->
    <MonthHeatmap
      :month-key="heatmap.monthKey"
      :cells="heatmap.cells"
      :counts="heatmap.counts"
      :detail="heatmap.detail"
      :max="heatmap.max"
      :today-key="todayKey"
      :next-disabled="nextDisabled"
      @change-month="changeMonth"
    />
    <p v-if="!nextDisabled" class="back-line">
      <button class="btn btn-sm" type="button" @click="backToCurrentMonth">回到本月</button>
    </p>

    <!-- 近 8 周完成率：纯 CSS 柱状，不引图表库 -->
    <section v-if="summary.habitCount" class="card">
      <h3 class="section-title">近 8 周完成率</h3>
      <div class="bars" role="img" :aria-label="barsAriaLabel">
        <div
          v-for="(week, index) in weeks"
          :key="week.weekKey"
          class="bar-col"
          :class="{ 'is-current': index === weeks.length - 1 }"
        >
          <p class="bar-pct">{{ percent(week.rate) }}</p>
          <div class="bar-track">
            <div class="bar-fill" :style="{ height: barHeight(week.rate) }"></div>
          </div>
          <p class="bar-label">{{ week.label }}</p>
          <p class="muted bar-done">{{ week.done }} 次</p>
        </div>
      </div>
      <p class="muted bars-note">
        满打卡 = 各习惯每周目标合计 {{ weeklyTarget }} 次；最后一柱是进行中的本周，偏低属正常。
      </p>
    </section>

    <!-- 明细表 -->
    <section v-if="summary.habitCount" class="card">
      <header class="table-head">
        <h3 class="section-title">习惯明细</h3>
        <div class="filters">
          <input
            v-model="table.keyword"
            class="filter-input"
            type="search"
            placeholder="按名称筛选"
            aria-label="按习惯名称筛选"
          />
          <label class="filter-check">
            <input v-model="table.onlyActive" type="checkbox" />
            只看本周已打卡
          </label>
        </div>
      </header>

      <!-- 表格内容确实需要横向滚动：外层套一个 overflow-x:auto 的滚动容器，
           页面本身不再被撑破，列也一列不少地能在容器里滑到 -->
      <div class="table-scroll">
        <table class="stats-table">
          <caption>点击表头可排序；点「展开」查看该习惯在当前月份的打卡日期。</caption>
          <thead>
            <tr>
              <th v-for="col in columns" :key="col.key" scope="col" :class="{ 'is-sorted': table.sortKey === col.key }">
                <button class="th-btn" type="button" @click="sortBy(col.key)">
                  {{ col.label }}
                  <span class="th-arrow" :aria-hidden="true">{{ arrowOf(col.key) }}</span>
                </button>
              </th>
              <th scope="col">本月明细</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="!visibleRows.length">
              <td class="empty-cell" :colspan="columns.length + 1">
                没有符合条件的习惯，换个关键词或取消「只看本周已打卡」。
              </td>
            </tr>
            <tr v-for="row in visibleRows" :key="row.id">
              <td>
                <span class="dot" :style="{ backgroundColor: row.color }"></span>
                <span class="row-name">{{ row.name }}</span>
                <div v-if="expandedId === row.id" class="month-detail">
                  <p class="muted">{{ heatmap.label }} · 已打卡 {{ monthDetail(row.id).length }} 天</p>
                  <ul v-if="monthDetail(row.id).length" class="chips">
                    <li
                      v-for="key in monthDetail(row.id)"
                      :key="key"
                      class="chip"
                      :class="{ 'chip-today': key === todayKey }"
                    >
                      {{ shortDate(key) }}
                    </li>
                  </ul>
                  <p v-else class="muted">这个习惯本月还没有打卡记录。</p>
                </div>
              </td>
              <td>{{ row.target }} 天/周</td>
              <td class="cell-week">
                <span class="mini">
                  <span class="mini-fill" :style="{ width: `${Math.round(row.weekRate * 100)}%` }"></span>
                </span>
                <span class="mini-text">{{ row.weekDone }}/{{ row.target }}</span>
              </td>
              <td><span class="pill" :class="ratePill(row.weekRate)">{{ percent(row.weekRate) }}</span></td>
              <td>{{ row.currentStreak }} 天</td>
              <td>{{ row.longestStreak }} 天</td>
              <td>
                <button class="btn btn-sm" type="button" @click="toggleExpand(row.id)">
                  {{ expandedId === row.id ? '收起' : '展开' }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- 空态：没有习惯时不渲染任何依赖除数的图表，直接给引导 -->
    <section v-if="!summary.habitCount" class="card empty-state">
      <h3 class="section-title">还没有可统计的习惯</h3>
      <p class="muted">
        先去打卡页建一个学习习惯（名称不超过 20 字、每周目标 1–7 天），并记录今天的完成情况，
        回到这里就会出现热力月历、近 8 周完成率和明细表。
      </p>
      <RouterLink class="btn btn-primary" to="/">去打卡页登记习惯</RouterLink>
    </section>
  </div>
</template>

<script setup>
import { computed, reactive, ref, watch } from 'vue'
import MonthHeatmap from '@/components/habit/MonthHeatmap.vue'
import { useHabits } from '@/composables/useHabits'
import { buildMonthHeatmap, overallSummary, recentWeeks } from '@/utils/stats'
import {
  addMonths,
  formatShortDate,
  fromDateKey,
  isValidDateKey,
  startOfMonth,
  toDateKey,
} from '@/utils/date'

const { state } = useHabits()

const RECENT_WEEK_COUNT = 8

// 今天在整个页面里是常量，月份才是可变状态
const todayKey = toDateKey()
const monthDate = ref(startOfMonth(new Date()))
const expandedId = ref('')

const heatmap = computed(() =>
  buildMonthHeatmap(state.habits, state.checkins, monthDate.value),
)

const nextDisabled = computed(() => heatmap.value.monthKey >= todayKey.slice(0, 7))

const summary = computed(() => overallSummary(state.habits, state.checkins, todayKey))

const weeks = computed(() =>
  recentWeeks(state.habits, state.checkins, fromDateKey(todayKey), RECENT_WEEK_COUNT),
)

const maxRate = computed(() =>
  weeks.value.reduce((max, week) => (week.rate > max ? week.rate : max), 0),
)

const weeklyTarget = computed(() =>
  summary.value.perHabit.reduce((sum, habit) => sum + habit.target, 0),
)

const statCards = computed(() => [
  {
    key: 'habitCount',
    label: '习惯总数',
    value: summary.value.habitCount,
    unit: ' 个',
    note: summary.value.habitCount ? '已登记的学习习惯' : '还没有登记习惯',
    cls: '',
  },
  {
    key: 'totalCheckins',
    label: '累计打卡次数',
    value: summary.value.totalCheckins,
    unit: ' 次',
    note: '所有习惯的历史打卡合计',
    cls: '',
  },
  {
    key: 'thisWeekDone',
    label: '本周打卡',
    value: summary.value.thisWeekDone,
    unit: ` / ${weeklyTarget.value} 次`,
    note: '本周（周一起）已完成次数',
    cls: 'is-brand',
  },
  {
    key: 'avgRate',
    label: '平均完成率',
    value: percent(summary.value.avgRate),
    unit: '',
    note: summary.value.habitCount ? '各习惯本周完成率的平均' : '无习惯时按 0% 兜底',
    cls: summary.value.avgRate >= 0.8 ? 'is-good' : '',
  },
])

const barsAriaLabel = computed(
  () => `近 ${RECENT_WEEK_COUNT} 周完成率，最高 ${percent(maxRate.value)}`,
)

const columns = [
  { key: 'name', label: '名称' },
  { key: 'target', label: '目标' },
  { key: 'weekDone', label: '本周' },
  { key: 'weekRate', label: '完成率' },
  { key: 'currentStreak', label: '当前连续' },
  { key: 'longestStreak', label: '最长连续' },
]

// 表格的筛选 + 排序状态：一处 reactive 收住，避免散落四五个 ref
const table = reactive({
  keyword: '',
  onlyActive: false,
  sortKey: 'weekRate',
  sortAsc: false,
})

const visibleRows = computed(() => {
  const keyword = table.keyword.trim().toLowerCase()
  const filtered = summary.value.perHabit.filter((row) => {
    const matchedName = !keyword || row.name.toLowerCase().includes(keyword)
    const matchedActive = !table.onlyActive || row.weekDone > 0
    return matchedName && matchedActive
  })

  const key = table.sortKey
  const direction = table.sortAsc ? 1 : -1
  return [...filtered].sort((left, right) => {
    const a = left[key]
    const b = right[key]
    if (typeof a === 'string' || typeof b === 'string') {
      return String(a).localeCompare(String(b), 'zh-CN') * direction
    }
    return ((Number(a) || 0) - (Number(b) || 0)) * direction
  })
})

// 切月之后展开行里显示的还是上一个月的日期，继续留着会误导，直接收起
watch(monthDate, () => {
  expandedId.value = ''
})

// 展开中的习惯被删掉、或被筛选条件排除时收起，避免 expandedId 悬空
watch(visibleRows, (rows) => {
  if (expandedId.value && !rows.some((row) => row.id === expandedId.value)) {
    expandedId.value = ''
  }
})

const monthKeySet = computed(() => new Set(heatmap.value.cells.filter(Boolean)))

function changeMonth(step) {
  const delta = Number(step)
  if (!Number.isFinite(delta) || delta === 0) return
  // 子组件已把「下一月」置灰，这里再挡一次，防止别处直接调用
  if (delta > 0 && nextDisabled.value) return
  monthDate.value = addMonths(monthDate.value, delta)
}

function backToCurrentMonth() {
  monthDate.value = startOfMonth(new Date())
}

function sortBy(key) {
  if (table.sortKey === key) {
    table.sortAsc = !table.sortAsc
    return
  }
  table.sortKey = key
  // 文本列首次点击升序更直观，数值列首次点击看高分
  table.sortAsc = key === 'name'
}

function arrowOf(key) {
  if (table.sortKey !== key) return ''
  return table.sortAsc ? '▲' : '▼'
}

function toggleExpand(id) {
  expandedId.value = expandedId.value === id ? '' : id
}

function monthDetail(id) {
  const dates = Array.isArray(state.checkins[id]) ? state.checkins[id] : []
  return dates.filter((key) => monthKeySet.value.has(key))
}

function shortDate(key) {
  return isValidDateKey(key) ? formatShortDate(key) : key
}

function percent(rate) {
  const num = Number(rate)
  if (!Number.isFinite(num) || num <= 0) return '0%'
  return `${Math.round(Math.min(num, 1) * 100)}%`
}

function barHeight(rate) {
  // 柱高按完成率绝对值算，和柱顶百分比读数一致；空数据给 3% 让轨道可见
  const num = Number(rate)
  if (!Number.isFinite(num) || num <= 0) return '3%'
  return `${Math.max(3, Math.min(100, Math.round(num * 100)))}%`
}

function ratePill(rate) {
  const num = Number(rate)
  if (!Number.isFinite(num)) return 'pill-amber'
  if (num >= 1) return 'pill-green'
  if (num >= 0.5) return ''
  if (num > 0) return 'pill-amber'
  return 'pill-red'
}
</script>

<style scoped>
.stats-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.banner {
  padding: 6px 12px;
  font-size: 12.5px;
  line-height: 1.6;
}

/* ---------- 数字卡 ---------- */
.stat-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
}

.stat-card {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

/* 全局 .card + .card 的 16px 上边距与本页 flex gap 会叠加（网格内还会把第 2–4 张卡压低），
   统一清掉，间距只由 .stats-page / .stat-grid 的 gap 负责 */
.stats-page > .card + .card,
.stat-grid .card + .card {
  margin-top: 0;
}

.stat-label {
  color: var(--muted);
  font-size: 12.5px;
}

.stat-value {
  color: var(--brand);
  font-size: 26px;
  font-weight: 700;
  line-height: 1.3;
  font-variant-numeric: tabular-nums;
}

.stat-value.is-brand {
  color: var(--accent);
}

.stat-value.is-good {
  color: var(--accent2);
}

.stat-unit {
  font-size: 13px;
  font-weight: 400;
  color: var(--muted);
}

.stat-note {
  font-size: 12px;
}

.streak-line {
  margin-top: -4px;
}

.streak-hint {
  font-size: 12px;
}

.back-line {
  margin-top: -8px;
  text-align: right;
}

/* ---------- 柱状条 ---------- */
.bars {
  display: flex;
  align-items: flex-end;
  gap: 10px;
  margin-top: 6px;
}

.bar-col {
  display: flex;
  flex: 1;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  min-width: 0;
}

.bar-track {
  display: flex;
  align-items: flex-end;
  width: 100%;
  height: 132px;
  border-radius: 6px;
  background: #eef1f7;
  overflow: hidden;
}

.bar-fill {
  width: 100%;
  border-radius: 6px 6px 0 0;
  background: linear-gradient(180deg, #7ea6ec, var(--accent));
}

.bar-col.is-current .bar-fill {
  background: linear-gradient(180deg, #46b58a, var(--accent2));
}

.bar-pct {
  color: var(--brand);
  font-size: 11.5px;
  font-variant-numeric: tabular-nums;
}

.bar-label {
  color: var(--text);
  font-size: 12px;
  white-space: nowrap;
}

.bar-done {
  font-size: 11.5px;
}

.bars-note {
  margin-top: 10px;
  font-size: 12px;
}

/* ---------- 明细表 ---------- */
.table-head {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 8px 12px;
}

.filters {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px;
}

.filter-input {
  width: 168px;
}

.filter-check {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  color: var(--muted);
  font-size: 12.5px;
  white-space: nowrap;
}

/* 明细表：外层滚动容器负责横向滚动（内容放不下时页面本身不被撑破），
   表格只给一个「不低于自身内容最小宽度」的地板，保证列不被压瘪、一列都不藏。 */
.table-scroll {
  overflow-x: auto;
  min-width: 0;
}

.stats-table {
  margin-top: 10px;
  min-width: 560px;
}

.th-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 0;
  border: none;
  background: none;
  color: inherit;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  cursor: pointer;
}

.th-arrow {
  color: var(--accent);
  font-size: 10px;
}

.is-sorted {
  color: var(--accent);
}

.dot {
  display: inline-block;
  width: 9px;
  height: 9px;
  margin-right: 6px;
  border-radius: 50%;
  vertical-align: baseline;
}

.row-name {
  color: var(--text);
}

.cell-week {
  min-width: 116px;
}

.mini {
  display: inline-block;
  width: 62px;
  height: 7px;
  margin-right: 6px;
  border-radius: 4px;
  background: #eef1f7;
  vertical-align: middle;
  overflow: hidden;
}

.mini-fill {
  display: block;
  height: 100%;
  border-radius: 4px;
  background: var(--accent);
}

.mini-text {
  color: var(--muted);
  font-size: 12px;
  font-variant-numeric: tabular-nums;
}

.month-detail {
  margin-top: 8px;
  padding: 10px 12px;
  border: 1px dashed var(--line);
  border-radius: 10px;
  background: #f7f9fd;
}

.chips {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 6px;
}

.chip {
  padding: 1px 9px;
  border-radius: var(--radius-pill);
  background: #e8f0ff;
  color: var(--accent);
  font-size: 11.5px;
  line-height: 1.7;
}

.chip-today {
  background: #e8f5ee;
  color: var(--accent2);
  font-weight: 700;
}

.empty-cell {
  color: var(--muted);
  text-align: center;
}

/* ---------- 空态 ---------- */
.empty-state {
  gap: 8px;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

@media (max-width: 720px) {
  .stat-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .bars {
    gap: 6px;
  }

  .bar-track {
    height: 104px;
  }

  .bar-done {
    display: none;
  }

  .filters {
    width: 100%;
  }

  .filter-input {
    flex: 1;
    width: auto;
    min-width: 120px;
  }
}
</style>
