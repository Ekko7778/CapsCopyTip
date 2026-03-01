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
