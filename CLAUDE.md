# CLAUDE.md

CursorTip 项目的 AI 工作规范。事实描述（目录结构、文件清单等）请用 Glob/LS 自查，本文件只记约束。

## 仓库边界

- `main` 分支**只**包含 AHK v2 桌面应用。产品官网在 `website` 分支（commit `4784909` 拆分），不要在此分支添加 HTML/CSS/JS。

## 构建与运行

前置：[AutoHotkey v2](https://www.autohotkey.com/)。

不编译运行：

```bash
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" CursorTip.ahk
```

编译 / 发行走 **`cursortip-build` skill**（编译触发词：编译、打包、构建、生成 exe、封装成 exe；发行触发词：发行、发布、发布到 GitHub、可以发行了、创建 Release、发新版本、发版）。

## AHK v2 代码规范

- 函数默认 **assume-local**，给脚本级全局变量赋值要 `global var1, var2`。
- 类的静态属性（如 `Config.*`）随处可访问，不需要 `global`。
- `Gui.OnEvent("Close", ...)` 传 `Gui`；`GuiCtrl.OnEvent("Click", ...)` 传带 `.Gui` 属性的 `GuiControl`。
- `IsObject(gui)` **不代表**窗口还存在，必须配 `WinExist("ahk_id " . gui.Hwnd)`。
- v2 语法更新快、AI 训练数据可能过期。修改涉及核心语法（Gui 控件、消息/窗口 API、FileInstall、imm32 等）前，**必须先查文档，按以下优先级**：
    1. **项目内部**：`docs/ahk-v2-development-guide.md`（覆盖 ~90% 关键语法/API）
    2. **AHK v2 官方**：context7 `/websites/autohotkey_v2`（v2 语法命中率 100%）
    3. **Windows API**：tavily search → Microsoft Docs（多源交叉验证）

## 约束与避坑

- **没有测试 / CI / Linter**，验证全靠手动。
- 编译产物 `CursorTip.exe`、`dist/`、`work/` 都在 `.gitignore`。
- 项目没有包管理。
- 修改前必须读懂相关代码（DRY 第二铁律），不要凭印象瞎改。
- 修改配置 / 脚本后必须排查引用方（第三铁律）。
- 网站分支的 `AGENTS.md` 不在本规则管辖。