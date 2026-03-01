# 开发笔记

## AutoHotkey 编译问题

### 问题现象

使用 `Ahk2Exe.exe` 编译时报错：
```
Failed to compile: D:\Desktop\test\AllInOneNotification.ahk
Exit code: 52
```

### 原因分析

在 Git Bash / MSYS2 环境下，Windows 程序的命令行参数需要使用 **双斜杠 `//`** 而不是单斜杠 `/`。

### 错误示例

```bash
# ❌ 错误 - 单斜杠会被 Git Bash 吃掉
"/c/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" /in "script.ahk" /out "script.exe"

# ❌ 错误 - PowerShell 封装也失败
pwsh -Command "Start-Process -FilePath '...' -ArgumentList '/in ...'"
```

### 正确做法

```bash
# ✅ 正确 - 使用双斜杠
"/c/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" //in "D:\\Desktop\\test\\script.ahk" //out "D:\\Desktop\\test\\script.exe" //base "C:\\Program Files\\AutoHotkey\\v2\\AutoHotkey64.exe" //compress 0
```

### 参数说明

| 参数 | 说明 |
|:-----|:-----|
| `//in` | 输入的 .ahk 脚本路径 |
| `//out` | 输出的 .exe 文件路径 |
| `//base` | 基础 exe 文件（AutoHotkey 运行时） |
| `//compress` | 压缩级别（0=不压缩，1=UPX 压缩） |

### 完整编译命令

```bash
# 删除旧文件 + 重新编译
rm -f /d/Desktop/test/AllInOneNotification.exe && \
"/c/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" \
  //in "D:\\Desktop\\test\\AllInOneNotification.ahk" \
  //out "D:\\Desktop\\test\\AllInOneNotification.exe" \
  //base "C:\\Program Files\\AutoHotkey\\v2\\AutoHotkey64.exe" \
  //compress 0
```

---

## SendMessage 权限问题

### 问题现象

编译后的 exe 运行时报错：
```
Error: (5) 拒绝访问。
result := SendMessage(0x283, 0x005, 0, , "ahk_id " . hIMEWnd)
```

### 原因

访问某些窗口的 IME 状态时，当前进程没有足够权限。

### 解决方案

在 `SendMessage` 和 `DllCall` 周围添加 try-catch：

```autohotkey
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
```

出错时返回 `"?"` 而不是崩溃。
