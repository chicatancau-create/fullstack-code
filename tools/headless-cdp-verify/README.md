# headless-cdp-verify

不装 Playwright/Puppeteer，用 `spawn` 自起 headless Edge + 手写 CDP 客户端（Node 24 全局 `WebSocket`，零依赖）做前端真机取证：实拍截图、真实视口、真指针交互、可复跑的布局断言。

配套经验记录：`E:\本地AI使用手册\01-前端\09-测试与质量\`（自写 CDP 探针的七种假阳性）、`01-前端\02-CSS与视觉\`（flex/grid `min-width:auto` 撑宽兄弟卡片 + 遮挡不等于溢出）。

## 四条不可妥协的做法

1. **端口只从自己的 profile 读。** 启动一律 `--remote-debugging-port=0`，真实端口从临时 `user-data-dir` 里的 `DevToolsActivePort` 第一行读。**绝不探固定调试端口**——本机 `127.0.0.1:9333` 是 Qoder 内置隐藏 Chrome，探到它就等于在导航用户自己的标签页。
2. **先判 `child.exitCode` 再等端口。** 启动失败的浏览器会留下一个永远不出现的端口文件，不检查就只会看到 30 秒超时，把你引向「端口不通」的错方向。
3. **断言必须被证明会失败。** 全绿不等于有牙齿：抹掉被测状态跑一次，确认相关断言变红。
4. **收尾杀进程树 + 显式 `process.exit()`。** 持有 WebSocket 与 HTTP server 的 Node 永远不会自己退出。清理用 `taskkill /PID <pid> /T /F`，再 `rmSync` 临时 profile。

## 用法

被测应用要先有一个 HTTP 入口。Vite 项目用构建产物 + `vite preview`（**别占用户自己的 5173/4173**）：

```sh
cd ../../Web/vue && npm run build
npx vite preview --port 4187 --strictPort --host 127.0.0.1 &
VERIFY_BASE=http://127.0.0.1:4187 node examples/measure-overflow.mjs
```

| 脚本 | 判什么 | 退出码 |
| --- | --- | --- |
| `measure-overflow.mjs` | 多个视口 × 多个路由的 `documentElement.scrollWidth - clientWidth`，并列出溢出元素与「被滚动容器裁掉」的节点 | 0 全绿 / 1 有溢出 / 2 跑挂了 |
| `measure-overlap.mjs` | 兄弟列互相压住的像素量（`overflow:visible` 的 grid 轨道被压窄时文字会画到邻列下面，`over` 却仍是 0） | — |
| `assert-app.mjs` | 端到端行为断言 + 实拍截图（登录守卫、增删改、持久化、翻周翻月边界、404、窄视口），含反向对照与 `N/E` 档 | `fail > 1` 才非零（预留 1 条故意的负对照） |
| `capture-shots.mjs` | 在**干净种子态**下按顺序拍一组图，避免同一轮里的增删改让各图数据互相矛盾 | 0 |

## 改造成自己的项目

四个脚本共用同一段 `CDP` 类与 `ownPort()` 轮询，抄过去即可。需要按你的 DOM 改的是：

- `measure-overflow.mjs` 里的 `SIZES` / `ROUTES`
- `assert-app.mjs` 里的选择器与断言文案（**这份是 Vue 习惯打卡应用的验收脚本，选择器写死了它的类名**，只能当写法范例，不能直接跑别的项目）

`deviceScaleFactor` 设 2 时截图像素 = 视口 × 2，判据里的像素量也跟着翻倍；实拍与取数必须共用同一组参数。

## 已知测不到的

触屏没有 hover，CSS 浮层类明细在这条回路上量不到；真实滚动条宽度在 headless 模拟里不计入 `clientWidth`，901–906px 这类临界窗口在真浏览器上会比量到的少 15–17px。
