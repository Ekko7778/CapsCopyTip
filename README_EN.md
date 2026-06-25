<div align="center">

<img src="assets/logo.png" alt="CursorTip" width="128" height="128">

# CursorTip

**A lightweight Windows desktop status indicator** · [Learn more](https://cursortip.pages.dev/)

Displays real-time caps lock + IME state and clipboard operation feedback on screen, helping you stay aware of your input environment.

[![Release](https://img.shields.io/github/v/release/zeno528/CursorTip?style=flat&logo=github&labelColor=1e293b&color=3b82f6)](https://github.com/zeno528/CursorTip/releases)
[![License](https://img.shields.io/github/license/zeno528/CursorTip?style=flat&labelColor=1e293b&color=3b82f6)](LICENSE)
[![Website](https://img.shields.io/badge/Website-cursortip.pages.dev-8b5cf6?style=flat&logo=cloudflare-pages&labelColor=1e293b)](https://cursortip.pages.dev/)
[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2-334455?style=flat&logo=autohotkey&labelColor=1e293b&color=4a5568)](https://www.autohotkey.com/)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=flat&logo=windows&labelColor=1e293b)](https://github.com/zeno528/CursorTip)

English | [简体中文](README.md)

</div>

## Screenshots

| Caps Lock + IME | Copy Feedback |
|:----------------:|:-------------:|
| ![](images/preview-caps-ime-light.png)![](images/preview-caps-ime-dark.png) | ![](images/preview-copy-tip-light.png)![](images/preview-copy-tip-dark.png) |

## Features

| Feature | Trigger | Display |
|:--------|:--------|:--------|
| Caps Lock state | CapsLock toggle / Shift release, independently displayed | 🔒 CAPS / 🔓 caps |
| IME state | Shown with caps lock indicator | ZH / EN |
| Copy feedback | Clipboard content changes | Copied: N char(s) / image / N file(s) |

Tips appear as floating bubbles on screen, can follow the mouse cursor, and auto-dismiss after a few seconds without interrupting your workflow.

## Copy Detection

| Copy Method | Detection Result |
|:------------|:-----------------|
| Text | N chars |
| Screenshot (Win+Shift+S) | Image |
| Paint / PS / WeChat copy image | Image |
| File Explorer copy files | N files |

## Installation

1. Download the latest `CursorTip_vX.X.X.zip` from [Releases](https://github.com/zeno528/CursorTip/releases)
2. Extract and run the exe, no need to install AutoHotkey

### Auto-start on Boot

Right-click the tray icon → Settings → Check "🚀 Run at startup", or place the exe in the startup folder (`Win+R` → `shell:startup`)

## Compilation

Requires [AutoHotkey v2](https://www.autohotkey.com/) and the Ahk2Exe compiler (bundled with the v2 installer).

```bash
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" \
  /in CursorTip.ahk \
  /out CursorTip.exe \
  /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

The script embeds the `;@Ahk2Exe-SetMainIcon` directive to set the icon, so no `/icon` parameter is needed.

## System Requirements

- Windows 10 / 11

## Project Structure

```
CursorTip/
├── CursorTip.ahk               # Main script (all development and bug fixes target this file)
├── LICENSE                     # MIT License
├── README.md / README_EN.md    # Chinese / English documentation
│
├── assets/                     # Icons and brand assets
├── images/                     # README preview images
└── docs/                       # AHK v2 development documentation
```

## License

[MIT](LICENSE)
