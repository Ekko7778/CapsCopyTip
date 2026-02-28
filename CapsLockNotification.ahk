; ============================================================
; CapsLockNotification.ahk (AutoHotkey v2)
; 功能：大小写切换时显示提示
; 特点：快速响应，不拦截按键
; ============================================================

#SingleInstance Force
Persistent

; 托盘提示
A_TrayTip := "大小写提示已运行"

; 记录上一次状态
lastState := GetKeyState("CapsLock", "T")

; 定时器检查状态变化（每 50ms 检查一次，响应快）
SetTimer(CheckCapsLock, 50)

return

; ============================================================
; 检查 CapsLock 状态变化
; ============================================================
CheckCapsLock() {
    global lastState
    currentState := GetKeyState("CapsLock", "T")

    ; 状态变化时显示提示
    if (currentState != lastState) {
        lastState := currentState

        if (currentState) {
            ToolTip("大写开启")
        } else {
            ToolTip("小写")
        }

        ; 0.8秒后关闭提示
        SetTimer(RemoveToolTip, 800)
    }
}

RemoveToolTip() {
    ToolTip()
    SetTimer(RemoveToolTip, 0)
}
