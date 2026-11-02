const DATE_KEY_PATTERN = /^(\d{4})-(\d{2})-(\d{2})$/

export function toDateKey(date = new Date()) {
  if (!(date instanceof Date) || Number.isNaN(date.getTime())) {
    throw new TypeError('无效日期')
  }

  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

export function fromDateKey(key) {
  const match = DATE_KEY_PATTERN.exec(key)
  if (!match) throw new TypeError('日期键必须为 YYYY-MM-DD')

  const [, year, month, day] = match
  const date = new Date(Number(year), Number(month) - 1, Number(day), 12)
  if (
    date.getFullYear() !== Number(year) ||
    date.getMonth() !== Number(month) - 1 ||
    date.getDate() !== Number(day)
  ) {
    throw new TypeError('无效日期')
  }
  return date
}

export function isValidDateKey(key) {
  if (typeof key !== 'string') return false
  try {
    fromDateKey(key)
    return true
  } catch {
    return false
  }
}

export function addDays(date, amount) {
  const next = new Date(date)
  next.setDate(next.getDate() + amount)
  return next
}

export function addMonths(date, amount) {
  const next = new Date(date.getFullYear(), date.getMonth() + amount, 1, 12)
  return next
}

export function startOfWeek(date = new Date()) {
  const start = new Date(date)
  start.setHours(12, 0, 0, 0)
  const day = start.getDay()
  start.setDate(start.getDate() + (day === 0 ? -6 : 1 - day))
  return start
}

export function getWeekDates(date = new Date()) {
  const monday = startOfWeek(date)
  return Array.from({ length: 7 }, (_, index) => addDays(monday, index))
}

export function startOfMonth(date = new Date()) {
  return new Date(date.getFullYear(), date.getMonth(), 1, 12)
}

export function getMonthCalendar(date = new Date()) {
  const first = startOfMonth(date)
  const leadingDays = (first.getDay() + 6) % 7
  const daysInMonth = new Date(first.getFullYear(), first.getMonth() + 1, 0).getDate()
  const cellCount = Math.ceil((leadingDays + daysInMonth) / 7) * 7

  return Array.from({ length: cellCount }, (_, index) => {
    const day = index - leadingDays + 1
    if (day < 1 || day > daysInMonth) return null
    return toDateKey(new Date(first.getFullYear(), first.getMonth(), day, 12))
  })
}

export function calcCurrentStreak(dateKeys, referenceDate = new Date()) {
  const completed = new Set(dateKeys.filter(isValidDateKey))
  const today = toDateKey(referenceDate)
  let cursor = new Date(referenceDate)

  if (!completed.has(toDateKey(cursor))) cursor = addDays(cursor, -1)

  let streak = 0
  while (completed.has(toDateKey(cursor))) {
    streak += 1
    cursor = addDays(cursor, -1)
  }

  return completed.has(today) || completed.has(toDateKey(addDays(referenceDate, -1)))
    ? streak
    : 0
}

export function calcLongestStreak(dateKeys) {
  const dates = [...new Set(dateKeys.filter(isValidDateKey))].sort()
  if (!dates.length) return 0

  let longest = 1
  let current = 1
  for (let index = 1; index < dates.length; index += 1) {
    const expected = toDateKey(addDays(fromDateKey(dates[index - 1]), 1))
    current = dates[index] === expected ? current + 1 : 1
    longest = Math.max(longest, current)
  }
  return longest
}

export function formatShortDate(key) {
  const date = fromDateKey(key)
  return `${date.getMonth() + 1}月${date.getDate()}日`
}

export function formatFullDate(key) {
  return new Intl.DateTimeFormat('zh-CN', {
    month: 'long',
    day: 'numeric',
    weekday: 'long',
  }).format(fromDateKey(key))
}
