; ============================================================
; AllInOneNotification.ahk (AutoHotkey v2)
; 功能：合并大小写提示 + 复制提示
; - 大小写/输入法：🔒 大写 | 中 / 🔓 小写 | 英
; - 复制提示：显示复制的字符数/图片/文件数
; - 右键托盘图标可打开设置
; ============================================================

#SingleInstance Force
Persistent

; ============================================================
; 全局设置
; ============================================================
global capsShowDuration := 800    ; 大小写提示显示时间
global copyShowDuration := 800    ; 复制提示显示时间
global lastCapsState := GetKeyState("CapsLock", "T")
global configPath := A_ScriptDir . "\config.ini"

A_TrayTip := "大小写+输入法+复制提示"

; ============================================================
; 托盘菜单设置
; ============================================================
; 删除默认菜单项
A_TrayMenu.Delete()

; 添加自定义菜单项
A_TrayMenu.Add("⚙ 设置", ShowSettings)
A_TrayMenu.Add()  ; 分隔线
A_TrayMenu.Add("🔄 重启", (*) => Reload())
A_TrayMenu.Add("❌ 退出", (*) => ExitApp())

; ============================================================
; 启动时加载配置
; ============================================================
LoadConfig()

; ============================================================
; 大小写监听
; ============================================================
SetTimer(CheckCapsLock, 30)

~Shift:: {
    KeyWait("Shift")
    ShowCapsStatus()
}

; ============================================================
; 复制监听
; ============================================================
OnClipboardChange(ClipChanged)

return

; ============================================================
; 配置管理
; ============================================================
LoadConfig() {
    global capsShowDuration, copyShowDuration, configPath

    ; 如果配置文件不存在，使用默认值
    if !FileExist(configPath)
        return

    try {
        capsShowDuration := IniRead(configPath, "Settings", "CapsShowDuration", 800)
        copyShowDuration := IniRead(configPath, "Settings", "CopyShowDuration", 800)
    } catch {
        ; 读取失败，使用默认值
    }
}

SaveConfig() {
    global capsShowDuration, copyShowDuration, configPath

    try {
        IniWrite(capsShowDuration, configPath, "Settings", "CapsShowDuration")
        IniWrite(copyShowDuration, configPath, "Settings", "CopyShowDuration")
    } catch as e {
        MsgBox("保存配置失败：" . e.Message, "错误", 16)
    }
}

; ============================================================
; 设置窗口
; ============================================================
ShowSettings(*) {
    global capsShowDuration, copyShowDuration

    ; 创建设置窗口
    settingsGui := Gui("+Owner", "设置")
    settingsGui.SetFont("s10", "Microsoft YaHei")

    ; 大小写提示时长
    settingsGui.Add("Text", "x20 y20 w200", "大小写提示显示时长 (毫秒):")
    capsEdit := settingsGui.Add("Edit", "x220 y17 w80", capsShowDuration)

    ; 复制提示时长
    settingsGui.Add("Text", "x20 y60 w200", "复制提示显示时长 (毫秒):")
    copyEdit := settingsGui.Add("Edit", "x220 y57 w80", copyShowDuration)

    ; 按钮
    settingsGui.Add("Button", "x80 y100 w80 Default", "保存").OnEvent("Click", SaveAndClose)
    settingsGui.Add("Button", "x180 y100 w80", "取消").OnEvent("Click", (*) => settingsGui.Destroy())

    ; 保存并关闭函数
    SaveAndClose(*) {
        global capsShowDuration, copyShowDuration

        ; 验证并保存，最小值 100ms
        capsShowDuration := Max(100, Integer(capsEdit.Value || 800))
        copyShowDuration := Max(100, Integer(copyEdit.Value || 800))

        SaveConfig()
        settingsGui.Destroy()

        ToolTip("设置已保存")
        SetTimer(() => ToolTip(), 1500)
    }

    settingsGui.Show("w320 h150")
}

; ============================================================
; CapsLock 状态检查
; ============================================================
CheckCapsLock() {
    global lastCapsState
    current := GetKeyState("CapsLock", "T")
    if (current != lastCapsState) {
        lastCapsState := current
        ShowCapsStatus()
    }
}

; ============================================================
; 显示大小写+输入法状态
; ============================================================
ShowCapsStatus() {
    global capsShowDuration

    ; 获取大小写状态
    caps := GetKeyState("CapsLock", "T")
    capsIcon := caps ? "🔒 大写" : "🔓 小写"

    ; 获取输入法状态
    ime := GetIMEStatus()

    ; 合并显示
    tip := capsIcon . " | " . ime

    MouseGetPos(&x, &y)
    ToolTip(tip, x + 10, y + 10)
    SetTimer(RemoveCapsTip, capsShowDuration)
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

    try hIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hWnd, "UInt")
    catch
        return "?"

    if (!hIMEWnd)
        return "?"

    DetectHiddenWindows(true)
    try {
        result := SendMessage(0x283, 0x005, 0, , "ahk_id " . hIMEWnd)
    } catch {
        DetectHiddenWindows(false)
        return "?"
    }
    DetectHiddenWindows(false)

    return (result = 1) ? "中" : "英"
}

; ============================================================
; 关闭大小写提示
; ============================================================
RemoveCapsTip() {
    ToolTip()
    SetTimer(RemoveCapsTip, 0)
}

; ============================================================
; 剪贴板变化回调函数 (AutoHotkey v2)
; dataType: 0=空, 1=文本或文件, 2=非文本(图片等)
; ============================================================
ClipChanged(dataType) {
    global copyShowDuration

    ; 剪贴板格式常量
    ; CF_BITMAP = 2, CF_DIB = 8, CF_DIBV5 = 17, CF_HDROP = 15
    isFile := DllCall("IsClipboardFormatAvailable", "UInt", 15)
    isImage := DllCall("IsClipboardFormatAvailable", "UInt", 2)
          || DllCall("IsClipboardFormatAvailable", "UInt", 8)
          || DllCall("IsClipboardFormatAvailable", "UInt", 17)

    if (isFile) {
        ; 复制的是文件
        files := StrSplit(A_Clipboard, "`n", "`r")
        count := files.Length
        ToolTip("已复制：" . count . " 个文件")
        SetTimer(RemoveCopyTip, copyShowDuration)
    }
    else if (isImage) {
        ; 复制的是图片
        ToolTip("已复制：图片")
        SetTimer(RemoveCopyTip, copyShowDuration)
    }
    else if (dataType = 1 || dataType = 2) {
        ; 复制的是文本 (dataType=2 可能是图片，但如果上面没检测到就当文本处理)
        text := A_Clipboard
        length := StrLen(text)
        if (length > 0) {
            ToolTip("已复制：" . length . " 字符")
            SetTimer(RemoveCopyTip, copyShowDuration)
        }
    }
}

; ============================================================
; 关闭复制提示
; ============================================================
RemoveCopyTip() {
    ToolTip()
    SetTimer(RemoveCopyTip, 0)
}
