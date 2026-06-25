; ============================================================
; CursorTip (AutoHotkey v2)
; 功能：大小写提示 + 复制提示
; - 大小写/输入法：🔒 大写 | 中 / 🔓 小写 | 英
; - 复制提示：显示复制的字符数/图片/文件数
; - 右键托盘图标可打开设置
; ============================================================

;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\app.ico

#SingleInstance Force
Persistent
A_HotkeyInterval := 0  ; 禁用热键频率限制警告（按住 Ctrl/Win 等修饰键会因 auto-repeat 触发，如微信语音输入按住说话）

; ============================================================
; 版本
; ============================================================
global VERSION := "1.0.2"

; ============================================================
; 配置管理类 — 统一管理所有配置项
; ============================================================
class Config {
    static Path := A_ScriptDir . "\config.ini"

    ; 默认值（唯一维护处）
    static Defaults := {
        enableCapsTip: true,
        enableCopyTip: true,
        showIMEStatus: true,
        capsShowDuration: 800,
        copyShowDuration: 800,
        tipPosition: 1,          ; 1=跟随鼠标 2=屏幕中央 3=屏幕顶部 4=屏幕底部
        tipMouseOffset: 20,
        tipTopOffset: 50,
        tipBottomOffset: 100,
        tipFontSize: 9,
        tipFontBold: true,
        tipLightMode: true,
        language: "auto"
    }

    ; 每个配置项声明为独立的静态属性（带默认值）
    static enableCapsTip := true
    static enableCopyTip := true
    static showIMEStatus := true
    static capsShowDuration := 800
    static copyShowDuration := 800
    static tipPosition := 1
    static tipMouseOffset := 20
    static tipTopOffset := 50
    static tipBottomOffset := 100
    static tipFontSize := 9
    static tipFontBold := true
    static tipLightMode := true
    static language := "auto"

    ; 加载配置
    static Load() {
        if !FileExist(Config.Path)
            return

        try {
            c := Config
            c.enableCapsTip := IniRead(Config.Path, "Settings", "EnableCapsTip", 1) = 1
            c.enableCopyTip := IniRead(Config.Path, "Settings", "EnableCopyTip", 1) = 1
            c.showIMEStatus := IniRead(Config.Path, "Settings", "ShowIMEStatus", 1) = 1

            c.capsShowDuration := Integer(IniRead(Config.Path, "Settings", "CapsShowDuration", 800))
            c.copyShowDuration := Integer(IniRead(Config.Path, "Settings", "CopyShowDuration", 800))

            c.tipPosition := Integer(IniRead(Config.Path, "Settings", "TipPosition", 1))
            c.tipMouseOffset := Integer(IniRead(Config.Path, "Settings", "TipMouseOffset", 20))
            c.tipTopOffset := Integer(IniRead(Config.Path, "Settings", "TipTopOffset", 50))
            c.tipBottomOffset := Integer(IniRead(Config.Path, "Settings", "TipBottomOffset", 100))

            c.tipFontSize := Integer(IniRead(Config.Path, "Settings", "TipFontSize", 9))
            c.tipFontBold := IniRead(Config.Path, "Settings", "TipFontBold", 1) = 1
            c.tipLightMode := IniRead(Config.Path, "Settings", "TipLightMode", 0) = 1
            c.language := IniRead(Config.Path, "Settings", "Language", "auto")
        } catch {
            ; 读取失败，使用默认值
        }
    }

    ; 保存配置
    static Save() {
        try {
            c := Config
            IniWrite(c.enableCapsTip ? 1 : 0, Config.Path, "Settings", "EnableCapsTip")
            IniWrite(c.enableCopyTip ? 1 : 0, Config.Path, "Settings", "EnableCopyTip")
            IniWrite(c.showIMEStatus ? 1 : 0, Config.Path, "Settings", "ShowIMEStatus")

            IniWrite(c.capsShowDuration, Config.Path, "Settings", "CapsShowDuration")
            IniWrite(c.copyShowDuration, Config.Path, "Settings", "CopyShowDuration")

            IniWrite(c.tipPosition, Config.Path, "Settings", "TipPosition")
            IniWrite(c.tipMouseOffset, Config.Path, "Settings", "TipMouseOffset")
            IniWrite(c.tipTopOffset, Config.Path, "Settings", "TipTopOffset")
            IniWrite(c.tipBottomOffset, Config.Path, "Settings", "TipBottomOffset")

            IniWrite(c.tipFontSize, Config.Path, "Settings", "TipFontSize")
            IniWrite(c.tipFontBold ? 1 : 0, Config.Path, "Settings", "TipFontBold")
            IniWrite(c.tipLightMode ? 1 : 0, Config.Path, "Settings", "TipLightMode")
            IniWrite(c.language, Config.Path, "Settings", "Language")
        } catch as e {
            MsgBox(T("err_save_config") . e.Message, T("err_title"), 16)
        }
    }

