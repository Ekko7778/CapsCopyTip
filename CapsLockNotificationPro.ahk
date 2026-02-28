; ============================================================
; CapsLockNotificationPro.ahk (AutoHotkey v2)
; 功能：大小写切换时显示提示（升级版）
; 特点：
;   - 显示图标（大写🔒 / 小写🔓）
;   - 提示位置在屏幕中央
;   - 同时显示输入法状态（中/英）
;   - 快速响应（30ms 检测）
; ============================================================

#SingleInstance Force
Persistent

; ============================================================
; 可配置参数
; ============================================================
global showDuration := 800      ; 提示显示时间（毫秒）
global checkInterval := 30      ; 检测间隔（毫秒），越小响应越快
global tipX := "Mouse"          ; 提示 X 位置："Mouse" 或具体数字
global tipY := "Mouse"          ; 提示 Y 位置："Mouse" 或具体数字

; ============================================================
; 内部状态
; ============================================================
global lastCapsState := GetKeyState("CapsLock", "T")
global lastImeState := ""

; 托盘提示
A_TrayTip := "大小写提示Pro"

; 定时器检查状态
SetTimer(CheckKeyboardState, checkInterval)

return

; ============================================================
; 检查键盘状态变化
; ============================================================
CheckKeyboardState() {
    global lastCapsState, lastImeState

    ; 获取当前状态
    currentCaps := GetKeyState("CapsLock", "T")
    currentIme := GetIMELanguage()

    ; 检测变化
    capsChanged := (currentCaps != lastCapsState)
    imeChanged := (currentIme != lastImeState)

    if (capsChanged || imeChanged) {
        lastCapsState := currentCaps
        lastImeState := currentIme

        ; 构建提示内容
        tip := ""

        ; 大小写状态
        if (currentCaps) {
            tip .= "🔒 大写"
        } else {
            tip .= "🔓 小写"
        }

        ; 输入法状态
        if (currentIme != "") {
            tip .= " | " . currentIme
        }

        ; 显示提示
        ShowTip(tip)
    }
}

; ============================================================
; 获取输入法语言
; ============================================================
GetIMELanguage() {
    try {
        ; 获取当前窗口的输入法状态
        hWnd := WinGetID("A")
        if (!hWnd)
            return ""

        ; 尝试获取输入法信息
        threadID := DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "Ptr", 0)
        hKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")

        ; 常见输入法 LANGID
        langID := hKL & 0xFFFF

        if (langID = 0x0804) {
            ; 中文输入法，进一步判断是否中文模式
            return "中"
        } else if (langID = 0x0409) {
            return "英"
        }
    }
    return ""
}

; ============================================================
; 显示提示（跟随鼠标）
; ============================================================
ShowTip(text) {
    global tipX, tipY, showDuration

    ; 获取鼠标位置
    MouseGetPos(&mouseX, &mouseY)

    ; 计算显示位置
    if (tipX = "Mouse") {
        x := mouseX + 10
    } else if (tipX = "Center") {
        x := A_ScreenWidth / 2 - 60
    } else {
        x := tipX
    }

    if (tipY = "Mouse") {
        y := mouseY + 10
    } else if (tipY = "Center") {
        y := A_ScreenHeight / 2 - 30
    } else {
        y := tipY
    }

    ; 显示提示
    ToolTip(text, x, y)

    ; 设置关闭定时器
    SetTimer(RemoveToolTip, showDuration)
}

RemoveToolTip() {
    ToolTip()
    SetTimer(RemoveToolTip, 0)
}
