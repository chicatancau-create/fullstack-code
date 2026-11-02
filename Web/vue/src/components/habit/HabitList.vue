<template>
  <div class="habit-list">
    <div class="list-head">
      <span class="head-cell head-name">习惯</span>
      <div class="head-cells">
        <div
          v-for="day in headerDays"
          :key="day.dateKey"
          class="head-cell"
          :class="{ today: day.isToday }"
        >
          <span class="weekday">{{ day.label }}</span>
          <span class="daydate">{{ day.short }}</span>
        </div>
      </div>
      <span class="head-cell head-stats">本周统计</span>
      <span class="head-cell head-actions">操作</span>
    </div>

    <HabitRow
      v-for="habit in habits"
      :key="habit.id"
      :habit="habit"
      :week-keys="weekKeys"
      :dates="datesOf(habit.id)"
      @toggle="(habitId, dateKey) => emit('toggle', habitId, dateKey)"
      @edit="(habit) => emit('edit', habit)"
      @remove="(removed) => emit('remove', removed)"
    />

    <p v-if="!habits.length" class="list-empty">暂无习惯可展示，请先新增一个习惯。</p>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { formatShortDate, isValidDateKey, toDateKey } from '@/utils/date'
import HabitRow from './HabitRow.vue'

const WEEK_LABELS = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

const props = defineProps({
  habits: { type: Array, default: () => [] },
  weekKeys: { type: Array, default: () => [] },
  checkins: { type: Object, default: () => ({}) },
})

const emit = defineEmits(['toggle', 'edit', 'remove'])

const todayKey = toDateKey()

const headerDays = computed(() =>
  props.weekKeys.map((dateKey, index) => ({
    dateKey,
    label: WEEK_LABELS[index] || dateKey,
    short: isValidDateKey(dateKey) ? formatShortDate(dateKey) : '--',
    isToday: dateKey === todayKey,
  })),
)

// 兜底：checkins 里缺该习惯的键时给空数组，避免子组件拿到 undefined
function datesOf(habitId) {
  return props.checkins[habitId] ?? []
}
</script>

<style scoped>
.habit-list {
  /* 打卡格子（表头与每行共用）的尺寸变量：窄屏只改这两个值，表头与格子永远对齐 */
  --cell-size: 36px;
  --cell-gap: 6px;
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--card);
  padding: 6px 16px 10px;
  box-shadow: 0 1px 3px rgba(31, 58, 95, 0.05);
  min-width: 0;
}
.list-head {
  display: grid;
  /* 与 HabitRow.vue 的 .habit-row 逐字相同的四列轨道：第 2 列按 --cell-size/--cell-gap
     算出格子条宽度、第 4 列固定 104px，两边都不随本列文字长短变化，
     所以「星期条 / 本周统计 / 操作」的表头中心线正好落在每行对应内容的中心线上。
     改轨道必须同步改 HabitRow.vue，否则表头与格子错位。 */
  grid-template-columns:
    minmax(132px, 220px)
    calc(var(--cell-size, 36px) * 7 + var(--cell-gap, 6px) * 6)
    minmax(200px, 260px)
    104px;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
  border-bottom: 1px solid var(--line);
  background: #eaf0fa;
}
.head-cell {
  font-size: 12px;
  color: var(--brand);
  text-align: center;
}
.head-cells {
  display: flex;
  gap: var(--cell-gap);
}
.head-cells .head-cell {
  width: var(--cell-size);
  flex: none;
  display: flex;
  flex-direction: column;
  align-items: center;
  line-height: 1.35;
}
.head-cell.today {
  font-weight: 700;
}
.head-cell.today .daydate {
  color: var(--accent);
}
.weekday {
  font-weight: 700;
}
.daydate {
  font-size: 11px;
  color: var(--muted);
}
.head-name {
  text-align: left;
  padding-left: 6px;
}
.list-empty {
  margin: 12px 0 4px;
  text-align: center;
  font-size: 13px;
  color: var(--muted);
}

/* 窄屏（≤900px）：四列轨道的最小值之和 760px（132+288+200+104+3 个 gap），
   900px 以下的视口只剩 794px 及以下，四列并排已经没有可读空间，改为整行堆叠：
   第 1 行 = 三个列名当图例（习惯左、本周统计+操作右），第 2 行 = 7 个星期表头独占一行，
   堆叠顺序与 HabitRow.vue 同一断点里的一一对应，且表头条与格子条左边缘同宽同位。 */
@media (max-width: 900px) {
  .list-head {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px 12px;
  }
  .head-cells {
    order: 3;
    flex-basis: 100%;
  }
  .head-stats {
    margin-left: auto;
  }
}

/* 更窄一档：格子与表头同步缩到 32px（7×32+6×5=254px，390px 视口仍单行放得下），
   并允许换行兜底，绝不再把整页撑出横向滚动 */
@media (max-width: 420px) {
  .habit-list {
    --cell-size: 32px;
    --cell-gap: 5px;
    padding: 6px 10px 10px;
  }
  .head-cells {
    flex-wrap: wrap;
  }
}
</style>