    ; 恢复默认值
    static Reset() {
        for k, v in Config.Defaults.OwnProps()
            Config.%k% := v
    }
}

; ============================================================
; 多语言（i18n）— 字符串表 + 取值
; ============================================================
global L := Map(
    "zh", Map(
        "tray_settings", "⚙ 设置",
        "tray_reload", "🔄 重启",
        "tray_exit", "❌ 退出",
        "caps_on", "🔒 大写",
        "caps_off", "🔓 小写",
        "ime_zh", "中",
        "ime_en", "英",
        "copy_files", "已复制：{n} 个文件",
        "copy_image", "已复制：图片",
        "copy_chars", "已复制：{n} 字符",
        "set_features", "功能开关",
        "set_startup", "🚀 开机启动",
        "set_caps", "🔠 大小写提示",
        "set_ime", "🌐 显示中/英状态",
        "set_copy", "📋 复制提示",
        "set_duration", "显示时长",
        "set_caps_label", "大小写提示:",
        "set_copy_label", "复制提示:",
        "set_position", "提示位置",
        "pos_mouse", "跟随鼠标",
        "pos_center", "屏幕中央",
        "pos_top", "屏幕顶部",
        "pos_bottom", "屏幕底部",
        "set_offset", "偏移:",
        "set_appearance", "外观样式",
        "app_light", "浅色模式",
        "app_dark", "深色模式",
        "set_fontsize", "字号:",
        "set_bold", "加粗",
        "set_language", "语言",
        "lang_auto", "自动",
        "lang_zh", "中文",
        "lang_en", "English",
        "btn_reset", "恢复默认",
        "btn_save", "保存",
        "btn_cancel", "取消",
        "msg_saved", "设置已保存",
        "err_save_config", "保存配置失败：",
        "err_set_startup", "设置开机启动失败：",
        "link_about", "关于",
        "err_title", "错误"
    ),
    "en", Map(
        "tray_settings", "⚙ Settings",
        "tray_reload", "🔄 Reload",
        "tray_exit", "❌ Exit",
        "caps_on", "🔒 CAPS",
        "caps_off", "🔓 caps",
        "ime_zh", "ZH",
        "ime_en", "EN",
        "copy_files", "Copied: {n} file(s)",
        "copy_image", "Copied: image",
        "copy_chars", "Copied: {n} char(s)",
        "set_features", "Features",
        "set_startup", "🚀 Run at startup",
        "set_caps", "🔠 CapsLock tip",
        "set_ime", "🌐 Show IME",
        "set_copy", "📋 Copy tip",
        "set_duration", "Duration",
        "set_caps_label", "CapsLock tip:",
        "set_copy_label", "Copy tip:",
        "set_position", "Position",
        "pos_mouse", "Follow mouse",
        "pos_center", "Screen center",
        "pos_top", "Top",
        "pos_bottom", "Bottom",
        "set_offset", "Offset:",
        "set_appearance", "Appearance",
        "app_light", "Light",
        "app_dark", "Dark",
        "set_fontsize", "Font size:",
        "set_bold", "Bold",
        "set_language", "Language",
        "lang_auto", "Auto",
        "lang_zh", "中文",
        "lang_en", "English",
        "btn_reset", "Reset",
        "btn_save", "Save",
        "btn_cancel", "Cancel",
        "msg_saved", "Settings saved",
        "err_save_config", "Failed to save config: ",
        "err_set_startup", "Failed to set startup: ",
        "link_about", "About",
        "err_title", "Error"
    )
)

global curLang := "zh"  ; 启动时按 Config.language 重算

; 取字符串：T("key") 或 T("key", n)（{n} 占位符替换）；key 缺失返回 [key] 占位，不崩
T(key, n := "") {
    global L, curLang
    if !L.Has(curLang) || !L[curLang].Has(key)
        return "[" . key . "]"
    s := L[curLang][key]
    if (n != "")
        s := StrReplace(s, "{n}", n)
    return s
}

; 按 A_Language（4 位 LCID）主语言码判断：04=中文，其余默认英文
DetectLang() {
    pri := SubStr(A_Language, 3, 2)
    if (pri = "04")
        return "zh"
    return "en"
}

; ============================================================
; 全局状态
; ============================================================
global lastCapsState := GetKeyState("CapsLock", "T")
global lastCapsChangeTime := 0
global clipboardProcessing := false
global shiftAlone := false
global tipGui := ""
global tipGuiText := ""
global settingsGui := ""
global settingsOpenPos := ""  ; 切语言重建时记忆窗口位置，避免销毁→重建空帧（灰线）
global tipFixedWidth := 0  ; Caps/IME 提示固定宽度（按英文最宽文本测量，0=未测）
global tipGuiIsFixed := false  ; 当前 tipGui 是否固定宽度模式（决定能否复用窗口避免闪烁）


