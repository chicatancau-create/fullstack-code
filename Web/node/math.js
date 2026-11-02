// === math.js — 导出模块 ===

// 具名导出：一次导出多个
export function add(a, b) {
  return a + b;
}

export function subtract(a, b) {
  return a - b;
}

export const PI = 3.14159;

// 默认导出：每个文件最多一个
export default function multiply(a, b) {
  return a * b;
}