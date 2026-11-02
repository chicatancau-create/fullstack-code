<template>
  <section class="card heatmap">
    <header class="hm-head">
      <h3 class="section-title">打卡热力月历</h3>
      <div class="hm-nav">
        <button
          class="btn btn-sm"
          type="button"
          aria-label="上一月"
          @click="emit('change-month', -1)"
        >
          ‹ 上一月
        </button>
        <span class="hm-month" aria-live="polite">{{ monthLabel }}</span>
        <button
          class="btn btn-sm btn-primary"
          type="button"
          aria-label="下一月"
          :disabled="nextDisabled"
          @click="emit('change-month', 1)"
        >
          下一月 ›
        </button>
      </div>
    </header>

    <p class="muted hm-summary">
      <span v-if="maxSafe">单日最多 {{ maxSafe }} 个习惯完成打卡</span>
      <span v-else>本月还没有任何打卡记录</span>
      <span v-if="nextDisabled" class="pill pill-amber hm-edge">已是当前月，未来月份不可查看</span>
      <span v-else class="muted hm-edge">{{ monthAfterText }}</span>
    </p>

    <!-- 周一起排的表头，与下方 7 列网格严格对齐 -->
    <div class="hm-weekdays" aria-hidden="true">
      <span v-for="day in WEEK_LABELS" :key="day" class="hm-weekday">{{ day }}</span>
    </div>

    <div class="hm-grid" :aria-label="`${monthLabel}打卡热力图`">
      <div
        v-for="(cellKey, index) in safeCells"
        :key="cellKey || `blank-${index}`"
        class="hm-cell"
        :class="cellClass(cellKey, index)"
        :tabindex="isFocusable(cellKey) ? 0 : -1"
        :aria-label="cellAriaLabel(cellKey)"
      >
        <template v-if="cellKey">
          <span class="hm-day">{{ dayNumberOf(cellKey) }}</span>
          <span v-if="countOf(cellKey)" class="hm-count">{{ countOf(cellKey) }}</span>
          <!-- 悬停与键盘聚焦共用这一份明细：靠 CSS :hover / :focus 显隐，不注册监听、不碰 DOM -->
          <div v-if="hasDetail(cellKey)" class="hm-tip" role="tooltip">
            <strong class="hm-tip-title">{{ tipTitle(cellKey) }}</strong>
            <ul class="hm-tip-list">
              <li v-for="item in detailOf(cellKey)" :key="`${cellKey}-${item.name}`">
                <i class="hm-dot" :style="{ backgroundColor: item.color }"></i>
                <span>{{ item.name }}</span>
              </li>
            </ul>
          </div>
        </template>
        <span v-else class="hm-blank" aria-hidden="true">·</span>
      </div>
    </div>

    <footer class="hm-foot">
      <button class="btn btn-sm hm-legend-btn" type="button" @click="showLegend = !showLegend">
        {{ showLegend ? '收起色阶图例' : '查看色阶图例' }}
      </button>
      <div v-if="showLegend" class="hm-legend">
        <span v-for="level in LEGEND" :key="level.cls" class="hm-legend-item">
          <i class="hm-swatch" :class="level.cls"></i>{{ level.text }}
        </span>
        <span class="hm-legend-item"><i class="hm-swatch is-future-demo"></i>未来日期</span>
      </div>
    </footer>
  </section>
</template>

<script setup>
import { computed, ref } from 'vue'
import { formatFullDate, isValidDateKey, toDateKey } from '@/utils/date'

const props = defineProps({
  // 'YYYY-MM'，标题直接由它推导，避免父页再传一份文案
  monthKey: { type: String, default: '' },
  cells: { type: Array, default: () => [] },
  counts: { type: Object, default: () => ({}) },
  detail: { type: Object, default: () => ({}) },
  max: { type: Number, default: 0 },
  todayKey: { type: String, default: toDateKey() },
  // 「下一月不能超过当前月」这类边界由父页判定后下发
  nextDisabled: { type: Boolean, default: false },
})

const emit = defineEmits(['change-month'])

const WEEK_LABELS = ['一', '二', '三', '四', '五', '六', '日']
const LEGEND = [
  { cls: 'heat-0', text: '0 个习惯' },
  { cls: 'heat-1', text: '1 个' },
  { cls: 'heat-2', text: '2 个' },
  { cls: 'heat-3', text: '3 个及以上' },
]