; ============================================================
; 托盘菜单
; ============================================================
A_TrayTip := "CursorTip v" . VERSION

; 构建托盘菜单（语言切换后重复调用以刷新文字）
BuildTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add(T("tray_settings"), ShowSettings)
    A_TrayMenu.Add()
    A_TrayMenu.Add(T("tray_reload"), (*) => Reload())
    A_TrayMenu.Add(T("tray_exit"), (*) => ExitApp())
}

; 单击托盘图标打开设置
OnMessage(0x404, TrayClickHandler)

TrayClickHandler(wParam, lParam, msg, hwnd) {
    if (lParam = 0x201 || lParam = 0x203) {  ; 左键单击或双击
        ShowSettings()
        return 0
    }
    ; 右键等其他消息不拦截，交给 AHK 默认处理（弹出菜单）
}

OnExit(OnScriptExit)

; ============================================================
; 启动
; ============================================================
Config.Load()
curLang := (Config.language = "auto") ? DetectLang() : Config.language
BuildTrayMenu()
InitMonitors()
MeasureTipFixedWidth()

return ; 自动执行段结束

; ============================================================
; 退出清理
; ============================================================
OnScriptExit(exitReason, exitCode) {
    global tipGui, settingsGui
    SetTimer(CheckCapsLock, 0)
    SetTimer(HideTip, 0)

    if (IsObject(tipGui)) {
        tipGui.Destroy()
        tipGui := ""
    }
    if (IsObject(settingsGui)) {
        settingsGui.Destroy()
        settingsGui := ""
    }
}

; ============================================================
; 注册/取消监听
; ============================================================
InitMonitors() {
    c := Config

    ; 大小写监听
    if (c.enableCapsTip)
        SetTimer(CheckCapsLock, 50)

    ; 复制监听
    if (c.enableCopyTip)
        OnClipboardChange(ClipChanged)
}

ApplySettings() {
    global tipGui, tipGuiText
    c := Config

    ; 大小写监听
    SetTimer(CheckCapsLock, 0)
    if (c.enableCapsTip)
        SetTimer(CheckCapsLock, 50)

    ; 复制监听
    OnClipboardChange(ClipChanged, 0)
    if (c.enableCopyTip)
        OnClipboardChange(ClipChanged)

    ; 销毁提示窗口以应用新外观
    if (IsObject(tipGui)) {
        tipGui.Destroy()
        tipGui := ""
        tipGuiText := ""
    }

    ; 字号/主题/语言可能变化，重测固定宽度
    MeasureTipFixedWidth()
}

; ============================================================
; 开机启动管理
; ============================================================
IsStartupEnabled() {
    exePath := A_IsCompiled ? A_ScriptFullPath : A_ScriptDir . "\CursorTip.exe"
    try {
        regValue := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "CursorTip", "")
        return InStr(regValue, exePath) > 0
    } catch {
        return false
    }
}

SetStartup(enable) {
    exePath := A_IsCompiled ? A_ScriptFullPath : A_ScriptDir . "\CursorTip.exe"
    if (enable) {
        try {
            RegWrite(exePath, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "CursorTip")
        } catch as e {
            MsgBox(T("err_set_startup") . e.Message, T("err_title"), 16)
        }
    } else {
        try {
            RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "CursorTip")
        } catch {
        }
    }
}

; ============================================================
; 提示窗口管理
; ============================================================
; 测量英文模式下最宽 Caps/IME 提示（🔒 CAPS | ZH）的控件宽度，作为 Caps 提示固定宽度基准
; 字号/主题/语言变化后在 ApplySettings 里重测
MeasureTipFixedWidth() {
    global tipFixedWidth
    c := Config
    g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20", "")
    g.SetFont("s" . c.tipFontSize . (c.tipFontBold ? " Bold" : ""), "Microsoft YaHei")
    t := g.Add("Text", "Center r1", L["en"]["caps_on"] . " | " . L["en"]["ime_zh"])
    g.Show("Hide AutoSize")
    t.GetPos(,, &tw, &th)
    g.Destroy()
    tipFixedWidth := tw
}

; 按 tipPosition 把 tipGui 定位显示（gw/gh 为当前窗口尺寸）；NA=不抢焦点
ShowTipAt(gw, gh) {
    global tipGui
    c := Config
    switch c.tipPosition {
        case 1:
            CoordMode "Mouse", "Screen"
            MouseGetPos(&mx, &my)
            tipGui.Show("x" . (mx + c.tipMouseOffset) . " y" . (my + c.tipMouseOffset) . " NA")
        case 2:
            tipGui.Show("x" . (A_ScreenWidth - gw) / 2 . " y" . (A_ScreenHeight - gh) / 2 . " NA")
        case 3:
            tipGui.Show("x" . (A_ScreenWidth - gw) / 2 . " y" . c.tipTopOffset . " NA")
        case 4:
            tipGui.Show("x" . (A_ScreenWidth - gw) / 2 . " y" . (A_ScreenHeight - gh - c.tipBottomOffset) . " NA")
    }
}

