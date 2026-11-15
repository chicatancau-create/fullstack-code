<template>
  <div class="habit-row">
    <div class="identity">
      <span class="color-dot" :style="{ background: habit.color }" aria-hidden="true"></span>
      <div class="identity-text">
        <strong class="name">{{ habit.name }}</strong>
        <span class="pill pill-goal">目标 {{ habit.target }} 天/周</span>
      </div>
    </div>

    <div class="cells" role="group" :aria-label="`${habit.name} 本周打卡`">
      <button
        v-for="cell in cells"
        :key="cell.dateKey"
        type="button"
        class="cell"
        :class="{ checked: cell.checked, future: cell.isFuture, today: cell.isToday }"
        :style="cell.checked ? { background: habit.color } : null"
        :disabled="cell.isFuture"
        :aria-pressed="cell.checked"
        :title="cell.title"
        @click="onCellClick(cell)"
      ><span v-if="cell.checked" class="tick">✓</span></button>
    </div>

    <div class="stats">
      <span class="pill pill-progress">本周 {{ weekDone }}/{{ habit.target }}</span>
      <div class="progress" aria-hidden="true">
        <span class="progress-bar" :style="barStyle"></span>
      </div>
      <span class="stat-text">{{ weekRate }}%</span>
      <span class="stat-text">连续 {{ currentStreak }} 天</span>
      <span class="stat-text">最长 {{ longestStreak }} 天</span>
    </div>

    <div class="row-actions">
      <button v-if="!confirmingDelete" type="button" class="btn-mini" @click="emit('edit', habit)">编辑</button>
      <button
        type="button"
        class="btn-mini btn-danger"
        :class="{ confirming: confirmingDelete }"
        @click="onRemoveClick"
      >{{ confirmingDelete ? '确认删除' : '删除' }}</button>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { calcCurrentStreak, calcLongestStreak, formatShortDate, isValidDateKey, toDateKey } from '@/utils/date'

const props = defineProps({
  habit: { type: Object, required: true },
  weekKeys: { type: Array, default: () => [] },
  dates: { type: Array, default: () => [] },
})

const emit = defineEmits(['toggle', 'edit', 'remove'])

const todayKey = toDateKey()

const checkedSet = computed(() => new Set(props.dates.filter(isValidDateKey)))

const cells = computed(() =>
  props.weekKeys.map((dateKey) => {
    const checked = checkedSet.value.has(dateKey)
    const isFuture = dateKey > todayKey
    const label = isValidDateKey(dateKey) ? formatShortDate(dateKey) : dateKey
    let hint = '未打卡，点击打卡'
    if (isFuture) hint = '未来日期不可打卡'
    else if (checked) hint = '已打卡，点击取消'
    return {
      dateKey,
      checked,
      isFuture,
      isToday: dateKey === todayKey,
      title: `${label} · ${hint}`,
    }
  }),
)

const weekDone = computed(
  () => props.weekKeys.filter((dateKey) => checkedSet.value.has(dateKey)).length,
)
const weekRate = computed(() => Math.round((weekDone.value / props.habit.target) * 100))
const barStyle = computed(() => ({ width: `${Math.min(weekRate.value, 100)}%` }))
const currentStreak = computed(() => calcCurrentStreak(props.dates))
const longestStreak = computed(() => calcLongestStreak(props.dates))

const confirmingDelete = ref(false)
let deleteTimer = null

// 父页切换查看的周后，旧的「再点一次确认删除」语境已失效，立即清掉行内确认态
watch(() => props.weekKeys, () => {
  clearDeleteTimer()
  confirmingDelete.value = false
})

function clearDeleteTimer() {
  if (deleteTimer !== null) {
    clearTimeout(deleteTimer)
    deleteTimer = null
  }
}

function onCellClick(cell) {
  if (cell.isFuture) return
  emit('toggle', props.habit.id, cell.dateKey)
}

function onRemoveClick() {
  if (confirmingDelete.value) {
    clearDeleteTimer()
    confirmingDelete.value = false
    emit('remove', props.habit)
    return
  }
  confirmingDelete.value = true
  deleteTimer = setTimeout(() => {
    confirmingDelete.value = false
    deleteTimer = null
  }, 2500)
}

onBeforeUnmount(clearDeleteTimer)
</script>

