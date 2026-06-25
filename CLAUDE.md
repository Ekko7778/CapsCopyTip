# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Layout

This is the `main` branch, which contains only the AutoHotkey v2 desktop application. The product website lives in the separate `website` branch (commit `4784909` split them). If you need to edit the site, switch branches; do not add HTML/CSS/JS files here.

## Build & Run

Prerequisite: [AutoHotkey v2](https://www.autohotkey.com/) installed.

Run without compiling:

```bash
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" CursorTip.ahk
```

Compile to `CursorTip.exe` (release build):

```bash
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" \
  /in CursorTip.ahk \
  /out CursorTip.exe \
  /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

The script already contains `;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\app.ico`, so no `/icon` argument is needed.

There is no test suite or linter for the AHK code. Verification is manual: run the script, toggle CapsLock, copy text/files/images, and exercise the settings window.

## High-Level Architecture

`CursorTip.ahk` is intentionally a single-file application. All runtime logic lives in this file.

- **`Config` class** — Static configuration singleton. Holds defaults, reads from/writes to `A_ScriptDir\config.ini`. All settings flow through `Config.Load()` at startup and `Config.Save()` on change.
- **Tip window lifecycle** — `ShowTip()` creates or reuses a borderless `Gui` window. Fixed-width tips (CapsLock/IME) reuse the same window to avoid flicker; variable-width tips (copy feedback) recreate the window so `AutoSize` measures the new text correctly.
- **CapsLock + IME detection** — `CheckCapsLock()` polls every 50 ms. `GetIMEStatus()` first tries `imm32\ImmGetConversionStatus`; if that fails, it falls back to `ImmGetDefaultIMEWnd` + `SendMessage(0x283, 0x005, ...)`. Results are cached for 150 ms unless `forceRefresh` is requested.
- **Copy feedback** — `OnClipboardChange(ClipChanged)` inspects clipboard formats via `IsClipboardFormatAvailable`. It distinguishes files (`CF_HDROP = 15`), images (`CF_BITMAP`, `CF_DIB`, `CF_DIBV5`), and text.
- **Settings GUI** — `ShowSettings()` builds the window. `SettingsSave()` reads controls, validates bounds, calls `Config.Save()` and `ApplySettings()`, then destroys the window. `ApplyLanguage()` rebuilds the settings window in place when the language changes.
- **Startup toggle** — `SetStartup()` writes or deletes `HKCU\Software\Microsoft\Windows\CurrentVersion\Run\CursorTip`, pointing to `CursorTip.exe` in the script directory.

Important AutoHotkey v2 conventions used throughout:

- Functions are **assume-local** by default. Use `global var1, var2` when assigning to script-level globals.
- Class static properties (`Config.*`) are accessible everywhere without `global`.
- `Gui.OnEvent("Close", ...)` passes a `Gui`; `GuiCtrl.OnEvent("Click", ...)` passes a `GuiControl` with a `.Gui` property. `SettingsClose()` handles both.
- `IsObject(gui)` does **not** mean the window still exists; always pair it with `WinExist("ahk_id " . gui.Hwnd)`.

## Important Files

- `CursorTip.ahk` — entire AHK application.
- `config.ini` — user configuration, generated at runtime, ignored by git.
- `docs/ahk-v2-development-guide.md` — AHK v2 patterns and project-specific design notes. Some paths refer to an older refactor (`CapsCopyTip`, `lib/`); the current project is a single-file app, so treat those as pattern guidance rather than literal structure.

## Common Gotchas

- `work/` is a local scratch directory ignored by git.
- Compiled output `CursorTip.exe` and `dist/` are ignored.
- The project has no package manager, no tests, and no CI. Verification is manual.
- For the website branch, see its own `AGENTS.md`.