ShowTip(text, duration := 0, fixedWidth := false) {
    global tipGui, tipGuiText, tipFixedWidth, tipGuiIsFixed
    c := Config

    ; 涉及窗口句柄和定时器，防止 timer/热键重入导致状态错乱
    Critical
    try {
        winValid := IsObject(tipGui) ? DllCall("IsWindow", "Ptr", tipGui.Hwnd) : 0

        ; 仅固定宽度模式（Caps/IME 提示）复用窗口：控件宽度恒定，只改 .Value 即可，
        ; 无需 Destroy/Create，杜绝切换时的空帧闪烁。
        ; 自适应宽度（复制提示）宽度随文本变化，必须销毁重建才能正确量宽，不复用。
        ; （历史复用 bug 全源于「要重算宽度」：中文截断 / 控件堆叠变高 / 重绘残影——
        ;   固定宽度下不重算，这些坑不存在。）
        if (fixedWidth && tipGuiIsFixed && winValid && IsObject(tipGuiText)) {
            tipGuiText.Value := text
            tipGui.GetPos(,, &gw, &gh)
            ShowTipAt(gw, gh)
        } else {
            ; 宽度模式变化或窗口无效：销毁重建，AutoSize 全新计算尺寸
            if (IsObject(tipGui)) {
                try tipGui.Destroy()
                tipGui := ""
                tipGuiText := ""
            }

            tipGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20", "")
            if (c.tipLightMode) {
                tipGui.BackColor := "F5F5F5"
                textColor := "333333"
            } else {
                tipGui.BackColor := "333333"
                textColor := "FFFFFF"
            }
            tipGui.SetFont("s" . c.tipFontSize . (c.tipFontBold ? " Bold" : ""), "Microsoft YaHei")
            textOpts := "c" . textColor . " Center r1"
            if (fixedWidth && tipFixedWidth > 0)
                textOpts := "w" . tipFixedWidth . " " . textOpts
            tipGuiText := tipGui.Add("Text", textOpts, text)

            ; Windows 11 圆角
            try {
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", tipGui.Hwnd, "Int", 33, "Int*", 2, "Int", 4)
            }

            ; 先在隐藏状态下 AutoSize 取尺寸，再一次性定位显示
            tipGui.Show("Hide AutoSize")
            tipGui.GetPos(,, &gw, &gh)
            ShowTipAt(gw, gh)
            tipGuiIsFixed := fixedWidth
        }

        ; 自动关闭
        if (duration > 0) {
            SetTimer(HideTip, 0)
            SetTimer(HideTip, -duration)
        }
    } finally {
        Critical "Off"
    }
}

HideTip() {
    global tipGui

    ; HideTip 也操作 tipGui，避免被 ShowTip 重入导致隐藏错窗口
    Critical
    try {
        if (IsObject(tipGui) && DllCall("IsWindow", "Ptr", tipGui.Hwnd)) {
            tipGui.Hide()
        }
        SetTimer(HideTip, 0)
    } finally {
        Critical "Off"
    }
}

; ============================================================
; 输入法检测 — 统一使用 ImmGetConversionStatus
; ============================================================
GetIMEStatus(forceRefresh := false) {
    static lastResult := "英"
    static lastCheckTime := 0
    static lastWindowHash := 0

    ; 防抖：150ms 内且同一窗口直接返回上次结果
    if (!forceRefresh) {
        if (A_TickCount - lastCheckTime < 150)
            return lastResult
        hWnd := WinExist("A")
        if (hWnd && hWnd = lastWindowHash)
            return lastResult
    }

    result := ""
    method := ""
    hWnd := 0

    try {
        hWnd := WinExist("A")
        if (!hWnd)
            throw Error()

        ; 方法1: ImmGetConversionStatus（最可靠，标准 IME 接口）
        result := DetectIMEViaConversionStatus(hWnd)
        method := "Conversion"

        ; 方法2: 回退到 ImmGetDefaultIMEWnd + SendMessage
        if (result = "") {
            result := DetectIMEViaMessage(hWnd)
            method := "Message"
        }
    } catch as e {
    }

    if (result != "") {
        lastResult := result
        lastWindowHash := WinExist("A")
    }

    lastCheckTime := A_TickCount
    return lastResult
}

