; ============================================================
; CapsLockNotificationPro.ahk (AutoHotkey v2)
; 功能：大小写 + 输入法状态提示（合并显示）
; - 显示格式：🔒 大写 | 中 / 🔓 小写 | 英
; ============================================================

#SingleInstance Force
Persistent

global showDuration := 800
global lastCapsState := GetKeyState("CapsLock", "T")

A_TrayTip := "大小写+输入法提示"

; CapsLock 监听
SetTimer(CheckCapsLock, 30)

; Shift 监听
~Shift:: {
    KeyWait("Shift")
    ShowStatus()
}

return

; ============================================================
; CapsLock 状态检查
; ============================================================
CheckCapsLock() {
    global lastCapsState
    current := GetKeyState("CapsLock", "T")
    if (current != lastCapsState) {
        lastCapsState := current
        ShowStatus()
    }
}

; ============================================================
; 显示合并状态（大小写 + 中/英）
; ============================================================
ShowStatus() {
    global showDuration

    ; 获取大小写状态
    caps := GetKeyState("CapsLock", "T")
    capsIcon := caps ? "🔒 大写" : "🔓 小写"

    ; 获取输入法状态
    ime := GetIMEStatus()

    ; 合并显示
    tip := capsIcon . " | " . ime

    MouseGetPos(&x, &y)
    ToolTip(tip, x + 10, y + 10)
    SetTimer(RemoveTip, showDuration)
}

; ============================================================
; 获取输入法中/英状态
; ============================================================
GetIMEStatus() {
    try hWnd := WinExist("A")
    catch
        return "?"

    if (!hWnd)
        return "?"

    hIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hWnd, "UInt")

    if (!hIMEWnd)
        return "?"

    DetectHiddenWindows(true)
    result := SendMessage(0x283, 0x005, 0, , "ahk_id " . hIMEWnd)
    DetectHiddenWindows(false)

    return (result = 1) ? "中" : "英"
}

; ============================================================
; 关闭提示
; ============================================================
RemoveTip() {
    ToolTip()
    SetTimer(RemoveTip, 0)
}
