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
global VERSION := "1.1.1"

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
        tipLightMode: "auto",
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
    static tipLightMode := "auto"
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
            tipRaw := IniRead(Config.Path, "Settings", "TipLightMode", "auto")
            ; 兼容旧版布尔值（0/1）→ 新版字符串（"light"/"dark"/"auto"）
            c.tipLightMode := IsInteger(tipRaw) ? (tipRaw = 1 ? "light" : "dark") : tipRaw
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
            IniWrite(c.tipLightMode, Config.Path, "Settings", "TipLightMode")
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
        "copy_image_files", "已复制：{n} 张图片",
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
        "app_auto", "跟随系统",
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
        "link_about", "检查更新",
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
        "copy_image_files", "Copied: {n} image(s)",
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
        "app_auto", "Follow system",
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
        "link_about", "Check for updates",
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
global settingsSessionLang := ""  ; 打开设置会话时的语言快照，切语言即时预览、取消时据此回滚
global settingsDraft := ""  ; 切语言重建设置窗口时的控件草稿，ShowSettings 在 Show 前应用，避免选中状态闪烁
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
; 调试日志：每次启动清空，AI 通过读 work/debug.log 调试
try {
    DirCreate("work")
    FileDelete("work\debug.log")
    FileAppend("CursorTip: started at " . A_Now . "`n", "work\debug.log")
}
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
    global tipGui, tipGuiText, curLang
    c := Config

    ; 语言也是设置的一部分，在此统一应用：保存后即时刷新 curLang + 托盘菜单
    ; 覆盖「Reset 恢复默认语言」等不经 OnLangChange 的路径，避免保存后界面语言不刷新
    curLang := (c.language = "auto") ? DetectLang() : c.language
    BuildTrayMenu()

    ; 大小写监听
    SetTimer(CheckCapsLock, 0)
    if (c.enableCapsTip)
        SetTimer(CheckCapsLock, 50)

    ; 复制监听
    OnClipboardChange(ClipChanged, 0)
    if (c.enableCopyTip)
        OnClipboardChange(ClipChanged)

    ; 销毁提示窗口以应用新外观（复用 DestroyTipGui，与预览共用同一销毁逻辑）
    DestroyTipGui()

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

