// === main.js — 导入模块 ===

// 导入默认导出（不需要花括号）
import multiply from "./math.js";

// 导入具名导出（需要花括号）
import { add, subtract, PI } from "./math.js";

// 一次性导入默认导出和具名导出
import multiply, { add, subtract } from "./math.js";

// 导入时重命名
import { add as plus } from "./math.js";

// 导入整个模块作为命名空间
import * as math from "./math.js";
console.log(math.add(1, 2));      // 3
console.log(math.default(3, 4));  // 12