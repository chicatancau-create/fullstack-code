import { reactive, watch } from 'vue'
import { addDays, isValidDateKey, toDateKey } from '@/utils/date'

const STORAGE_KEY = 'xiji-habit-tracker-v1'
const COLORS = ['#2f6b52', '#d97745', '#6874b8', '#b58a32', '#b65c68']

function createSeedData() {
  const today = new Date()
  const createdAt = toDateKey(addDays(today, -90))
  const habits = [
    { id: 'habit-reading', name: '专注阅读', target: 5, color: COLORS[0], createdAt },
    { id: 'habit-english', name: '英语听力', target: 4, color: COLORS[2], createdAt },
    { id: 'habit-exercise', name: '舒展运动', target: 3, color: COLORS[1], createdAt },
    { id: 'habit-review', name: '每日复盘', target: 7, color: COLORS[4], createdAt },
  ]
  const checkins = Object.fromEntries(habits.map((habit) => [habit.id, []]))
  const patterns = [
    (offset) => offset % 7 !== 2 && offset % 11 !== 0,
    (offset) => (offset * 2 + 1) % 5 < 2,
    (offset) => [1, 3, 5].includes(offset % 7),
    (offset) => offset % 6 !== 2,
  ]

  habits.forEach((habit, habitIndex) => {
    for (let offset = 90; offset >= 0; offset -= 1) {
      if (patterns[habitIndex](offset)) {
        checkins[habit.id].push(toDateKey(addDays(today, -offset)))
      }
    }
  })

  return { habits, checkins }
}

function sanitizeData(data) {
  if (!data || !Array.isArray(data.habits) || typeof data.checkins !== 'object') {
    return createSeedData()
  }

  const ids = new Set()
  const habits = data.habits.reduce((valid, habit) => {
    const name = typeof habit?.name === 'string' ? habit.name.trim() : ''
    const target = Number(habit?.target)
    if (
      typeof habit?.id !== 'string' ||
      !habit.id ||
      ids.has(habit.id) ||
      !name ||
      name.length > 20 ||
      !Number.isInteger(target) ||
      target < 1 ||
      target > 7
    ) return valid

    ids.add(habit.id)
    valid.push({
      id: habit.id,
      name,
      target,
      color: COLORS.includes(habit.color) ? habit.color : COLORS[0],
      createdAt: isValidDateKey(habit.createdAt) ? habit.createdAt : toDateKey(),
    })
    return valid
  }, [])

  const today = toDateKey()
  const checkins = {}
  habits.forEach((habit) => {
    const dates = Array.isArray(data.checkins[habit.id]) ? data.checkins[habit.id] : []
    checkins[habit.id] = [...new Set(dates.filter(
      (key) => isValidDateKey(key) && key <= today,
    ))].sort()
  })
  return { habits, checkins }
}

const state = reactive({
  habits: [],
  checkins: {},
  storageError: '',
})

function loadState() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    const data = saved ? sanitizeData(JSON.parse(saved)) : createSeedData()
    state.habits = data.habits
    state.checkins = data.checkins
  } catch {
    const data = createSeedData()
    state.habits = data.habits
    state.checkins = data.checkins
    state.storageError = '本地数据读取失败，当前已载入示例数据。'
  }
}

function persistState() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({
      habits: state.habits,
      checkins: state.checkins,
    }))
    state.storageError = ''
  } catch {
    state.storageError = '浏览器存储不可用，本次修改可能无法在刷新后保留。'
  }
}

loadState()
watch(() => [state.habits, state.checkins], persistState, { deep: true, immediate: true })

function hasDuplicateName(name, excludeId = '') {
  const normalized = name.trim().toLocaleLowerCase()
  return state.habits.some(
    (habit) => habit.id !== excludeId && habit.name.toLocaleLowerCase() === normalized,
  )
}

function addHabit(input) {
  if (hasDuplicateName(input.name)) return { success: false, message: '已有同名习惯，请换一个名称' }
  const id = globalThis.crypto?.randomUUID?.() ?? `habit-${Date.now()}`
  state.habits.push({
    id,
    name: input.name.trim(),
    target: Number(input.target),
    color: input.color,
    createdAt: toDateKey(),
  })
  state.checkins[id] = []
  return { success: true }
}

function updateHabit(id, input) {
  const habit = state.habits.find((item) => item.id === id)
  if (!habit) return { success: false, message: '该习惯已不存在' }
  if (hasDuplicateName(input.name, id)) return { success: false, message: '已有同名习惯，请换一个名称' }
  Object.assign(habit, {
    name: input.name.trim(),
    target: Number(input.target),
    color: input.color,
  })
  return { success: true }
}

function deleteHabit(id) {
  state.habits = state.habits.filter((habit) => habit.id !== id)
  delete state.checkins[id]
}

function toggleCheckin(habitId, dateKey) {
  if (!state.habits.some((habit) => habit.id === habitId)) return false
  if (!isValidDateKey(dateKey) || dateKey > toDateKey()) return false

  const dates = state.checkins[habitId] ?? []
  state.checkins[habitId] = dates.includes(dateKey)
    ? dates.filter((key) => key !== dateKey)
    : [...dates, dateKey].sort()
  return true
}

function clearData() {
  state.habits = []
  state.checkins = {}
}

function resetData() {
  const data = createSeedData()
  state.habits = data.habits
  state.checkins = data.checkins
}

export function useHabits() {
  return {
    state,
    addHabit,
    updateHabit,
    deleteHabit,
    toggleCheckin,
    clearData,
    resetData,
  }
}

export { STORAGE_KEY }
