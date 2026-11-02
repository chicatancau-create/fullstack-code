/**
 * 统计纯函数（第5题 · 学习习惯打卡）
 *
 * 约定：
 * 1. 本文件不依赖 Vue，入参 / 出参全部是普通对象与数组，可以脱离组件单独测试。
 * 2. 所有比率统一返回 0–1 之间的小数；分母为 0、入参非法、计算出现 NaN 时一律返回 0，
 *    保证视图层做乘除、百分比、柱状高度时不会拿到 NaN / Infinity。
 * 3. 日期键统一为 'YYYY-MM-DD'，字典序比较即时间先后，因此 'a' < 'b' 可直接用。
 */
import {
  addDays,
  calcCurrentStreak,
  calcLongestStreak,
  fromDateKey,
  getMonthCalendar,
  getWeekDates,
  isValidDateKey,
  startOfMonth,
  startOfWeek,
  toDateKey,
} from '@/utils/date'

const DEFAULT_RECENT_WEEKS = 8
const FALLBACK_COLOR = '#2f6b52'

/* ---------------------------------------------------------------- 工具 ----- */

function normalizeHabits(habits) {
  if (!Array.isArray(habits)) return []
  return habits.filter((habit) => habit && typeof habit.id === 'string' && habit.id)
}

function normalizeCheckins(checkins) {
  return checkins && typeof checkins === 'object' ? checkins : {}
}

/** 取某个习惯的合法打卡日期（非法键丢弃、重复键去重，防止脏数据抬高统计）。 */
function datesOf(checkins, id) {
  const raw = normalizeCheckins(checkins)[id]
  return Array.isArray(raw) ? [...new Set(raw.filter(isValidDateKey))] : []
}

/** 每周目标天数兜底：非 1–7 的整数时收敛到合法区间。 */
function targetOf(target) {
  const num = Number(target)
  if (!Number.isFinite(num)) return 1
  return Math.min(7, Math.max(1, Math.round(num)))
}

/** 比率兜底：分母 <= 0 或结果非有限数时返回 0，并夹在 0–1。 */
function safeRate(numerator, denominator) {
  const top = Number(numerator)
  const bottom = Number(denominator)
  if (!Number.isFinite(top) || !Number.isFinite(bottom) || bottom <= 0) return 0
  const rate = top / bottom
  if (!Number.isFinite(rate) || rate <= 0) return 0
  return Math.min(rate, 1)
}

function clampRate(rate) {
  const num = Number(rate)
  if (!Number.isFinite(num) || num <= 0) return 0
  return Math.min(num, 1)
}

/** 允许传 Date 或 'YYYY-MM-DD'，非法时退回今天。 */
function toDate(value) {
  if (value instanceof Date && !Number.isNaN(value.getTime())) return value
  if (isValidDateKey(value)) return fromDateKey(value)
  return new Date()
}

/** 允许传 Date、'YYYY-MM' 或 'YYYY-MM-DD'，非法时退回本月。 */
function toMonthDate(value) {
  if (typeof value === 'string' && /^\d{4}-\d{2}$/.test(value)) {
    const [year, month] = value.split('-')
    return new Date(Number(year), Number(month) - 1, 1, 12)
  }
  return startOfMonth(toDate(value))
}

function monthKeyOf(date) {
  return toDateKey(date).slice(0, 7)
}

function monthLabelOf(date) {
  return `${date.getFullYear()}年${date.getMonth() + 1}月`
}

function shortLabelOf(key) {
  const date = fromDateKey(key)
  return `${date.getMonth() + 1}.${date.getDate()}`
}

/* ------------------------------------------------------------ 热力月历 ----- */

/**
 * 构造某个月的热力数据。
 * @param {Array} habits   Habit[]
 * @param {Object} checkins Record<habitId, string[]>
 * @param {Date|string} monthDate 月内任意日期 / 'YYYY-MM'
 * @returns {{monthKey:string,label:string,cells:(string|null)[],counts:Record<string,number>,detail:Record<string,{name:string,color:string}[]>,max:number}}
 */