; 通过 ImmGetConversionStatus 检测（标准 API，兼容所有输入法）
DetectIMEViaConversionStatus(hWnd) {
    hIMC := DllCall("imm32\ImmGetContext", "Ptr", hWnd, "UPtr")
    if (!hIMC)
        return ""

    try {
        DllCall("imm32\ImmGetConversionStatus", "Ptr", hIMC, "UInt*", &fdwConversion := 0, "UInt*", &fdwSentence := 0, "Int")
        DllCall("imm32\ImmReleaseContext", "Ptr", hWnd, "UPtr", hIMC)
        return (fdwConversion & 0x0001) ? "中" : "英"
    } catch {
        DllCall("imm32\ImmReleaseContext", "Ptr", hWnd, "UPtr", hIMC)
        return ""
    }
}

; 通过 IMM32 窗口消息检测（回退方案）
; 使用 IMC_GETOPENSTATUS (0x005)：返回 1 = IME 打开 = 中文模式
DetectIMEViaMessage(hWnd) {
    saved := A_DetectHiddenWindows
    try {
        DetectHiddenWindows(true)
        hIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "UInt", hWnd, "UInt")
        if (hIMEWnd) {
            result := SendMessage(0x283, 0x005, 0, , "ahk_id " . hIMEWnd)
            DetectHiddenWindows(saved)
            return result ? "中" : "英"
        }
        DetectHiddenWindows(saved)
    } catch {
        DetectHiddenWindows(saved)
    }
    return ""
}

; ============================================================
; 大小写监听
; ============================================================
CheckCapsLock() {
    global lastCapsState, lastCapsChangeTime
    if (!Config.enableCapsTip)
        return

    current := GetKeyState("CapsLock", "T")
    if (current != lastCapsState) {
        lastCapsState := current
        lastCapsChangeTime := A_TickCount
        ShowCapsStatus()
    }
}

ShowCapsStatus(forceRefreshIME := false) {
    if (!Config.enableCapsTip)
        return

    caps := GetKeyState("CapsLock", "T")
    capsIcon := caps ? T("caps_on") : T("caps_off")

    if (Config.showIMEStatus) {
        ime := GetIMEStatus(forceRefreshIME)
        if (ime = "")
            ime := "中"  ; 检测失败时默认中文（内部常量，不译）
        imeDisplay := (ime = "中") ? T("ime_zh") : T("ime_en")
        tip := capsIcon . " | " . imeDisplay
    } else {
        tip := capsIcon
    }

    ShowTip(tip, Config.capsShowDuration, true)
}