// 图例是纯 UI 开合状态，用 ref 足够，不必提升到父页
const showLegend = ref(true)

const safeCells = computed(() => (Array.isArray(props.cells) ? props.cells : []))

const maxSafe = computed(() => {
  const num = Number(props.max)
  return Number.isFinite(num) && num > 0 ? num : 0
})

const monthLabel = computed(() => {
  const matched = /^(\d{4})-(\d{2})$/.exec(props.monthKey)
  if (!matched) return '—'
  return `${matched[1]}年${Number(matched[2])}月`
})

// 图例最后一格之外的提示文案，非法 monthKey 时不显示，避免拼出「— 之后」这种怪文案
const monthAfterText = computed(() => (monthLabel.value === '—' ? '' : '可继续往前翻看历史月份'))

const todayValid = computed(() => isValidDateKey(props.todayKey))

function countOf(cellKey) {
  if (!cellKey) return 0
  const num = Number(props.counts?.[cellKey])
  return Number.isFinite(num) && num > 0 ? num : 0
}

function detailOf(cellKey) {
  if (!cellKey) return []
  const list = props.detail?.[cellKey]
  return Array.isArray(list) ? list : []
}

function isFuture(cellKey) {
  // 日期键是 YYYY-MM-DD，字典序即时间序
  return Boolean(cellKey) && todayValid.value && cellKey > props.todayKey
}

function hasDetail(cellKey) {
  return Boolean(cellKey) && !isFuture(cellKey) && detailOf(cellKey).length > 0
}

function isFocusable(cellKey) {
  return hasDetail(cellKey)
}

/**
 * 色阶分档：max <= 3 时严格用课定的 0/1/2/3+ 四档；
 * 习惯多、单日 max 更大时按 max 归一，仍压回 4 档保证肉眼可辨。
 */
function heatLevel(cellKey) {
  const count = countOf(cellKey)
  if (count <= 0) return 0
  const max = maxSafe.value
  if (max <= 3) return Math.min(count, 3)
  return Math.min(3, Math.max(1, Math.ceil((count / max) * 3)))
}

function cellClass(cellKey, index) {
  if (!cellKey) return ['is-blank']
  return [
    `heat-${heatLevel(cellKey)}`,
    {
      'is-today': Boolean(todayValid.value) && cellKey === props.todayKey,
      'is-future': isFuture(cellKey),
      'tip-below': index < WEEK_LABELS.length,
      'tip-left': index % WEEK_LABELS.length === 0,
      'tip-right': index % WEEK_LABELS.length === WEEK_LABELS.length - 1,
    },
  ]
}

function dayNumberOf(cellKey) {
  return Number(cellKey.slice(8, 10)) || 1
}

function tipTitle(cellKey) {
  return isValidDateKey(cellKey) ? formatFullDate(cellKey) : cellKey
}

function cellAriaLabel(cellKey) {
  if (!cellKey) return '空白格'
  if (isFuture(cellKey)) return `${cellKey} 尚未到来`
  const count = countOf(cellKey)
  return count ? `${cellKey}，${count} 个习惯完成打卡` : `${cellKey}，没有打卡`
}
</script>

<style scoped>
.heatmap {
  overflow: visible;
}

.hm-head {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 8px 12px;
}

.hm-head .section-title {
  margin-bottom: 0;
}

.hm-nav {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.hm-month {
  min-width: 92px;
  color: var(--brand);
  font-size: 14px;
  font-weight: 700;
  text-align: center;
  white-space: nowrap;
}

.hm-summary {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px 12px;
  margin: 10px 0 4px;
}

.hm-edge {
  margin-left: auto;
}

/* 表头与网格共用同一套 7 列轨道，保证周一到周日不错位 */
.hm-weekdays,
.hm-grid {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: 6px;
}

.hm-weekdays {
  margin-top: 8px;
}

.hm-weekday {
  padding: 2px 0;
  color: var(--muted);
  font-size: 12px;
  font-weight: 700;
  text-align: center;
}

.hm-grid {
  margin-top: 4px;
}

.hm-cell {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: space-between;
  min-height: 62px;
  padding: 5px 7px;
  border: 1px solid var(--line);
  border-radius: 8px;
  font-size: 12.5px;
  line-height: 1.4;
}

.hm-cell:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 1px;
}

