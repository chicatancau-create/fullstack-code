# fullstack-code

一个用于系统性练习的**多语言学习仓库**，把 Web、C/C++、Python、HarmonyOS 四条练习线集中在一处。
仓库里既有可运行的语法笔记，也有跟课练习和平台 Demo，每个目录都能独立运行。

## 目录结构

| 目录 | 技术栈 | 内容 |
|---|---|---|
| `Web/js自学/` | 原生 HTML + JavaScript | 两页**可运行**的语法笔记，页面内会把 `console.log` 的真实输出打印到黄底框 |
| `Web/vue/` | Vue 3 + Vite + vue-router | 跟课练习：组件、路由、动态组件、商品管理表格与自定义指令 |
| `Cpp/` | C / C++（MinGW g++） | 环境自检样例，各一个可执行文件 |
| `Python/` | Python 3 + venv | 环境自检样例 |
| `Harmony/MyApplication/` | HarmonyOS ArkTS | 家电商城 Demo：底部 Tab 导航、搜索过滤、购物车 |

## 各模块怎么运行

### Web / js自学
无需构建，直接用浏览器打开对应 HTML 即可：

- `Web/js自学/javaScript基础语法.html`
- `Web/js自学/循环与数组.html`

### Web / vue

```bash
cd Web/vue
npm install
npm run dev        # 开发服务器，默认 http://localhost:5173
npm run build      # 生产构建
npm run preview    # 预览构建产物
```

要求 Node `^22.18.0 || >=24.12.0`。

### Cpp

用 VS Code 的构建任务（`Cpp/.vscode/tasks.json`，编译器 `g++`），或手动编译：

```bash
cd Cpp
g++ c.cpp -o c.exe
g++ EnvironmentTest.c -o EnvironmentTestC.exe
```

### Python

```bash
cd Python
python main.py
python EnvironmentTest.py
```

虚拟环境位于 `Python/.venv`（已被 git 忽略，需自行重建）。

### Harmony

用 DevEco Studio 打开 `Harmony/MyApplication` 工程后运行；依赖与构建产物（`oh_modules`、`.hvigor`、`build`）不入库。

## 相关文档

- [progress.md](progress.md) — 进度记录：仓库当前做到哪一步、结构是什么样、下一步做什么
- [errors.md](errors.md) — 错误清单：真实发生过的错误与排查过程

## 仓库说明

- 本仓库为个人学习用途。
- `.gitignore` 已忽略依赖与构建产物（`node_modules/`、`.venv/`、`*.exe`、`oh_modules/` 等），克隆后各模块需按上文自行安装依赖。

<!-- 双端同步测试 2026-10-15 -->