; Shift 独立按下检测：只有单独按下并释放 Shift 才触发
~*LShift::
~*RShift:: {
    global shiftAlone
    ; 按下 Shift 时已有其他修饰键按住 → 组合键
    if (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        shiftAlone := false
    else
        shiftAlone := true
}

~*LShift up::
~*RShift up:: {
    global lastCapsChangeTime, shiftAlone
    if (!Config.enableCapsTip)
        return

    ; 如果 Shift 不是独立按下（有其他键同时被按），不触发
    if (!shiftAlone)
        return

    ; 释放时仍有其他修饰键按住 → 组合键，不触发
    if (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        return

    ; 释放时仍有鼠标键按住 → 组合键，不触发
    if (GetKeyState("LButton", "P") || GetKeyState("RButton", "P") || GetKeyState("MButton", "P"))
        return

    ; 防抖
    if (A_TickCount - lastCapsChangeTime < 80)
        return

    Sleep(30)
    ShowCapsStatus(true)
}

; 任意其他键按下 → 标记 Shift 不是独立按下
~*a::
~*b::
~*c::
~*d::
~*e::
~*f::
~*g::
~*h::
~*i::
~*j::
~*k::
~*l::
~*m::
~*n::
~*o::
~*p::
~*q::
~*r::
~*s::
~*t::
~*u::
~*v::
~*w::
~*x::
~*y::
~*z::
~*0::
~*1::
~*2::
~*3::
~*4::
~*5::
~*6::
~*7::
~*8::
~*9::
~*Space::
~*Enter::
~*Tab::
~*Backspace::
~*Esc::
~*F1::
~*F2::
~*F3::
~*F4::
~*F5::
~*F6::
~*F7::
~*F8::
~*F9::
~*F10::
~*F11::
~*F12::
~*Up::
~*Down::
~*Left::
~*Right::
~*Home::
~*End::
~*PgUp::
~*PgDn::
~*Insert::
~*Delete::
~*PrintScreen::
~*ScrollLock::
~*Pause::
~*Numpad0::
~*Numpad1::
~*Numpad2::
~*Numpad3::
~*Numpad4::
~*Numpad5::
~*Numpad6::
~*Numpad7::
~*Numpad8::
~*Numpad9::
~*NumpadMult::
~*NumpadAdd::
~*NumpadSub::
~*NumpadDiv::
~*NumpadEnter::
~*NumpadDot::
~*`::
~*-::
~*=::
~*[::
~*]::
~*\::
~*;::
~*'::
~*,::
~*.::
~*/::
~*LCtrl::
~*RCtrl::
~*LAlt::
~*RAlt::
~*LWin::
~*RWin::
~*LButton up::
~*RButton up::
~*MButton up:: {
    global shiftAlone := false
}

; ============================================================
; 剪贴板监听
; ============================================================
ClipChanged(dataType) {
    global clipboardProcessing
    if (!Config.enableCopyTip || clipboardProcessing)
        return

    ; 只响应文本和剪贴板更新事件，忽略其他格式避免同一次复制触发多次
    if (dataType != 1 && dataType != 2)
        return

    clipboardProcessing := true

    try {
        ; 等待剪贴板可用，避免其他程序占用导致读取失败
        Sleep(50)

        isFile := DllCall("IsClipboardFormatAvailable", "UInt", 15)
        isImage := DllCall("IsClipboardFormatAvailable", "UInt", 2)
              || DllCall("IsClipboardFormatAvailable", "UInt", 8)
              || DllCall("IsClipboardFormatAvailable", "UInt", 17)

        if (isFile) {
            clipText := A_Clipboard
            files := StrSplit(clipText, "`n", "`r")
            count := files.Length
            if (count > 0 && files[1] != "")
                ShowTip(T("copy_files", count), Config.copyShowDuration)
        } else if (isImage) {
            ShowTip(T("copy_image"), Config.copyShowDuration)
        } else {
            clipText := A_Clipboard
            length := StrLen(clipText)
            if (length > 0)
                ShowTip(T("copy_chars", length), Config.copyShowDuration)
        }
    } catch {
        ; 剪贴板被占用，静默忽略
    } finally {
        clipboardProcessing := false
    }
}

; ============================================================
; 设置窗口
; ============================================================
ShowSettings(*) {
    global settingsGui, settingsOpenPos
    ; 防止多开
    if (IsObject(settingsGui)) {
        try {
            if (WinExist("ahk_id " . settingsGui.Hwnd)) {
                WinActivate("ahk_id " . settingsGui.Hwnd)
                return
            }
        } catch {
            settingsGui := ""
        }
    }

    c := Config
    g := Gui(, "CursorTip v" . VERSION)
    g.SetFont("s10", "Microsoft YaHei")

    ; === 功能开关 ===
    g.SetFont("Bold")
    g.Add("Text", "x20 y10", T("set_features"))
    g.SetFont("Norm")

    g.ctl_startup := g.Add("CheckBox", "x20 y32 w150", T("set_startup"))
    g.ctl_startup.Value := IsStartupEnabled()

    g.ctl_caps := g.Add("CheckBox", "x20 y57 w130", T("set_caps"))
    g.ctl_caps.Value := c.enableCapsTip
    g.ctl_ime := g.Add("CheckBox", "x200 y57 w140", T("set_ime"))
    g.ctl_ime.Value := c.showIMEStatus
    g.ctl_ime.Enabled := c.enableCapsTip

    g.ctl_copy := g.Add("CheckBox", "x20 y82 w130", T("set_copy"))
    g.ctl_copy.Value := c.enableCopyTip

    g.ctl_caps.OnEvent("Click", (ctrl, *) => ctrl.Gui.ctl_ime.Enabled := ctrl.Value)

    ; 分割线
    g.Add("Text", "x10 y110 w320 h1 BackgroundDDDDDD")

    ; === 显示时长 ===
    g.SetFont("Bold")
    g.Add("Text", "x20 y122", T("set_duration"))
    g.SetFont("Norm")

    g.Add("Text", "x20 y147 w110", T("set_caps_label"))
    g.ctl_capsDur := g.Add("Edit", "x200 y144 w60 h22 Number", c.capsShowDuration)
    g.Add("Text", "x265 y147", "ms")
    g.Add("Text", "x20 y177 w110", T("set_copy_label"))
    g.ctl_copyDur := g.Add("Edit", "x200 y174 w60 h22 Number", c.copyShowDuration)
    g.Add("Text", "x265 y177", "ms")

    g.Add("Text", "x10 y202 w320 h1 BackgroundDDDDDD")

    ; === 提示位置 ===
    g.SetFont("Bold")
    g.Add("Text", "x20 y214", T("set_position"))
    g.SetFont("Norm")

    ; Radio 显示顺序: 跟随鼠标 / 屏幕顶部 / 屏幕底部 / 屏幕中央（中央用得少，放最后）
    ; tipPosition 值的含义保持不变（1=鼠标, 2=中央, 3=顶部, 4=底部），仅 Radio 显示顺序与控件->值映射调整
    g.ctl_pos1 := g.Add("Radio", "x20 y239 w120 +Group" . (c.tipPosition = 1 ? " Checked" : ""), T("pos_mouse"))
    g.ctl_pos2 := g.Add("Radio", "x20 y266 w100" . (c.tipPosition = 3 ? " Checked" : ""), T("pos_top"))
    g.ctl_pos3 := g.Add("Radio", "x20 y293 w100" . (c.tipPosition = 4 ? " Checked" : ""), T("pos_bottom"))
    g.ctl_pos4 := g.Add("Radio", "x20 y320 w140" . (c.tipPosition = 2 ? " Checked" : ""), T("pos_center"))
    ; 偏移量紧跟 Radio 文字，Radio 最长到 x140（英文"Follow mouse"）
    g.Add("Text", "x190 y242 w40 Right", T("set_offset"))
    g.ctl_mouseOffset := g.Add("Edit", "x235 y239 w35 h22 Number", c.tipMouseOffset)
    g.Add("Text", "x275 y242", "px")
    g.Add("Text", "x190 y269 w40 Right", T("set_offset"))
    g.ctl_topOffset := g.Add("Edit", "x235 y266 w35 h22 Number", c.tipTopOffset)
    g.Add("Text", "x275 y269", "px")
    g.Add("Text", "x190 y296 w40 Right", T("set_offset"))
    g.ctl_bottomOffset := g.Add("Edit", "x235 y293 w35 h22 Number", c.tipBottomOffset)
    g.Add("Text", "x275 y296", "px")

    g.Add("Text", "x10 y350 w320 h1 BackgroundDDDDDD")

    ; === 外观样式 ===
    g.SetFont("Bold")
    g.Add("Text", "x20 y362", T("set_appearance"))
    g.SetFont("Norm")

    g.ctl_lightMode := g.Add("Radio", "x20 y387 w100 +Group" . (c.tipLightMode ? " Checked" : ""), T("app_light"))
    g.ctl_darkMode := g.Add("Radio", "x200 y387 w100" . (!c.tipLightMode ? " Checked" : ""), T("app_dark"))
    g.Add("Text", "x20 y417 w70", T("set_fontsize"))
    g.ctl_fontSize := g.Add("Edit", "x95 y414 w40 h22 Number", c.tipFontSize)
    g.ctl_bold := g.Add("CheckBox", "x200 y417 w60", T("set_bold"))
    g.ctl_bold.Value := c.tipFontBold

    ; === 语言 ===
    g.Add("Text", "x20 y447 w80", T("set_language"))
    langIdx := Map("auto",1,"zh",2,"en",3)[Config.language]
    g.ctl_lang := g.Add("DDL", "x200 y444 w120 AltSubmit Choose" . langIdx, [T("lang_auto"), T("lang_zh"), T("lang_en")])
    g.ctl_lang.OnEvent("Change", OnLangChange)

    g.Add("Text", "x10 y475 w320 h1 BackgroundDDDDDD")

    ; === 按钮 ===
    g.Add("Button", "x20 y490 w80", T("btn_reset")).OnEvent("Click", SettingsReset)
    g.Add("Button", "x130 y490 w80", T("btn_cancel")).OnEvent("Click", SettingsClose)
    g.Add("Button", "x240 y490 w80 Default", T("btn_save")).OnEvent("Click", SettingsSave)
    g.OnEvent("Close", SettingsClose)

    ; 底部信息
    icoPath := A_Temp . "\CursorTip_github.ico"
    FileInstall("assets\github.ico", icoPath, 1)
    g.Add("Picture", "x20 y530 w16 h16", icoPath).OnEvent("Click", (*) => Run("https://cursortip.pages.dev/"))
    g.SetFont("s8", "Microsoft YaHei")
    g.Add("Link", "x40 y532", '<a href="https://cursortip.pages.dev/">' . T("link_about") . '</a>')
    g.Add("Text", "x200 y532", "© 2026  MIT License")

    ; 有记忆位置就在原位显示（切语言重建时新窗口完整覆盖旧窗口，消除空帧/灰线）
    showOpts := "w340 h560"
    if (settingsOpenPos != "")
        showOpts .= " x" . settingsOpenPos[1] . " y" . settingsOpenPos[2]
    ; 禁用 DWM 窗口过渡动画（DWMWA_TRANSITIONS_FORCEDISABLED=3）：新窗口瞬间不透明显示，
    ; 避免淡入期间底下旧窗口的文字透过来形成一瞬间残影
    try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", g.Hwnd, "Int", 3, "Int*", 1, "Int", 4)
    g.Show(showOpts)
    settingsGui := g
}

; 切换语言：保存配置并即时刷新托盘菜单 + 重建设置窗口
OnLangChange(ctl, *) {
    Config.language := ["auto", "zh", "en"][ctl.Value]
    Config.Save()
    ApplyLanguage()
}

; 应用当前 Config.language：更新 curLang、重建托盘、重开设置窗口
ApplyLanguage() {
    global curLang, settingsGui, settingsOpenPos
    curLang := (Config.language = "auto") ? DetectLang() : Config.language
    BuildTrayMenu()
    if (IsObject(settingsGui)) {
        oldGui := settingsGui
        ; 记录旧窗口位置：新窗口在同位置覆盖显示后再销毁旧窗口，
        ; 消除「销毁→重建」之间的空帧（即切语言时中间那条灰线）
        try {
            if (WinExist("ahk_id " . oldGui.Hwnd))
                oldGui.GetPos(&px, &py), settingsOpenPos := [px, py]
        } catch {
        }
        settingsGui := ""   ; 让 ShowSettings 的防多开逻辑放行，能创建新窗口
        ShowSettings()      ; 新窗口在旧位置显示，完整覆盖旧窗口
        if (IsObject(oldGui))
            oldGui.Destroy()   ; 旧窗口已被新窗口遮挡，销毁无视觉中断
    } else {
        ShowSettings()
    }
}

SettingsClose(ctrlOrGui, *) {
    global settingsGui
    ; Close 事件传入 Gui 对象，按钮点击传入 GuiControl（有 .Gui 属性）
    g := ctrlOrGui.HasProp("Gui") ? ctrlOrGui.Gui : ctrlOrGui
    g.Destroy()
    settingsGui := ""
}

SettingsReset(ctrl, *) {
    d := Config.Defaults
    g := ctrl.Gui

    g.ctl_startup.Value := false
    g.ctl_caps.Value := d.enableCapsTip
    g.ctl_ime.Value := d.showIMEStatus
    g.ctl_ime.Enabled := d.enableCapsTip
    g.ctl_copy.Value := d.enableCopyTip

    g.ctl_capsDur.Value := d.capsShowDuration
    g.ctl_copyDur.Value := d.copyShowDuration

    ; Radio 显示顺序: 鼠标 / 顶部 / 底部 / 中央，对应 tipPosition 值: 1 / 3 / 4 / 2
    g.ctl_pos1.Value := (d.tipPosition = 1)
    g.ctl_pos2.Value := (d.tipPosition = 3)
    g.ctl_pos3.Value := (d.tipPosition = 4)
    g.ctl_pos4.Value := (d.tipPosition = 2)
    g.ctl_mouseOffset.Value := d.tipMouseOffset
    g.ctl_topOffset.Value := d.tipTopOffset
    g.ctl_bottomOffset.Value := d.tipBottomOffset

    g.ctl_fontSize.Value := d.tipFontSize
    g.ctl_bold.Value := d.tipFontBold
    g.ctl_lightMode.Value := d.tipLightMode
    g.ctl_lang.Value := Map("auto",1,"zh",2,"en",3)[d.language]
}

SettingsSave(ctrl, *) {
    global settingsGui
    g := ctrl.Gui
    c := Config

    ; 读取 GUI 值
    c.enableCapsTip := g.ctl_caps.Value
    c.enableCopyTip := g.ctl_copy.Value
    c.showIMEStatus := g.ctl_ime.Value

    SetStartup(g.ctl_startup.Value)

    c.capsShowDuration := Max(100, Integer(g.ctl_capsDur.Value || 800))
    c.copyShowDuration := Max(100, Integer(g.ctl_copyDur.Value || 800))

    ; Radio 显示顺序: 鼠标 / 顶部 / 底部 / 中央，对应 tipPosition 值: 1 / 3 / 4 / 2
    if (g.ctl_pos1.Value)
        c.tipPosition := 1
    else if (g.ctl_pos2.Value)
        c.tipPosition := 3
    else if (g.ctl_pos3.Value)
        c.tipPosition := 4
    else if (g.ctl_pos4.Value)
        c.tipPosition := 2
    else
        c.tipPosition := 1

    c.tipMouseOffset := Max(0, Min(100, Integer(g.ctl_mouseOffset.Value || 20)))
    c.tipTopOffset := Max(0, Min(500, Integer(g.ctl_topOffset.Value || 50)))
    c.tipBottomOffset := Max(0, Min(500, Integer(g.ctl_bottomOffset.Value || 100)))

    c.tipFontSize := Max(8, Min(72, Integer(g.ctl_fontSize.Value || 9)))
    c.tipFontBold := g.ctl_bold.Value
    c.tipLightMode := g.ctl_lightMode.Value
    c.language := ["auto", "zh", "en"][g.ctl_lang.Value]

    Config.Save()
    ApplySettings()

    g.Destroy()
    settingsGui := ""

    ShowTip(T("msg_saved"), 800)
}