.hm-day {
  color: var(--text);
  font-weight: 700;
  font-variant-numeric: tabular-nums;
}

.hm-count {
  align-self: flex-end;
  padding: 0 5px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.72);
  color: var(--brand);
  font-size: 11px;
  font-weight: 700;
}

/* 四档色阶：数值按课定 token，第 3 档起文字转白 */
.heat-0 {
  background-color: #eef1f7;
}

.heat-1 {
  background-color: #cfe0ff;
}

.heat-2 {
  background-color: #7ea6ec;
}

.heat-3 {
  background-color: var(--accent);
}

.heat-2 .hm-day,
.heat-3 .hm-day {
  color: #fff;
}

.heat-3 .hm-count {
  background: rgba(255, 255, 255, 0.85);
}

/* 跨月空白格：只留占位点，不参与任何交互 */
.is-blank {
  align-items: center;
  justify-content: center;
  min-height: 62px;
  border-style: dashed;
  border-color: #eef1f5;
  background-color: transparent;
}

.hm-blank {
  color: #cfd6e2;
  font-size: 14px;
}

.is-today {
  border-color: var(--accent2);
  box-shadow: inset 0 0 0 2px var(--accent2);
}

/* 未来日期：降不透明度 + 斜纹，且没有明细浮层 */
.is-future {
  opacity: 0.45;
  background-image: repeating-linear-gradient(
    135deg,
    rgba(34, 48, 63, 0.14) 0 3px,
    transparent 3px 7px
  );
  cursor: default;
}

/* 浮层默认向上弹出；首行（.tip-below）改向下，两侧贴边格改为对齐本格，避免跑出卡片 */
.hm-tip {
  position: absolute;
  bottom: calc(100% + 6px);
  left: 50%;
  z-index: 6;
  width: max-content;
  max-width: 210px;
  padding: 8px 10px;
  border: 1px solid var(--line);
  border-radius: 10px;
  background: var(--card);
  box-shadow: 0 4px 14px rgba(31, 58, 95, 0.14);
  color: var(--text);
  font-size: 12px;
  line-height: 1.6;
  text-align: left;
  opacity: 0;
  visibility: hidden;
  transform: translateX(-50%);
  transition: opacity 0.12s ease;
  pointer-events: none;
}

.hm-cell.tip-below .hm-tip {
  bottom: auto;
  top: calc(100% + 6px);
}

.hm-cell.tip-left .hm-tip {
  left: 0;
  transform: none;
}

.hm-cell.tip-right .hm-tip {
  left: auto;
  right: 0;
  transform: none;
}

.hm-tip-title {
  display: block;
  margin-bottom: 4px;
  color: var(--brand);
}

.hm-tip-list li {
  display: flex;
  align-items: center;
  gap: 6px;
  white-space: nowrap;
}

.hm-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex: none;
}

/* 仅靠 CSS 显示浮层：鼠标悬停、格子聚焦、格子内部元素聚焦三种入口都覆盖 */
.hm-cell:hover .hm-tip,
.hm-cell:focus .hm-tip,
.hm-cell:focus-within .hm-tip {
  opacity: 1;
  visibility: visible;
}

.hm-foot {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px 14px;
  margin-top: 12px;
}

.hm-legend {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 6px 12px;
}

.hm-legend-item {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  color: var(--muted);
  font-size: 12px;
  white-space: nowrap;
}

.hm-swatch {
  width: 14px;
  height: 14px;
  border: 1px solid var(--line);
  border-radius: 4px;
}

.is-future-demo {
  background-color: #eef1f7;
  background-image: repeating-linear-gradient(
    135deg,
    rgba(34, 48, 63, 0.2) 0 2px,
    transparent 2px 5px
  );
  opacity: 0.6;
}

@media (max-width: 720px) {
  .hm-cell {
    min-height: 44px;
    padding: 3px 4px;
    border-radius: 6px;
    font-size: 11.5px;
  }

  .hm-count {
    display: none;
  }

  .hm-head {
    justify-content: flex-start;
  }
}
</style>
