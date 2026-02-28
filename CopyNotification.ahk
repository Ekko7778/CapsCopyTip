; ============================================================
; CopyNotification.ahk (AutoHotkey v2)
; 功能：复制成功后显示提示
; 使用方法：双击运行即可
; ============================================================

#SingleInstance Force
Persistent

; 监听剪贴板变化
OnClipboardChange(ClipChanged)

; 托盘提示
A_TrayTip := "复制提示已运行"

return

; ============================================================
; 剪贴板变化回调函数
; dataType: 0=剪贴板为空, 1=文本, 2=图片, 4=文件
; ============================================================
ClipChanged(dataType) {
    if (dataType = 1) {
        ; 获取剪贴板文本长度
        text := A_Clipboard
        length := StrLen(text)

        ; 显示简洁提示
        ToolTip("已复制：" . length . " 字符")

        ; 1秒后关闭提示
        SetTimer(RemoveToolTip, 500)
    }
    else if (dataType = 2) {
        ToolTip("已复制：图片")
        SetTimer(RemoveToolTip, 500)
    }
    else if (dataType = 4) {
        ; 统计文件数量
        files := StrSplit(A_Clipboard, "`n", "`r")
        count := files.Length
        ToolTip("已复制：" . count . " 个文件")
        SetTimer(RemoveToolTip, 500)
    }
}

RemoveToolTip() {
    ToolTip()
    SetTimer(RemoveToolTip, 0)  ; 关闭定时器
}
