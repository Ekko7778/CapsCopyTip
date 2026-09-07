; ============================================================
; CursorTip (AutoHotkey v2)
; 功能：大小写提示 + 复制提示
; - 大小写/输入法：🔒 大写 | 中 / 🔓 小写 | 英
; - 复制提示：显示复制的字符数/图片/文件数
; - 右键托盘图标可打开设置
; ============================================================

;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\app.ico

; 单实例判重交给启动段的「命名互斥体」守卫：
; #SingleInstance 按 exe 文件名判重，版本化产物（CursorTip_v1.1.2.exe / v1.1.3.exe）会被当成不同程序并存
#SingleInstance Off
; 启动即建图标会让后来退出的实例闪一下托盘：先不建，守卫通过后再亮出（A_IconHidden := false）
#NoTrayIcon
Persistent
A_HotkeyInterval := 0  ; 禁用热键频率限制警告（按住 Ctrl/Win 等修饰键会因 auto-repeat 触发，如微信语音输入按住说话）

; ============================================================
; 版本
; ============================================================
global VERSION := "1.2.1"

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
        tipMouseAbove: false,
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
    static tipMouseAbove := false
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
            c.tipMouseAbove := IniRead(Config.Path, "Settings", "TipMouseAbove", 0) = 1
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
            IniWrite(c.tipMouseAbove ? 1 : 0, Config.Path, "Settings", "TipMouseAbove")
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
        "pos_mouse_br", "右下方",
        "pos_mouse_tr", "右上方",
        "pos_center", "屏幕中央",
        "pos_top", "屏幕顶部",
        "pos_bottom", "屏幕底部",
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
        "pos_mouse", "Mouse",
        "pos_mouse_br", "Below",
        "pos_mouse_tr", "Above",
        "pos_center", "Center",
        "pos_top", "Top",
        "pos_bottom", "Bottom",
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
global tipFixedHeight := 0  ; 固定提示控件高度（MeasureTipFixedWidth 一并测出）
global tipBuiltTheme := ""  ; 当前 tip 窗口已用的配色主题（light/dark），预览时按需增量换色
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
    A_TrayMenu.Add(T("tray_reload"), ReloadApp)
    A_TrayMenu.Add(T("tray_exit"), (*) => ExitApp())
}

; 重启前先放开单实例互斥体：Reload 沿用本进程时句柄不会随实例关闭，
; 不先放开的话重启后的脚本会撞上自己留下的互斥体而立即退出
ReloadApp(*) {
    global g_singleInstanceMutex
    if (g_singleInstanceMutex) {
        DllCall("kernel32\CloseHandle", "ptr", g_singleInstanceMutex)
        g_singleInstanceMutex := 0
    }
    Reload()
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
; 单实例守卫：命名互斥体跨所有版本生效（exe 文件名各异 / .ahk 直跑均互斥）。
; 先到者持有且永不退出；后来者在亮出托盘图标之前直接退出——全程零闪烁
global g_singleInstanceMutex := DllCall("kernel32\CreateMutexW", "ptr", 0, "int", true, "wstr", "CursorTip_SingleInstance", "ptr")
if (g_singleInstanceMutex && A_LastError = 183)  ; ERROR_ALREADY_EXISTS = 已有实例
    ExitApp()
A_IconHidden := false  ; 守卫通过，亮出托盘图标（配合 #NoTrayIcon，后来者从未建过图标）

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
    ; 覆盖「恢复默认语言」等不经 OnLangChange 的路径，避免保存后界面语言不刷新
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
    global tipFixedWidth, tipFixedHeight
    c := Config
    g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20", "")
    g.SetFont("s" . c.tipFontSize . (c.tipFontBold ? " Bold" : ""), "Microsoft YaHei")
    t := g.Add("Text", "Center r1", L["en"]["caps_on"] . " | " . L["en"]["ime_zh"])
    g.Show("Hide AutoSize")
    t.GetPos(,, &tw, &th)
    g.Destroy()
    tipFixedWidth := tw
    tipFixedHeight := th   ; ShowTip 原地更新路径按此缩放控件/窗口
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
            y := c.tipMouseAbove ? Max(0, my - gh - c.tipMouseOffset) : my + c.tipMouseOffset
            tipGui.Show("x" . (mx + c.tipMouseOffset) . " y" . y . " NA")
        case 2:
            tipGui.Show("x" . (A_ScreenWidth - gw) / 2 . " y" . (A_ScreenHeight - gh) / 2 . " NA")
        case 3:
            tipGui.Show("x" . (A_ScreenWidth - gw) / 2 . " y" . c.tipTopOffset . " NA")
        case 4:
            tipGui.Show("x" . (A_ScreenWidth - gw) / 2 . " y" . (A_ScreenHeight - gh - c.tipBottomOffset) . " NA")
    }
}

