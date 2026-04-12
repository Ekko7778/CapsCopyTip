<div align="center">

<img src="assets/logo.png" alt="CursorTip" width="128" height="128">

# CursorTip

**A lightweight Windows desktop status indicator**

Displays real-time keyboard state and clipboard operation feedback on screen, helping you stay aware of your input environment.

[![Release](https://img.shields.io/github/v/release/zeno528/CursorTip?style=flat-square&logo=github)](https://github.com/zeno528/CursorTip/releases)
[![License](https://img.shields.io/github/license/zeno528/CursorTip?style=flat-square)](LICENSE)
[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2-334455?style=flat-square&logo=autohotkey)](https://www.autohotkey.com/)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=flat-square&logo=windows)](https://github.com/zeno528/CursorTip)

English | [简体中文](README.md)

</div>

## Features

| Feature | Trigger | Display |
|:--------|:--------|:--------|
| Caps Lock state | CapsLock toggle / Shift release | 🔒 Caps / 🔓 Lower |
| IME state | Shown with caps lock indicator | CN / EN |
| Copy feedback | Clipboard content changes | Copied: N chars / Image / N files |

Tips appear as floating bubbles on screen and auto-dismiss after a few seconds without interrupting your workflow.

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

Right-click the tray icon → Settings → Check "Auto-start", or place the exe in the startup folder (`Win+R` → `shell:startup`)

## Settings

Right-click the tray icon to open the settings window:

- Toggle features (Caps Lock indicator / IME display / Copy feedback)
- Display duration
- Tip position (Follow cursor / Screen center / Top / Bottom)
- Appearance (Dark / Light / Font size / Bold)

## Screenshots

| Caps Lock + IME | Copy Feedback | Settings |
|:----------------:|:-------------:|:--------:|
| ![](images/preview-caps-ime-light.png)![](images/preview-caps-ime-dark.png) | ![](images/preview-copy-tip-light.png)![](images/preview-copy-tip-dark.png) | ![](images/preview-settings.png) |

## System Requirements

- Windows 10 / 11
- No need to install AutoHotkey

## License

[MIT](LICENSE)
