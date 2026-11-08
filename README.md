# fullstack-code

一个用于系统性练习的**多语言学习仓库**，把 Web、C/C++、Python、HarmonyOS 四条练习线集中在一处。
仓库里既有可运行的语法笔记，也有跟课练习和平台 Demo，每个目录都能独立运行。

## 目录结构

| 目录 | 技术栈 | 内容 |
|---|---|---|
| `Web/js自学/` | 原生 HTML + JavaScript | 两页**可运行**的语法笔记，页面内会把 `console.log` 的真实输出打印到黄底框 |
| `Web/vue/` | Vue 3 + Vite + vue-router | 跟课练习：组件、路由、动态组件、商品管理表格与自定义指令 |
| `Web/webgl自学/` | 原生 HTML + Three.js r169（CDN importmap） | 单文件实时 3D 练习页。`浮空树脂小岛.html`：树脂圆柱沙盘、昼夜光照插值、GTAO + Bloom + AgX + SMAA、屏幕空间折射，贴图全程序化 |
| `Cpp/` | C / C++（MinGW g++） | 环境自检样例，各一个可执行文件 |
| `Python/` | Python 3 + venv | 环境自检样例 |
| `Harmony/yingye/` | HarmonyOS ArkTS | **当前主工程**：入口 `entry/src/main/ets/pages/Index.ets`，已备 10 张专辑封面素材供音乐播放器使用 |
| `Harmony/MyApplication/` | HarmonyOS ArkTS | 早期家电商城 Demo：底部 Tab 导航、搜索过滤、购物车 |

> ⚠️ `Harmony/` 下是**两个独立工程**，各自有 `entry/` 模块，互不引用。
> `yingye` 是当前在写的主工程，`MyApplication` 保留作参考。
> 用 DevEco Studio 打开时请分别打开各自的目录，不要打开 `Harmony/` 本身。

## 各模块怎么运行

### Web / js自学
无需构建，直接用浏览器打开对应 HTML 即可：

- `Web/js自学/javaScript基础语法.html`
- `Web/js自学/循环与数组.html`

### Web / webgl自学

无需构建，浏览器直接打开即可（需联网取 three.js）：

- `Web/webgl自学/浮空树脂小岛.html`

要点：

- 依赖只走 importmap（`three@0.169.0`，主源 `fastly.jsdelivr.net`）。本机到 CDN 偶发连接重置，
  已做三层兜底：addon 换镜像重试、核心库失败自动重载一次、失败面板给「重新加载」按钮；
  若始终不通，把 importmap 里的域名换成 `unpkg.com` 或本地 three 构建。
- 首次加载要 10–30s：所有贴图（沙纹/木纹/沉积层/法线）与高度场都是运行时程序化生成的，
  外加十几个着色器程序编译，不是卡死。
- 桌面端 only。交互：拖动环绕、滚轮缩放、`1`/`2`/`3` 切光照预设、空格停自动环绕、`H` 隐藏界面。

### Web / vue

```bash
cd Web/vue
npm install
npm run dev        # 开发服务器，默认 http://localhost:5173
npm run build      # 生产构建
npm run preview    # 预览构建产物
```

要求 Node `^22.18.0 || >=24.12.0`。

当前挂载的是**路由练习**：`src/App.vue` + `src/router/index.js` 只注册了
`/home`、`/about`（含子路由 `tab1`、`tab2`）。
`src/components/Goods/GoodsManage.vue`（商品管理表格 + `v-focus` 自定义指令）和
`src/components/Login/`（动态组件切换）是完整可用的组件，但**目前没有任何路由指向它们**——
要查看效果需临时在 `App.vue` 里直接引入，或补一条路由。

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

用 DevEco Studio 分别打开 `Harmony/yingye` 或 `Harmony/MyApplication` 后运行。

- 工程内**没有** `hvigorw` / `hvigorw.bat` 包装脚本，无法直接在命令行构建，验证以 DevEco 预览器/模拟器为主。
- 依赖与构建产物（`oh_modules`、`.hvigor`、`build`、`.preview`）不入库。

## 全栈项目线（project01–06）

| 目录 | 内容 | 本地入口 |
|---|---|---|
| `Web/project01-blog/` | React + Vite 学习笔记博客；组件 7/7、E2E、axe 0 | `npm ci && npm test && npm run build`；公网 <https://chicatancau-create.github.io/learning-blog-demo/> |
| `project02-collab/` | Fastify + PostgreSQL 协作平台；7/7、租户隔离、最后 Owner 并发 | `bash scripts/run_project.sh` |
| `project02-spring/` | Spring Boot + Spring Security + MySQL 迁移；本地 9/9、CI 10/10（Testcontainers） | `bash scripts/run_project.sh` |
| `project02-frameworks/` | Express/Nest 同契约对照；2/2 | 各目录 `npm test` |
| `project03-trade/` | 交易/库存/幂等/状态机 + RabbitMQ Outbox/Inbox/DLQ；15/15 | `bash scripts/run_project.sh` |
| `project04-saas/` | 多租户 SaaS、后台任务、OTel、Docker/K3s、Ingress、告警；13/13 | `bash scripts/run_project.sh` |
| `project05-takeover/` | 受控接手：3 缺陷→12/12 + D88–D90 | `bash scripts/run_project.sh`（独立库 `study_lab_p05`） |
| `project06-ai-min/` | mock LLM + 本地 Qwen0.5B + BM25 RAG | `npm test` / `node scripts/eval.mjs` |

CI：`.github/workflows/ci.yml`，8 个 job（项目 01–05、Java/MySQL、Express/Nest、AI）。最近全绿 run `42447157990`。
仓库为私有；项目 README 与 `evidence/` 里有逐项测试、故障注入和限制说明。

## 相关文档

- [progress.md](progress.md) — 进度记录：仓库当前做到哪一步、结构是什么样、下一步做什么
- [errors.md](errors.md) — 错误清单：真实发生过的错误与排查过程

## 仓库说明

- 本仓库为个人学习用途。
- `.gitignore` 已忽略依赖与构建产物（`node_modules/`、`.venv/`、`*.exe`、`oh_modules/`、`.hvigor/` 等），克隆后各模块需按上文自行安装依赖。
- `.workbuddy-ai/` 存放助手的工作数据（报告、记忆、备份），已被忽略，不属于项目内容。