ShowTip(text, duration := 0, fixedWidth := false) {
    global tipGui, tipGuiText, tipFixedWidth, tipFixedHeight, tipGuiIsFixed, tipBuiltTheme
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
            ; 原地更新（同一 HWND，杜绝重建首帧空窗）。关键：变更门控——
            ; 属性没变就一个都不碰，常规弹出/位置拖动保持零重绘（回归教训：每 tick 摸一遍
            ; BackColor/SetFont/Move 会触发整窗擦除重绘，把原本丝滑的位置拖动搞闪）
            theme := (c.tipLightMode = "auto") ? GetSystemTheme() : c.tipLightMode
            if (theme != tipBuiltTheme) {
                tipGui.BackColor := (theme = "light") ? "F5F5F5" : "333333"
                tipGuiText.SetFont("c" . ((theme = "light") ? "333333" : "FFFFFF"))
                tipBuiltTheme := theme
            }
            tipGuiText.GetPos(, , &cw, &ch)
            if (tipFixedWidth > 0 && (tipFixedWidth != cw || tipFixedHeight != ch)) {
                ; 字号/加粗变了：换字体 + 原地缩放控件与窗口（窗口新尺寸 = 当前 ± 控件尺寸差，
                ; 免复算边框/边距任意 DPI 自洽）；RDW_UPDATENOW 强制同步绘制，杜绝异步空帧
                tipGui.GetPos(,, &ww, &wh)
                tipGuiText.SetFont("s" . c.tipFontSize . (c.tipFontBold ? " Bold" : ""), "Microsoft YaHei")
                tipGuiText.Move(, , tipFixedWidth, tipFixedHeight)
                tipGui.Move(, , ww - cw + tipFixedWidth, wh - ch + tipFixedHeight)
                DllCall("RedrawWindow", "Ptr", tipGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x85)
            }
            ; 文本变了才写：WM_SETTEXT 会触发文字区重绘，位置拖动时内容恒定，
            ; 每 tick 盲写会让文字区反复重绘产生轻微闪烁
            if (tipGuiText.Value != text)
                tipGuiText.Value := text
            tipGui.GetPos(,, &gw, &gh)
            ShowTipAt(gw, gh)
        } else {
            ; 宽度模式变化或窗口无效：重建，AutoSize 全新计算尺寸。
            ; 旧窗口不先销毁——新窗口 Show 覆盖后再销毁，消除重建空帧闪烁（与设置窗口切语言同招）
            oldGui := IsObject(tipGui) ? tipGui : ""
            tipGui := ""
            tipGuiText := ""

            ; E0x02000000(WS_EX_COMPOSITED)：子控件双缓冲绘制，背景擦除与文字绘制原子提交，防拖动重绘撕裂
            tipGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +E0x02000000", "")
            theme := (c.tipLightMode = "auto") ? GetSystemTheme() : c.tipLightMode
            tipBuiltTheme := theme
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

            ; 新窗口已显示，此刻销毁旧窗口无视觉中断
            if (IsObject(oldGui))
                try oldGui.Destroy()
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
    ; 时长滑块量程 100-3000ms 实用区间，更大值可手输（保存仍钳到 99999）
    g.ctl_capsDur := AddNumSlider(g, "capsDur", 135, 144, 100, 3000, c.capsShowDuration, "ms")
    g.Add("Text", "x20 y177 w110", T("set_copy_label"))
    g.ctl_copyDur := AddNumSlider(g, "copyDur", 135, 174, 100, 3000, c.copyShowDuration, "ms")

    g.Add("Text", "x10 y202 w320 h1 BackgroundDDDDDD")

    ; === 提示位置 ===
    g.SetFont("Bold")
    g.Add("Text", "x20 y214", T("set_position"))
    g.SetFont("Norm")

    ; 位置分段选项条（Win11 分段控件样式）：每段两块实底 Text 叠放（激活=蓝底粗体 / 未激活=灰底），
    ; 点击切显隐。无 BackgroundTrans、无控件移动 → 无重绘伪影。序号→tipPosition: 1鼠标/2顶部/3底部/4中央
    g.Add("Text", "x20 y240 w300 h26 BackgroundE3E6E8")   ; 条底座
    g.ctl_posSegs := []
    segKeys := ["pos_mouse", "pos_top", "pos_bottom", "pos_center"]
    loop 4 {
        x := 21 + (A_Index - 1) * 75
        onCtrl := g.Add("Text", "x" x " y241 w72 h24 Center +0x200 BackgroundCCE4F7 c0067C4", T(segKeys[A_Index]))
        onCtrl.SetFont("Bold")   ; v2 字体样式不能放创建选项，只能 SetFont
        offCtrl := g.Add("Text", "x" x " y241 w72 h24 Center +0x200 BackgroundECECEC c444444", T(segKeys[A_Index]))
        onCtrl.Visible := false
        onCtrl.SegIdx := A_Index, offCtrl.SegIdx := A_Index
        onCtrl.OnEvent("Click", OnPosSegClick), offCtrl.OnEvent("Click", OnPosSegClick)
        g.ctl_posSegs.Push({on: onCtrl, off: offCtrl})
        RoundCtrl(onCtrl, 72, 24, 12)   ; r12 = 高度一半，胶囊形
    }

    ; 参数面板：滑块统一居左（x20 同一列），鼠标段方位选项居右（显式 h22 与输入框同高对齐，
    ; 且控件底边不得压到下方分割线——YaHei 下 radio 自动高约 28px，悬停重绘会吃线）；中央段无参数
    g.ctl_mouseOffset := AddNumSlider(g, "mouseOffset", 20, 282, 0, 100, c.tipMouseOffset, "px")
    g.ctl_mouseBr := g.Add("Radio", "x205 y282 h22 w58 +Group" . (!c.tipMouseAbove ? " Checked" : ""), T("pos_mouse_br"))
    g.ctl_mouseTr := g.Add("Radio", "x266 y282 h22 w58" . (c.tipMouseAbove ? " Checked" : ""), T("pos_mouse_tr"))
    g.ctl_topOffset := AddNumSlider(g, "topOffset", 20, 282, 0, 500, c.tipTopOffset, "px")
    g.ctl_bottomOffset := AddNumSlider(g, "bottomOffset", 20, 282, 0, 500, c.tipBottomOffset, "px")
    SetPosSegment(g, PosSegOf(c.tipPosition))   ; 初始化激活段（含面板显隐）

    g.Add("Text", "x10 y310 w320 h1 BackgroundDDDDDD")

    ; === 外观样式 ===
    g.SetFont("Bold")
    g.Add("Text", "x20 y322", T("set_appearance"))
    g.SetFont("Norm")

    g.ctl_themeAuto := g.Add("Radio", "x20 y347 w120 +Group" . (c.tipLightMode = "auto" ? " Checked" : ""), T("app_auto"))
    g.ctl_lightMode := g.Add("Radio", "x20 y374 w100" . (c.tipLightMode = "light" ? " Checked" : ""), T("app_light"))
    g.ctl_darkMode := g.Add("Radio", "x200 y374 w100" . (c.tipLightMode = "dark" ? " Checked" : ""), T("app_dark"))
    g.Add("Text", "x20 y404 w70", T("set_fontsize"))
    g.ctl_fontSize := AddNumSlider(g, "fontSize", 95, 401, 8, 72, c.tipFontSize)
    g.ctl_bold := g.Add("CheckBox", "x254 y404 w60", T("set_bold"))
    g.ctl_bold.Value := c.tipFontBold

    ; === 实时预览：视觉控件改动立即按未保存设置显示 tip，不写盘（保存才落定，取消回滚）===
    g.ctl_mouseBr.OnEvent("Click", MakePreviewCb("mouseAbove"))
    g.ctl_mouseTr.OnEvent("Click", MakePreviewCb("mouseAbove"))
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
    g.Add("Text", "x20 y434 w80", T("set_language"))
    langIdx := Map("auto",1,"zh",2,"en",3)[Config.language]
    g.ctl_lang := g.Add("DDL", "x200 y431 w120 AltSubmit Choose" . langIdx, [T("lang_auto"), T("lang_zh"), T("lang_en")])
    g.ctl_lang.OnEvent("Change", OnLangChange)

    g.Add("Text", "x10 y462 w320 h1 BackgroundDDDDDD")

    ; === 按钮 ===
    g.Add("Button", "x20 y477 w80", T("btn_reset")).OnEvent("Click", SettingsReset)
    g.Add("Button", "x130 y477 w80", T("btn_cancel")).OnEvent("Click", SettingsClose)
    g.Add("Button", "x240 y477 w80 Default", T("btn_save")).OnEvent("Click", SettingsSave)
    g.OnEvent("Close", SettingsClose)

    ; 底部信息
    icoPath := A_Temp . "\CursorTip_github.ico"
    FileInstall("assets\github.ico", icoPath, 1)
    g.Add("Picture", "x20 y517 w16 h16", icoPath).OnEvent("Click", (*) => Run("https://cursortip-website.pages.dev/"))
    g.SetFont("s8", "Microsoft YaHei")
    g.Add("Link", "x40 y519", '<a href="https://cursortip-website.pages.dev/">' . T("link_about") . '</a>')
    g.Add("Text", "x200 y519", "© 2026  MIT License")

    ; 有记忆位置就在原位显示（切语言重建时新窗口完整覆盖旧窗口，消除空帧/灰线）
    showOpts := "w340 h547"
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
        posSeg: g.ctl_posSeg,
        mouseOffset: g.ctl_mouseOffset.Value,
        mouseAbove: g.ctl_mouseTr.Value,
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
    SetPosSegment(g, s.posSeg)
    g.ctl_mouseOffset.Value := s.mouseOffset
    g.ctl_mouseBr.Value := !s.mouseAbove
    g.ctl_mouseTr.Value := s.mouseAbove
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
        tipMouseAbove:    c.tipMouseAbove,
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
    c.tipMouseAbove    := snap.tipMouseAbove
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

; 数值组合控件：[滑块][输入框][单位] 双向同步，任一改动走 OnPreviewChange(kind) 实时预览
; 程序设 .Value 不触发 Change 事件（仅用户操作触发，见 v2-changes 文档），双向回写无死循环
; 返回 Edit 控件：外部按 ctl_xxx.Value 读写，SettingsSave/Reset/快照逻辑零改动
AddNumSlider(g, kind, x, y, minV, maxV, val, unit := "") {
    ; INI 值超程时滑块顶格，Edit 保留原值（保存钳制逻辑不变）
    ; AltSubmit：默认 Change 仅在松手时触发（官方文档），加它才能拖动中高频触发→数值/预览实时跟手
    ctlSld := g.Add("Slider", "x" x " y" (y + 1) " w105 h22 Range" minV "-" maxV " NoTicks AltSubmit", Max(minV, Min(maxV, val)))
    ctlEdit := g.Add("Edit", "x" (x + 109) " y" y " w42 h22 Number", val)
    unitCtl := (unit != "") ? g.Add("Text", "x" (x + 155) " y" (y + 3), unit) : ""
    ; 三件套挂到 Edit 上，供参数面板整体显隐（SyncPositionPanel）
    ctlEdit.Slider := ctlSld
    ctlEdit.Unit := unitCtl
    ctlSld.OnEvent("Change", (sld, *) => (ctlEdit.Value := sld.Value, OnPreviewChange(sld, kind)))
    ctlEdit.OnEvent("Change", (ed, *) => (
        ctlSld.Value := Max(minV, Min(maxV, IsInteger(ed.Value) ? Integer(ed.Value) : minV)),
        OnPreviewChange(ed, kind)))
    return ctlEdit
}

; 滑块三件套（滑块/输入框/单位）整体显隐
SetSliderVisible(ctl, vis) {
    ctl.Visible := vis
    ctl.Slider.Visible := vis
    if (ctl.Unit != "")
        ctl.Unit.Visible := vis
}

; tipPosition → 选项条序号（1鼠标/2顶部/3底部/4中央）
PosSegOf(pos) {
    return Map(1, 1, 3, 2, 4, 3, 2, 4)[pos]
}

; 选项条切到第 idx 段：切换各段蓝/灰底显隐 + 切参数面板（点击/初始化/恢复默认共用）
SetPosSegment(g, idx) {
    g.ctl_posSeg := idx
    loop g.ctl_posSegs.Length {
        seg := g.ctl_posSegs[A_Index]
        active := A_Index = idx
        seg.on.Visible := active
        seg.off.Visible := !active
    }
    SyncPositionPanel(g)
}

; 按选中段显隐参数面板（1鼠标 2顶部 3底部 4中央-无参数）
SyncPositionPanel(g) {
    idx := g.ctl_posSeg
    SetSliderVisible(g.ctl_mouseOffset, idx = 1)
    SetSliderVisible(g.ctl_topOffset, idx = 2)
    SetSliderVisible(g.ctl_bottomOffset, idx = 3)
    g.ctl_mouseBr.Visible := g.ctl_mouseTr.Visible := (idx = 1)
}

; 位置分段条点击：切换激活段 + 照常预览
OnPosSegClick(ctl, *) {
    SetPosSegment(ctl.Gui, ctl.SegIdx)
    OnPreviewChange(ctl, "pos")
}

; 控件圆角裁剪（SetWindowRgn；w/h 为逻辑像素，按窗口 DPI 换算物理像素）
RoundCtrl(ctrl, w, h, r) {
    s := DllCall("user32\GetDpiForWindow", "Ptr", ctrl.Gui.Hwnd, "UInt") / 96
    rgn := DllCall("gdi32\CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", Round(w * s), "Int", Round(h * s), "Int", Round(r * s), "Int", Round(r * s), "Ptr")
    DllCall("user32\SetWindowRgn", "Ptr", ctrl.Hwnd, "Ptr", rgn, "Int", true)
}

; 实时预览：把控件当前值写进 Config 内存（不写盘）→ 按需重测尺寸 → 显示预览 tip
OnPreviewChange(ctl, kind) {
    g := ctl.Gui
    c := Config
    needMeasure := false   ; 只有字号/粗细变化才需重测 tipFixedWidth/Height

    switch kind {
        case "pos":                           ; 选项条序号→tipPosition: 1鼠标/2顶部/3底部/4中央
            c.tipPosition := [1, 3, 4, 2][g.ctl_posSeg]
        case "mouseOffset":  c.tipMouseOffset  := ClampNum(g.ctl_mouseOffset.Value,  0, 100, 20)
        case "mouseAbove":   c.tipMouseAbove   := g.ctl_mouseTr.Value
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

    ; 字号/加粗重测固定尺寸；配色/字体均可在现有窗口上原地更新（见 ShowTip 复用分支），无需强制重建
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
            || c.tipMouseAbove != snap.tipMouseAbove
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

    ; 选项条: 鼠标 / 顶部 / 底部 / 中央，对应 tipPosition 值: 1 / 3 / 4 / 2
    g.ctl_mouseOffset.Value := d.tipMouseOffset
    g.ctl_mouseBr.Value := !d.tipMouseAbove
    g.ctl_mouseTr.Value := d.tipMouseAbove
    g.ctl_topOffset.Value := d.tipTopOffset
    g.ctl_bottomOffset.Value := d.tipBottomOffset
    SetPosSegment(g, PosSegOf(d.tipPosition))
    g.ctl_topOffset.Value := d.tipTopOffset
    g.ctl_bottomOffset.Value := d.tipBottomOffset

    g.ctl_fontSize.Value := d.tipFontSize
    g.ctl_bold.Value := d.tipFontBold
    g.ctl_themeAuto.Value := (d.tipLightMode = "auto")
    g.ctl_lightMode.Value := (d.tipLightMode = "light")
    g.ctl_darkMode.Value := (d.tipLightMode = "dark")
    g.ctl_lang.Value := Map("auto",1,"zh",2,"en",3)[d.language]

    ; 控件已复位，Config 内存与预览一并复位：否则后续任何改动触发预览时，
    ; 仍按复位前的样式渲染（旧字号/主题残留在 Config 里）
    SyncConfigFromGui(g)
    DestroyTipGui()
    MeasureTipFixedWidth()
    ShowTip(GetPreviewText(), Config.capsShowDuration, true)
}

; 把设置窗口控件值同步进 Config 内存（保存/恢复默认共用；写盘与开机启动由调用方负责）
SyncConfigFromGui(g) {
    c := Config
    c.enableCapsTip := g.ctl_caps.Value
    c.enableCopyTip := g.ctl_copy.Value
    c.showIMEStatus := g.ctl_ime.Value

    c.capsShowDuration := Max(100, Integer(g.ctl_capsDur.Value || 800))
    c.copyShowDuration := Max(100, Integer(g.ctl_copyDur.Value || 800))

    ; 选项条序号 → tipPosition: 1鼠标/2顶部/3底部/4中央
    c.tipPosition := [1, 3, 4, 2][g.ctl_posSeg]

    c.tipMouseOffset := Max(0, Min(100, Integer(g.ctl_mouseOffset.Value || 20)))
    c.tipMouseAbove := g.ctl_mouseTr.Value
    c.tipTopOffset := Max(0, Min(500, Integer(g.ctl_topOffset.Value || 50)))
    c.tipBottomOffset := Max(0, Min(500, Integer(g.ctl_bottomOffset.Value || 100)))

    c.tipFontSize := Max(8, Min(72, Integer(g.ctl_fontSize.Value || 9)))
    c.tipFontBold := g.ctl_bold.Value
    c.tipLightMode := g.ctl_themeAuto.Value ? "auto" : (g.ctl_lightMode.Value ? "light" : "dark")
    c.language := ["auto", "zh", "en"][g.ctl_lang.Value]
}

SettingsSave(ctrl, *) {
    global settingsGui, settingsSessionLang, settingsConfigSnap
    g := ctrl.Gui

    SetStartup(g.ctl_startup.Value)
    SyncConfigFromGui(g)

    Config.Save()
    ApplySettings()

    g.Destroy()
    settingsGui := ""
    settingsSessionLang := ""
    settingsConfigSnap := ""

    ShowTip(T("msg_saved"), 800)
}