export function buildMonthHeatmap(habits, checkins, monthDate = new Date()) {
  const list = normalizeHabits(habits)
  const month = toMonthDate(monthDate)
  const cells = getMonthCalendar(month)
  const membership = list.map((habit) => ({
    name: habit.name || '未命名习惯',
    color: habit.color || FALLBACK_COLOR,
    set: new Set(datesOf(checkins, habit.id)),
  }))

  const counts = {}
  const detail = {}
  let max = 0

  cells.forEach((key) => {
    if (!key) return
    const hits = membership.filter((item) => item.set.has(key))
    counts[key] = hits.length
    detail[key] = hits.map(({ name, color }) => ({ name, color }))
    if (hits.length > max) max = hits.length
  })

  return {
    monthKey: monthKeyOf(month),
    label: monthLabelOf(month),
    cells,
    counts,
    detail,
    // 该月单日最多几个习惯打了卡；没有打卡时为 0，由视图负责兜底
    max,
  }
}

/* ------------------------------------------------------------ 总体概览 ----- */

/**
 * 顶部数字卡 + 明细表需要的汇总数据。
 * currentStreak / bestStreak 取「整体口径」：当天只要任意一个习惯打了卡即算一天。
 * avgRate 取「平均口径」：各习惯本周完成率的算术平均。
 */
export function overallSummary(habits, checkins, todayKey = toDateKey()) {
  const list = normalizeHabits(habits)
  const today = isValidDateKey(todayKey) ? todayKey : toDateKey()
  const refDate = fromDateKey(today)
  const weekKeys = getWeekDates(refDate).map((date) => toDateKey(date))
  const weekSet = new Set(weekKeys)

  const rows = list.map((habit) => {
    const dates = datesOf(checkins, habit.id)
    const target = targetOf(habit.target)
    const weekDone = dates.filter((key) => weekSet.has(key) && key <= today).length
    return {
      id: habit.id,
      name: habit.name || '未命名习惯',
      target,
      color: habit.color || FALLBACK_COLOR,
      total: dates.length,
      weekDone,
      weekRate: safeRate(weekDone, target),
      currentStreak: calcCurrentStreak(dates, refDate),
      longestStreak: calcLongestStreak(dates),
    }
  })

  const allKeys = [...new Set(rows.flatMap((row) => datesOf(checkins, row.id)))].sort()
  const rateSum = rows.reduce((sum, row) => sum + row.weekRate, 0)

  const perHabit = rows.map(({ total, ...rest }) => rest)

  return {
    habitCount: perHabit.length,
    totalCheckins: rows.reduce((sum, row) => sum + row.total, 0),
    thisWeekDone: rows.reduce((sum, row) => sum + row.weekDone, 0),
    // 没有习惯时 rateSum / 0 会得到 NaN，这里显式返回 0
    avgRate: perHabit.length ? clampRate(rateSum / perHabit.length) : 0,
    bestStreak: calcLongestStreak(allKeys),
    currentStreak: calcCurrentStreak(allKeys, refDate),
    perHabit,
  }
}

/* ------------------------------------------------------------ 近 N 周 ----- */

/**
 * 近 n 周完成率（含当周），返回按时间正序的数组，方便直接画柱状图。
 * 本周尚未过完，分母仍按整周目标天数计算，因此当周柱形偏低属预期。
 */
export function recentWeeks(habits, checkins, refDate = new Date(), n = DEFAULT_RECENT_WEEKS) {
  const list = normalizeHabits(habits)
  const totalTarget = list.reduce((sum, habit) => sum + targetOf(habit.target), 0)
  const membership = list.map((habit) => new Set(datesOf(checkins, habit.id)))
  const count = Math.min(52, Math.max(1, Number.isFinite(Number(n)) ? Math.round(Number(n)) : DEFAULT_RECENT_WEEKS))
  const base = startOfWeek(toDate(refDate))

  const weeks = []
  for (let back = count - 1; back >= 0; back -= 1) {
    const monday = addDays(base, -7 * back)
    const keys = getWeekDates(monday).map((date) => toDateKey(date))
    const weekSet = new Set(keys)
    const done = membership.reduce(
      (sum, set) => sum + keys.filter((key) => set.has(key)).length,
      0,
    )
    weeks.push({
      weekKey: keys[0],
      label: shortLabelOf(keys[0]),
      done,
      rate: safeRate(done, totalTarget),
    })
  }

  return weeks
}
