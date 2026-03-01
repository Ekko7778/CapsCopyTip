# AllInOneNotification 项目规则

## 项目概述

AutoHotkey v2 脚本，合并大小写提示 + 复制提示功能。

**功能**：
- 大小写/输入法：🔒 大写 | 中 / 🔓 小写 | 英
- 复制提示：显示复制的字符数/图片/文件数
- 右键托盘图标可打开设置窗口

**文件结构**：
```
AllInOneNotification.ahk  - 主脚本
AllInOneNotification.exe  - 编译后的可执行文件
config.ini                - 用户配置（自动生成）
```

---

## 编译命令

```bash
rm -f /d/Desktop/test/AllInOneNotification.exe && \
"/c/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" \
  //in "D:\\Desktop\\test\\AllInOneNotification.ahk" \
  //out "D:\\Desktop\\test\\AllInOneNotification.exe" \
  //base "C:\\Program Files\\AutoHotkey\\v2\\AutoHotkey64.exe" \
  //compress 0
```

> ⚠️ 在 Git Bash 下必须用 `//` 双斜杠，单斜杠会被吃掉

**编译流程**：
1. 修改代码后，先让用户测试 `.ahk` 脚本
2. 用户确认没问题后，再执行编译
3. 不要自作主张提前编译

---

## 开发笔记

### SendMessage 权限问题

访问某些窗口的 IME 状态时会报"拒绝访问"，需要 try-catch 保护：

```autohotkey
try {
    result := SendMessage(0x283, 0x005, 0, , "ahk_id " . hIMEWnd)
} catch {
    return "?"
}
```

### GUI 输入框验证时机

不要在 `OnEvent("Change")` 中实时验证，会导致退格键无法正常删除。

**错误做法**：
```autohotkey
capsEdit.OnEvent("Change", (*) => capsEdit.Value := Max(100, capsEdit.Value))
```

**正确做法**：在保存时验证
```autohotkey
SaveAndClose(*) {
    capsShowDuration := Max(100, Integer(capsEdit.Value || 800))
}
```

### GUI 控件初始值设置

`Gui.Add()` 不支持第四个参数设置初始值，需要先创建再设置 `.Value`：

**错误做法**：
```autohotkey
capsCheck := settingsGui.Add("CheckBox", "x20 y30", "大小写提示", enableCapsTip)
```

**正确做法**：
```autohotkey
capsCheck := settingsGui.Add("CheckBox", "x20 y30", "大小写提示")
capsCheck.Value := enableCapsTip
```

### GUI 窗口位置更新（避免闪烁和偏移）

更新 GUI 窗口位置时，不能用 `Show("NA AutoSize")` + `Move()`，会导致位置累积偏移。

**错误做法**：
```autohotkey
tipGui.Show("NA AutoSize")  ; 先显示
tipGui.GetPos(,, &gw, &gh)
tipGui.Move(gx, gy)         ; 再移动 - 会累积偏移！
```

**正确做法**：用 WM_SETREDRAW 禁用重绘，隐藏获取尺寸，直接定位显示
```autohotkey
SendMessage(0xB, 0, 0, , "ahk_id " . tipGui.Hwnd)  ; 禁用重绘
tipGui.Show("Hide AutoSize")                        ; 隐藏状态下获取尺寸
tipGui.GetPos(,, &gw, &gh)
tipGui.Show("x" . gx . " y" . gy . " NA")           ; 直接定位显示
SendMessage(0xB, 1, 0, , "ahk_id " . tipGui.Hwnd)  ; 启用重绘
```

### GUI 窗口有效性检查

`IsObject(tipGui)` 在 GUI 销毁后仍返回 true，需要同时检查窗口是否存在：

**错误做法**：
```autohotkey
if (IsObject(tipGui)) {  ; GUI 销毁后仍为 true！
```

**正确做法**：
```autohotkey
if (IsObject(tipGui) && WinExist("ahk_id " . tipGui.Hwnd)) {
```

### GUI 设置即时生效

修改字体等设置后，需要销毁旧的 GUI 才能在下次显示时应用新设置：

```autohotkey
ApplySettings() {
    ; ... 其他设置 ...

    ; 销毁旧的提示窗口，让下次显示时重新创建
    if (IsObject(tipGui)) {
        tipGui.Destroy()
        tipGui := ""
    }
}
```

### static 控件引用问题

`static tipText` 保留的是控件引用，GUI 销毁后引用失效。配合窗口有效性检查使用，或在重建 GUI 时重新赋值。
