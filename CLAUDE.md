# CLAUDE.md

本文件用于指导 Claude Code（claude.ai/code）在处理本仓库代码时的工作方式。

## 仓库结构

当前在 `main` 分支，**只包含** AutoHotkey v2 桌面应用。产品官网在独立的 `website` 分支（由 commit `4784909` 拆分）。如果需要编辑官网内容，请切换到对应分支，不要在 `main` 分支添加 HTML/CSS/JS 文件。

## 构建与运行

前置条件：已安装 [AutoHotkey v2](https://www.autohotkey.com/)。

不编译直接运行：

```bash
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" CursorTip.ahk
```

编译为 `CursorTip.exe` 走 **`cursortip-build` skill**（触发词：编译 / 打包 / 构建 / 生成 exe / 封装成 exe），由 skill 封装 Ahk2Exe 调用与图标参数，本文件不重复。

AHK 代码没有测试套件也没有 Linter，验证全靠手动：运行脚本、切换 CapsLock、复制文本/文件/图片，并测试设置窗口。

## 整体架构

`CursorTip.ahk` 故意做成了单文件应用，所有运行时逻辑都在这一个文件里。

- **`Config` 类** —— 静态配置单例。保存默认值，从 `A_ScriptDir\config.ini` 读写。所有设置在启动时走 `Config.Load()`，修改时走 `Config.Save()`。
- **Tip 窗口生命周期** —— `ShowTip()` 创建或复用无边框 `Gui` 窗口。固定宽度的提示（CapsLock/IME）复用同一个窗口以避免闪烁；可变宽度的提示（复制反馈）则重建窗口，让 `AutoSize` 正确测量新文本。
- **CapsLock + IME 检测** —— `CheckCapsLock()` 每 50 ms 轮询一次。`GetIMEStatus()` 优先调用 `imm32\ImmGetConversionStatus`；失败时回退到 `ImmGetDefaultIMEWnd` + `SendMessage(0x283, 0x005, ...)`。结果缓存 150 ms，除非显式传入 `forceRefresh`。
- **复制反馈** —— `OnClipboardChange(ClipChanged)` 通过 `IsClipboardFormatAvailable` 检查剪贴板格式，区分文件（`CF_HDROP = 15`）、图片（`CF_BITMAP`、`CF_DIB`、`CF_DIBV5`）和文本。
- **设置界面** —— `ShowSettings()` 构造窗口。`SettingsSave()` 读取控件、校验边界、调用 `Config.Save()` 和 `ApplySettings()`，然后销毁窗口。语言切换时 `ApplyLanguage()` 会在原窗口上重建设置界面。
- **开机自启** —— `SetStartup()` 写入或删除 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run\CursorTip`，指向脚本目录下的 `CursorTip.exe`。

全文件通用的 AutoHotkey v2 约定：

- 函数默认是 **assume-local**（默认局部变量），给脚本级全局变量赋值时要用 `global var1, var2`。
- 类的静态属性（如 `Config.*`）随处可直接访问，不需要 `global`。
- `Gui.OnEvent("Close", ...)` 传入的是 `Gui`；`GuiCtrl.OnEvent("Click", ...)` 传入的是带 `.Gui` 属性的 `GuiControl`。`SettingsClose()` 同时处理这两种情况。
- `IsObject(gui)` **并不能**说明窗口还存在；必须搭配 `WinExist("ahk_id " . gui.Hwnd)` 使用。

## 重要文件

- `CursorTip.ahk` —— 整个 AHK 应用。
- `config.ini` —— 用户配置，运行时生成，已加入 `.gitignore`。
- `docs/ahk-v2-development-guide.md` —— AHK v2 模式与项目专属设计笔记。其中部分路径涉及较早的重构（`CapsCopyTip`、`lib/`），但当前项目是单文件应用，那些内容当作「模式参考」看就行，不要照搬结构。

## 常见坑

- `work/` 是本地临时目录，已加入 `.gitignore`。
- 编译产物 `CursorTip.exe` 与 `dist/` 都被忽略。
- 项目没有包管理、没有测试、没有 CI，验证全靠手动。
- 官网分支有自己的 `AGENTS.md`，需要时切过去看。