<style scoped>
.habit-row {
  display: grid;
  /* 四列轨道全部写成「与本列内容无关」的尺寸，HabitList.vue 的 .list-head 用同一份声明，
     表头与格子才可能逐列等宽（原来第 2/4 列是 auto，表头内容与行内容不同 →
     1280px 下量到表头 220/301/260/37、行 190/288/240/100，星期条整体右移 30px，
     「本周统计」右移 53px；901px 下第 4 列还会缩到 90px 把「编辑」二字压成两行）。
     第 2 列 = 7 个格子 + 6 个间隙，由 --cell-size/--cell-gap 算出（与 .cells 的实际宽度同源）；
     第 4 列 = 编辑+删除 两个小按钮的实测宽度 100px + 4px 余量（字体度量差异时不至于把
     「编辑」二字压成两行，余量由 .row-actions 右对齐推到统计列与按钮之间）。
     四列最小值之和 132+288+200+104+3×12=760px ≤ 最窄桌面档（901px 视口）行宽 795px，
     真实浏览器还要扣掉 15~17px 竖向滚动条，留 35px 余量才不会把 .habit-list 顶出横向滚动条
     （第 1 列的下限因此从 150px 降到 132px：列里最宽的不折行内容是「目标 N 天/周」胶囊 ≈104px）。 */
  grid-template-columns:
    minmax(132px, 220px)
    calc(var(--cell-size, 36px) * 7 + var(--cell-gap, 6px) * 6)
    minmax(200px, 260px)
    104px;
  align-items: center;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid var(--line);
}
.identity {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}
.color-dot {
  flex: none;
  width: 14px;
  height: 14px;
  border-radius: 5px;
}
.identity-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}
.name {
  font-size: 14px;
  color: var(--text);
  overflow-wrap: anywhere;
}
.pill {
  align-self: flex-start;
  padding: 1px 8px;
  border-radius: 10px;
  font-size: 11.5px;
}
.pill-goal {
  background: #e8f0ff;
  color: #3b6fd4;
}
.pill-progress {
  background: #e8f5ee;
  color: #0e7a52;
}
.cells {
  display: flex;
  gap: var(--cell-gap, 6px);
}
.cell {
  width: var(--cell-size, 36px);
  height: var(--cell-size, 36px);
  flex: none;
  padding: 0;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: #fafbfe;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font: inherit;
}
.cell.checked {
  border-color: transparent;
}
.cell .tick {
  color: #fff;
  font-size: 15px;
  line-height: 1;
}
.cell.today {
  box-shadow: 0 0 0 2px var(--accent);
}
.cell.future,
.cell.future:disabled {
  background: #eef1f6;
  cursor: not-allowed;
  color: var(--muted);
}
.cell:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
/* 「本周统计」= 两行三列网格（5 项 flat children 按 DOM 顺序自动落位，不额外包一层）：
   第 1 行 = 本周胶囊 | 进度条 | 百分比，第 2 行 = 连续 N 天 | 最长 N 天。
   原本 5 项横成一排的内容最小宽度约 278px，而轨道只有 217.5px(901)/247px(1280)，
   .stats 又是 overflow:visible，多出来的 31~63px 会直接画进右侧「操作」列里。
   这里靠「内部换行」而不是「加宽轨道」解决：行宽在 901px 视口只有 795px，
   其余三列的最小值之和（132+288+104+3×12gap）已经吃掉 560px，把 .stats 的 minmax
   下限抬到 278px 会让整行撑破 .habit-list、量出横向滚动，所以只能让统计自己换行。
   第 1/3 列必须是**定宽**而不是 max-content：实测 max-content 时「80%」列 24.75px、
   「100%」列 31.8px，中间 1fr 跟着变，四行的进度条右边缘量出 911 / 918 两档、
   错位 7px。定宽后逐行相等。上限依据：第 1 列最宽内容是「本周 7/7」（done 与 target
   都 ≤7，不会出现三位数），第 3 列最宽是「100%」。 */
.stats {
  display: grid;
  grid-template-columns: 66px 1fr 40px;
  column-gap: 8px;
  row-gap: 3px;
  align-items: center;
  min-width: 0;
}
.progress {
  /* 网格项默认 stretch 铺满中间列，min-width 保证列窄到极限时进度条仍然可见 */
  min-width: 60px;
  height: 8px;
  border-radius: 6px;
  background: #eef1f6;
  overflow: hidden;
}
.progress-bar {
  display: block;
  height: 100%;
  border-radius: 6px;
  background: var(--accent2);
}
.stat-text {
  font-size: 12px;
  color: var(--muted);
  white-space: nowrap;
}
.row-actions {
  display: flex;
  gap: 6px;
  /* 轨道比两个按钮宽 4px，余量留在左侧（统计列与按钮之间），按钮本身永不被压成两行 */
  justify-content: flex-end;
}
.btn-mini {
  padding: 4px 10px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: #fff;
  color: var(--brand);
  font-size: 12.5px;
  cursor: pointer;
  white-space: nowrap;
}
.btn-danger {
  color: var(--danger);
  border-color: var(--danger);
}
.btn-danger.confirming {
  background: var(--danger);
  color: #fff;
}

/* 窄屏（≤900px）：与 HabitList.vue 的表头在同一断点同步堆叠——
   第 1 行 = 名称/目标（左）+ 编辑·删除（右），第 2 行 = 7 个打卡格子独占一行（与表头条左对齐、同尺寸），
   第 3 行 = 本周统计整行铺开，内部仍是上面那套两行网格（列宽跟着整行放大，信息一项不少） */
@media (max-width: 900px) {
  .habit-row {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px 12px;
  }
  .row-actions {
    order: 2;
    margin-left: auto;
  }
  .cells {
    order: 3;
    /* flex-basis:100% = 强制换行：格子条永远独占一行，且与表头星期条左边缘对齐 */
    flex: 0 1 100%;
  }
  .stats {
    order: 4;
    flex: 0 1 100%;
    /* 整行铺开后中间列不再无限拉伸（1fr 会吃掉 600px 剩余空间，把百分比顶到最右侧）：
       上限 260px 与桌面档的进度条观感一致，网格默认左对齐，右侧留白不承载信息。
       两侧同样用定宽，理由见 .stats 主声明（max-content 会让逐行右边缘错位） */
    grid-template-columns: 66px minmax(60px, 260px) 40px;
  }
}

/* 更窄一档：格子尺寸由 HabitList.vue 的 --cell-size 统一下调，这里只补换行兜底 */
@media (max-width: 420px) {
  .cells {
    flex-wrap: wrap;
  }
}
</style>