; 销毁当前 tip 窗口并清状态：预览/ApplySettings 调用，强制下次 ShowTip 走重建分支以应用新外观
DestroyTipGui() {
    global tipGui, tipGuiText, tipGuiIsFixed
    if (IsObject(tipGui)) {
        try tipGui.Destroy()
        tipGui := ""
        tipGuiText := ""
        tipGuiIsFixed := false
    }
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
    FileAppend("CursorTip: ShowTip text='" . text . "' dur=" . duration . " fixed=" . fixedWidth . "`n", "work\debug.log")

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
            theme := (c.tipLightMode = "auto") ? GetSystemTheme() : c.tipLightMode
            if (theme = "light") {
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

            ; Windows 11 圆角 + 禁用 DWM 显示过渡动画
            ; 过渡动画期间窗口从透明淡入，叠在浅色 webview 上会闪过一帧"浅色"，
            ; 快速切换中英文时表现为深浅色来回闪烁。设置窗口同此处理。
            try {
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", tipGui.Hwnd, "Int", 33, "Int*", 2, "Int", 4)  ; 圆角
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", tipGui.Hwnd, "Int", 3, "Int*", 1, "Int", 4)   ; 禁用过渡动画
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

; 取前台线程的「焦点控件」窗口句柄（IME 检测的正确目标）。
; webview 类容器（Tauri/Edge WebView2/Chrome/Electron）里，顶层前台窗口 ≠ 真正接收
; IME 输入的子窗口，对顶层窗口查 ImmGetConversionStatus 拿到的状态不随中英切换更新；
; 必须用 GetGUIThreadInfo 取 hwndFocus 才对。取不到时回退前台窗口（普通 Win32 应用够用）。
GetFocusHwnd() {
    hFore := DllCall("user32\GetForegroundWindow", "Ptr")
    if (!hFore)
        return 0
    tid := DllCall("user32\GetWindowThreadProcessId", "Ptr", hFore, "Ptr", 0, "UInt")
    guiInfo := Buffer(72, 0)
    NumPut("UInt", 72, guiInfo, 0)
    if (DllCall("user32\GetGUIThreadInfo", "UInt", tid, "Ptr", guiInfo.Ptr)) {
        hFocus := NumGet(guiInfo, 16, "Ptr")  ; hwndFocus：x64 下偏移 8+A_PtrSize=16
        if (hFocus)
            return hFocus
    }
    return hFore
}

GetIMEStatus(forceRefresh := false) {
    static lastResult := "英"
    static lastCheckTime := 0
    static lastWindowHash := 0

    ; 防抖：150ms 内且同一焦点窗口直接返回上次结果
    if (!forceRefresh) {
        if (A_TickCount - lastCheckTime < 150)
            return lastResult
        hWnd := GetFocusHwnd()
        if (hWnd && hWnd = lastWindowHash)
            return lastResult
    }

    result := ""
    method := ""
    hWnd := 0

    try {
        hWnd := GetFocusHwnd()
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
        lastWindowHash := hWnd
        FileAppend("CursorTip: IME -> " . result . " (method=" . method . ")`n", "work\debug.log")
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
; 系统主题检测
; ============================================================
; 读注册表 AppsUseLightTheme：1=浅色，0=深色；键不存在时默认 1（浅色）
GetSystemTheme() {
    value := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme", 1)
    return value ? "light" : "dark"
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
        FileAppend("CursorTip: CapsLock -> " . (current ? "ON" : "OFF") . "`n", "work\debug.log")
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

; 判断扩展名是否为常见图片格式（大小写不敏感）
; 列表前后留空格做单词边界，避免 "jpg" 误匹配 "jpeg" 等子串
IsImageExt(ext) {
    static imageExts := " png jpg jpeg gif bmp webp ico cur svg tif tiff heic heif avif jfif jpe dib "
    return ext != "" && InStr(imageExts, " " . ext . " ", false) > 0
}

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
            if (count > 0 && files[1] != "") {
                ; 按扩展名二次判断：全部是图片文件 → 显示"图片"，否则 → 显示"文件"
                allImages := true
                for index, f in files {
                    SplitPath(f, , , &ext)
                    if (!IsImageExt(ext)) {
                        allImages := false
                        break
                    }
                }
                if (allImages) {
                    FileAppend("CursorTip: Clipboard -> " . count . " image-file(s)`n", "work\debug.log")
                    ShowTip(T("copy_image_files", count), Config.copyShowDuration)
                } else {
                    FileAppend("CursorTip: Clipboard -> " . count . " file(s)`n", "work\debug.log")
                    ShowTip(T("copy_files", count), Config.copyShowDuration)
                }
            }
        } else if (isImage) {
            FileAppend("CursorTip: Clipboard -> image`n", "work\debug.log")
            ShowTip(T("copy_image"), Config.copyShowDuration)
        } else {
            clipText := A_Clipboard
            length := StrLen(clipText)
            if (length > 0) {
                FileAppend("CursorTip: Clipboard -> " . length . " chars`n", "work\debug.log")
                ShowTip(T("copy_chars", length), Config.copyShowDuration)
            }
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
    global settingsGui, settingsOpenPos, settingsSessionLang, settingsDraft, settingsConfigSnap
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

    ; 记录本次会话开始时的语言和视觉属性（仅首次打开：切语言会重建窗口，此时快照已存在不再覆盖），取消时据此回滚
    if (settingsSessionLang = "") {
        settingsSessionLang := Config.language
        settingsConfigSnap := SnapshotConfig()   ; 视觉属性快照，取消预览时回滚
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

    g.ctl_themeAuto := g.Add("Radio", "x20 y387 w120 +Group" . (c.tipLightMode = "auto" ? " Checked" : ""), T("app_auto"))
    g.ctl_lightMode := g.Add("Radio", "x20 y414 w100" . (c.tipLightMode = "light" ? " Checked" : ""), T("app_light"))
    g.ctl_darkMode := g.Add("Radio", "x200 y414 w100" . (c.tipLightMode = "dark" ? " Checked" : ""), T("app_dark"))
    g.Add("Text", "x20 y444 w70", T("set_fontsize"))
    g.ctl_fontSize := g.Add("Edit", "x95 y441 w40 h22 Number", c.tipFontSize)
    g.ctl_bold := g.Add("CheckBox", "x200 y444 w60", T("set_bold"))
    g.ctl_bold.Value := c.tipFontBold

    ; === 实时预览：视觉控件改动立即按未保存设置显示 tip，不写盘（保存才落定，取消回滚）===
    g.ctl_pos1.OnEvent("Click", MakePreviewCb("pos"))
    g.ctl_pos2.OnEvent("Click", MakePreviewCb("pos"))
    g.ctl_pos3.OnEvent("Click", MakePreviewCb("pos"))
    g.ctl_pos4.OnEvent("Click", MakePreviewCb("pos"))
    g.ctl_mouseOffset.OnEvent("Change", MakePreviewCb("mouseOffset"))
    g.ctl_topOffset.OnEvent("Change", MakePreviewCb("topOffset"))
    g.ctl_bottomOffset.OnEvent("Change", MakePreviewCb("bottomOffset"))
    g.ctl_fontSize.OnEvent("Change", MakePreviewCb("fontSize"))
    g.ctl_bold.OnEvent("Click", MakePreviewCb("bold"))
    g.ctl_themeAuto.OnEvent("Click", MakePreviewCb("theme"))
    g.ctl_lightMode.OnEvent("Click", MakePreviewCb("theme"))
    g.ctl_darkMode.OnEvent("Click", MakePreviewCb("theme"))
    g.ctl_capsDur.OnEvent("Change", MakePreviewCb("capsDur"))
    g.ctl_copyDur.OnEvent("Change", MakePreviewCb("copyDur"))

    ; === 语言 ===
    g.Add("Text", "x20 y474 w80", T("set_language"))
    langIdx := Map("auto",1,"zh",2,"en",3)[Config.language]
    g.ctl_lang := g.Add("DDL", "x200 y471 w120 AltSubmit Choose" . langIdx, [T("lang_auto"), T("lang_zh"), T("lang_en")])
    g.ctl_lang.OnEvent("Change", OnLangChange)

    g.Add("Text", "x10 y502 w320 h1 BackgroundDDDDDD")

    ; === 按钮 ===
    g.Add("Button", "x20 y517 w80", T("btn_reset")).OnEvent("Click", SettingsReset)
    g.Add("Button", "x130 y517 w80", T("btn_cancel")).OnEvent("Click", SettingsClose)
    g.Add("Button", "x240 y517 w80 Default", T("btn_save")).OnEvent("Click", SettingsSave)
    g.OnEvent("Close", SettingsClose)

    ; 底部信息
    icoPath := A_Temp . "\CursorTip_github.ico"
    FileInstall("assets\github.ico", icoPath, 1)
    g.Add("Picture", "x20 y557 w16 h16", icoPath).OnEvent("Click", (*) => Run("https://cursortip-website.pages.dev/"))
    g.SetFont("s8", "Microsoft YaHei")
    g.Add("Link", "x40 y559", '<a href="https://cursortip-website.pages.dev/">' . T("link_about") . '</a>')
    g.Add("Text", "x200 y559", "© 2026  MIT License")

    ; 有记忆位置就在原位显示（切语言重建时新窗口完整覆盖旧窗口，消除空帧/灰线）
    showOpts := "w340 h587"
    if (settingsOpenPos != "")
        showOpts .= " x" . settingsOpenPos[1] . " y" . settingsOpenPos[2]
    ; 禁用 DWM 窗口过渡动画（DWMWA_TRANSITIONS_FORCEDISABLED=3）：新窗口瞬间不透明显示，
    ; 避免淡入期间底下旧窗口的文字透过来形成一瞬间残影
    try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", g.Hwnd, "Int", 3, "Int*", 1, "Int", 4)
    ; 切语言重建（settingsDraft 非空）：Show 前先恢复用户草稿，避免「先显示 Config 默认值再跳回草稿」的选中状态闪烁
    if (IsObject(settingsDraft)) {
        RestoreSettings(g, settingsDraft)
        settingsDraft := ""
    }
    g.Show(showOpts)
    settingsGui := g
}

; 切换语言：即时预览（刷新托盘 + 重建设置窗口）。不在此写盘——保存统一走 SettingsSave，取消时由 SettingsClose 回滚
OnLangChange(ctl, *) {
    Config.language := ["auto", "zh", "en"][ctl.Value]
    ApplyLanguage()
}

; 应用当前 Config.language：更新 curLang、重建托盘、重开设置窗口
ApplyLanguage() {
    global curLang, settingsGui, settingsOpenPos, settingsDraft
    curLang := (Config.language = "auto") ? DetectLang() : Config.language
    BuildTrayMenu()
    if (IsObject(settingsGui)) {
        oldGui := settingsGui
        ; 快照用户已改但未保存的控件值：重建窗口会从 Config 重新初始化，不快照会丢失草稿
        snap := SnapshotSettings(oldGui)
        ; 记录旧窗口位置：新窗口在同位置覆盖显示后再销毁旧窗口，
        ; 消除「销毁→重建」之间的空帧（即切语言时中间那条灰线）
        try {
            if (WinExist("ahk_id " . oldGui.Hwnd))
                oldGui.GetPos(&px, &py), settingsOpenPos := [px, py]
        } catch {
        }
        settingsGui := ""   ; 让 ShowSettings 的防多开逻辑放行，能创建新窗口
        settingsDraft := snap   ; 草稿经全局变量传入：ShowSettings 在 Show 前应用，避免选中状态先跳默认再跳回的闪烁
        ShowSettings()      ; 新窗口在旧位置显示，完整覆盖旧窗口（内部已恢复草稿）
        if (IsObject(oldGui))
            oldGui.Destroy()   ; 旧窗口已被新窗口遮挡，销毁无视觉中断
    } else {
        ShowSettings()
    }
}

; 快照设置窗口所有可编辑控件值（切语言重建窗口时保留用户未保存的草稿；语言除外，由 Config.language 决定）
SnapshotSettings(g) {
    return {
        startup: g.ctl_startup.Value,
        caps: g.ctl_caps.Value,
        ime: g.ctl_ime.Value,
        imeEnabled: g.ctl_ime.Enabled,
        copy: g.ctl_copy.Value,
        capsDur: g.ctl_capsDur.Value,
        copyDur: g.ctl_copyDur.Value,
        pos1: g.ctl_pos1.Value, pos2: g.ctl_pos2.Value,
        pos3: g.ctl_pos3.Value, pos4: g.ctl_pos4.Value,
        mouseOffset: g.ctl_mouseOffset.Value,
        topOffset: g.ctl_topOffset.Value,
        bottomOffset: g.ctl_bottomOffset.Value,
        fontSize: g.ctl_fontSize.Value,
        bold: g.ctl_bold.Value,
        themeAuto: g.ctl_themeAuto.Value,
        lightMode: g.ctl_lightMode.Value,
        darkMode: g.ctl_darkMode.Value
    }
}

; 把快照恢复到新窗口控件
RestoreSettings(g, s) {
    g.ctl_startup.Value := s.startup
    g.ctl_caps.Value := s.caps
    g.ctl_ime.Value := s.ime
    g.ctl_ime.Enabled := s.imeEnabled
    g.ctl_copy.Value := s.copy
    g.ctl_capsDur.Value := s.capsDur
    g.ctl_copyDur.Value := s.copyDur
    g.ctl_pos1.Value := s.pos1
    g.ctl_pos2.Value := s.pos2
    g.ctl_pos3.Value := s.pos3
    g.ctl_pos4.Value := s.pos4
    g.ctl_mouseOffset.Value := s.mouseOffset
    g.ctl_topOffset.Value := s.topOffset
    g.ctl_bottomOffset.Value := s.bottomOffset
    g.ctl_fontSize.Value := s.fontSize
    g.ctl_bold.Value := s.bold
    g.ctl_themeAuto.Value := s.themeAuto
    g.ctl_lightMode.Value := s.lightMode
    g.ctl_darkMode.Value := s.darkMode
}

; 快照/恢复 Config 的视觉属性（取消预览时回滚用）
; 不含 language（已由 settingsSessionLang 管）、不含功能开关（不预览，取消时本就未改 Config）
SnapshotConfig() {
    c := Config
    return {
        tipPosition:      c.tipPosition,
        tipMouseOffset:   c.tipMouseOffset,
        tipTopOffset:     c.tipTopOffset,
        tipBottomOffset:  c.tipBottomOffset,
        tipFontSize:      c.tipFontSize,
        tipFontBold:      c.tipFontBold,
        tipLightMode:     c.tipLightMode,
        capsShowDuration: c.capsShowDuration,
        copyShowDuration: c.copyShowDuration
    }
}

RestoreConfig(snap) {
    c := Config
    c.tipPosition      := snap.tipPosition
    c.tipMouseOffset   := snap.tipMouseOffset
    c.tipTopOffset     := snap.tipTopOffset
    c.tipBottomOffset  := snap.tipBottomOffset
    c.tipFontSize      := snap.tipFontSize
    c.tipFontBold      := snap.tipFontBold
    c.tipLightMode     := snap.tipLightMode
    c.capsShowDuration := snap.capsShowDuration
    c.copyShowDuration := snap.copyShowDuration
}

; 数值裁剪到 [lo, hi]，空值/非法用 default（复刻 SettingsSave 的范围保护，保证预览与保存一致）
ClampNum(raw, lo, hi, default) {
    return Max(lo, Min(hi, Integer(raw || default)))
}

; 预览 tip 文本：caps + IME 风格（固定宽度，覆盖 ShowTip 复用+重建两条渲染路径）
GetPreviewText() {
    return T("caps_on") . " | " . T("ime_zh")
}

; 用闭包把控件 kind 绑进回调，避免脆弱的控件名/标题匹配
MakePreviewCb(kind) {
    return (ctl, *) => OnPreviewChange(ctl, kind)
}

; 实时预览：把控件当前值写进 Config 内存（不写盘）→ 按需重测宽度 → 销毁旧 tip → 显示预览 tip
OnPreviewChange(ctl, kind) {
    g := ctl.Gui
    c := Config
    needMeasure := false   ; 只有字号/粗细变化才需重测 tipFixedWidth

    switch kind {
        case "pos":                           ; pos1→1(鼠标) pos2→3(顶部) pos3→4(底部) pos4→2(中央)
            c.tipPosition := g.ctl_pos1.Value ? 1 : (g.ctl_pos2.Value ? 3 : (g.ctl_pos3.Value ? 4 : 2))
        case "mouseOffset":  c.tipMouseOffset  := ClampNum(g.ctl_mouseOffset.Value,  0, 100, 20)
        case "topOffset":    c.tipTopOffset    := ClampNum(g.ctl_topOffset.Value,    0, 500, 50)
        case "bottomOffset": c.tipBottomOffset := ClampNum(g.ctl_bottomOffset.Value, 0, 500, 100)
        case "fontSize":
            c.tipFontSize := ClampNum(g.ctl_fontSize.Value, 8, 72, 9)
            needMeasure := true
        case "bold":
            c.tipFontBold := g.ctl_bold.Value
            needMeasure := true
        case "theme":
            c.tipLightMode := g.ctl_themeAuto.Value ? "auto" : (g.ctl_lightMode.Value ? "light" : "dark")
        case "capsDur": c.capsShowDuration := ClampNum(g.ctl_capsDur.Value, 100, 99999, 800)
        case "copyDur": c.copyShowDuration := ClampNum(g.ctl_copyDur.Value, 100, 99999, 800)
    }

    ; 任何外观/位置变化都要先销毁旧窗口：ShowTip 固定宽度复用路径只改文本，不销毁会沿用旧字号/背景色
    DestroyTipGui()
    if (needMeasure)
        MeasureTipFixedWidth()

    ShowTip(GetPreviewText(), c.capsShowDuration, true)
}

SettingsClose(ctrlOrGui, *) {
    global settingsGui, settingsSessionLang, settingsConfigSnap, curLang
    ; Close 事件传入 Gui 对象，按钮点击传入 GuiControl（有 .Gui 属性）
    g := ctrlOrGui.HasProp("Gui") ? ctrlOrGui.Gui : ctrlOrGui
    changed := false

    ; 视觉属性是即时预览的（OnPreviewChange 改了 Config 内存但没写盘），回滚到会话开始时的值
    if (IsObject(settingsConfigSnap)) {
        snap := settingsConfigSnap, c := Config
        if (c.tipPosition != snap.tipPosition || c.tipMouseOffset != snap.tipMouseOffset
            || c.tipTopOffset != snap.tipTopOffset || c.tipBottomOffset != snap.tipBottomOffset
            || c.tipFontSize != snap.tipFontSize || c.tipFontBold != snap.tipFontBold
            || c.tipLightMode != snap.tipLightMode
            || c.capsShowDuration != snap.capsShowDuration || c.copyShowDuration != snap.copyShowDuration) {
            RestoreConfig(snap)
            changed := true
        }
        settingsConfigSnap := ""
    }

    ; 语言是即时预览的（OnLangChange 改了 Config.language 但没写盘），回滚到会话开始时的语言
    if (settingsSessionLang != "" && settingsSessionLang != Config.language) {
        Config.language := settingsSessionLang
        curLang := (Config.language = "auto") ? DetectLang() : Config.language
        BuildTrayMenu()
        changed := true
    }
    settingsSessionLang := ""

    ; 有任何回滚才统一清理：销毁残留预览 tip + 重测宽度 + 刷语言/定时器（ApplySettings 副作用在取消场景安全）
    if (changed)
        ApplySettings()

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
    g.ctl_themeAuto.Value := (d.tipLightMode = "auto")
    g.ctl_lightMode.Value := (d.tipLightMode = "light")
    g.ctl_darkMode.Value := (d.tipLightMode = "dark")
    g.ctl_lang.Value := Map("auto",1,"zh",2,"en",3)[d.language]
}

SettingsSave(ctrl, *) {
    global settingsGui, settingsSessionLang
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
    c.tipLightMode := g.ctl_themeAuto.Value ? "auto" : (g.ctl_lightMode.Value ? "light" : "dark")
    c.language := ["auto", "zh", "en"][g.ctl_lang.Value]

    Config.Save()
    ApplySettings()

    g.Destroy()
    settingsGui := ""
    settingsSessionLang := ""
    settingsConfigSnap := ""

    ShowTip(T("msg_saved"), 800)
}
