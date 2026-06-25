---
name: caps-build
description: 编译 CursorTip AHK 脚本为 EXE，并在用户说"可以发行了"时执行 GitHub Release 发行流程。当用户说"编译"、"打包"、"构建"、"生成exe"、"封装成exe"时使用编译流程；说"可以发行了"、"发布到 GitHub"、"创建 Release"时使用发行流程。
---

# CursorTip 编译与发行

将 `CursorTip.ahk` 编译为带图标的 EXE 可执行文件，并在用户确认后执行 GitHub Release 发行。

## Instructions

### Step 1: 前置检查

编译前你应该先确认环境和文件是否就绪。任何一项缺失都要先停止，并明确告知用户缺了什么：

1. **检查 `CursorTip.ahk` 是否存在**
   - 确认项目根目录有 `CursorTip.ahk`。

2. **检查 Ahk2Exe 编译器**
   - 默认路径：`C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe`
   - 如果不存在，提示用户安装 AutoHotkey v2（安装包自带 Ahk2Exe）。

3. **检查 AutoHotkey v2 基文件**
   - 默认路径：`C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
   - 这是 `/base` 参数需要的文件。

4. **检查主图标资源**
   - 脚本里的 `;@Ahk2Exe-SetMainIcon` 指向：
     ```
     assets\app.ico
     ```
   - 确认该文件存在，否则编译后的 exe 没有图标。

5. **检查 `FileInstall` 引用的资源**
   - 当前脚本通过 `FileInstall("assets\github.ico", ...)` 嵌入设置窗口的 GitHub 图标。
   - 确认 `assets\github.ico` 存在。

### Step 2: 读取版本号并判断是否需要递增

#### 2.1 读取当前版本号

你应该读取 `CursorTip.ahk` 中的当前版本号：

```autohotkey
global VERSION := "1.0.1"
```

用正则提取 `"x.y.z"` 的内容，用于后续递增判断。

**不要自动递增版本号**。版本号由 git 提交时管理，编译只使用当前值。

#### 2.2 用户要求递增时的判断流程

仅当用户**明确要求**更新版本号（如"更新版本号"、"递增版本"、"打包发布"）时，你才需要判断本次该递增多少。**判断范围只限于 `CursorTip.ahk` 主脚本的变更**，网站、CSS、文档、README、skill 文件等变更不参与版本号判断。

判断步骤：

1. **找到上一个版本节点**
   ```bash
   git log -S 'VERSION := "X.Y.Z"' --oneline -- CursorTip.ahk
   ```
   取最近一次修改 `VERSION` 的提交，这就是上一个版本发布节点。

2. **列出该节点到 HEAD 之间修改过 `CursorTip.ahk` 的提交**
   ```bash
   git log <上一个版本提交>..HEAD --oneline -- CursorTip.ahk
   ```

3. **按保守 semver 规则判断递增级别**

   | 级别 | 触发条件 | 保守原则 |
   |:---|:---|:---|
   | **MAJOR** | 删除功能、配置格式变更、系统要求改变、明确破坏用户现有行为 | 必须有 `BREAKING CHANGE`、`-范围!:` 或明确证据才升 |
   | **MINOR** | 新增用户可感知功能：新设置项、新交互、新支持场景 | 只有 `feat` 且确实增加功能才升，不确定时不升 |
   | **PATCH** | bugfix、重构、性能优化、样式调整、UI 微调 | **默认选项**，拿不准就 PATCH |

4. **向用户汇报并确认**
   你需要列出分析结果：
   - 上一个版本提交和版本号
   - 期间修改 `CursorTip.ahk` 的提交列表
   - 建议的新版本号及理由
   等用户明确回复「确认」或给出具体版本号后，再修改 `CursorTip.ahk` 中的 `VERSION`。

#### 2.3 递增后同步版本号

用户确认后，按标准 semver 更新 `CursorTip.ahk`：

- `1.0.1` → `1.0.2`（PATCH）
- `1.0.9` → `1.1.0`（MINOR）
- `1.9.9` → `2.0.0`（MAJOR）

### Step 3: 检查资源文件嵌入

编译前你必须确认脚本中的外部资源文件（图标、图片等）已通过 `FileInstall` 嵌入：

```autohotkey
; 正确：FileInstall 将文件嵌入 exe，运行时释放到临时目录
icoPath := A_Temp . "\CursorTip_github.ico"
FileInstall("assets\github.ico", icoPath, 1)
pic := g.Add("Picture", "x20 y500 w16 h16", icoPath)

; 错误：相对路径在编译后找不到文件
pic := g.Add("Picture", "x20 y500 w16 h16", "assets/github.ico")

; 错误：A_ScriptDir 拼接在 exe 单独运行时可能找不到 assets 目录
pic := g.Add("Picture", "x20 y500 w16 h16", A_ScriptDir . "\assets\github.ico")
```

**规则**：任何 GUI 控件引用的外部资源文件（ico/png/jpg 等），必须用 `FileInstall` 嵌入，不能依赖相对路径或 `A_ScriptDir` 拼接。

### Step 4: 执行编译

`CursorTip.ahk` 已经通过以下指令指定了主图标：

```autohotkey
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\app.ico
```

因此编译命令**不需要**再传 `//icon`。

编译产物输出到 `dist/` 目录，文件名带版本号以保留历史本体，如 `CursorTip_v1.0.1.exe`。

编译前你应该先确认 `dist/` 目录存在；如果不存在，先创建：

```bash
mkdir -p dist
```

执行编译（用读取到的实际版本号替换 `{版本号}`）：

```bash
"/c/Program Files/AutoHotkey/Compiler/Ahk2Exe.exe" \
  //in "<项目目录>\\CursorTip.ahk" \
  //out "<项目目录>\\dist\\CursorTip_v{版本号}.exe" \
  //base "C:\\Program Files\\AutoHotkey\\v2\\AutoHotkey64.exe" \
  //compress 0
```

**关键注意事项**：
- Ahk2Exe 的参数前缀在 Git Bash 下必须用 `//` 双斜杠，单斜杠会被 shell 吞掉
- `//in`、`//out`、`//base`、`//compress` 都是双斜杠
- 项目目录中的反斜杠路径要用 `\\` 转义（因为 Ahk2Exe 是 Windows 原生程序）
- `//compress 0` 不压缩，避免杀毒误报

### Step 5: 打开资源管理器

编译成功后，你应该自动打开 `dist/` 目录的资源管理器：

```bash
explorer "$(cd dist && pwd -W)"
```

这样用户可以立即看到编译产物，无需手动去找。

### Step 6: 确认结果

编译成功后会输出 `Successfully compiled as: ...`，你应该确认 EXE 已生成，并报告：

- 输出文件路径：`dist/CursorTip_v{版本号}.exe`（如 `dist/CursorTip_v1.0.1.exe`）
- 资源管理器已自动打开到 `dist/`

## Examples

**用户说："帮我编译一下"**
1. 前置检查：确认 Ahk2Exe、AutoHotkey64、资源文件都存在
2. 读取当前版本号 `1.0.1`
3. 检查资源文件是否都已 `FileInstall` 嵌入
4. 确认 `dist/` 目录存在
5. 编译输出为 `dist/CursorTip_v1.0.1.exe`
6. 打开资源管理器到 `dist/`
7. 报告结果

**用户说："打包发布" 或 "编译，更新版本号"**
1. 前置检查：确认 Ahk2Exe、AutoHotkey64、资源文件都存在
2. 读取当前版本号 `1.0.1`
3. 分析 `1.0.1` 到 `HEAD` 之间修改 `CursorTip.ahk` 的提交，发现只有 1 个 UI fix：修正按钮顺序和默认按钮
4. 按保守规则判断为 PATCH，建议 `1.0.1 → 1.0.2`
5. 用户确认后，更新 `CursorTip.ahk` 中的 `VERSION`
6. 检查资源文件是否都已 `FileInstall` 嵌入
7. 确认 `dist/` 目录存在
8. 编译输出为 `dist/CursorTip_v1.0.2.exe`
9. 打开资源管理器到 `dist/`
10. 报告结果

---

## 发行流程

仅当用户明确说「可以发行了」时，才执行以下发行流程。发行不会自动触发，必须等用户确认。

### Step R1: 前置检查

发行前你应该确认：

1. **EXE 已编译** — 确认 `dist/CursorTip_v{版本号}.exe` 存在。如果不存在，先提示用户执行编译。
2. **版本号已更新** — 确认 `CursorTip.ahk` 中的 `VERSION` 是本次发行的目标版本号。
3. **工作区干净** — 确认 `CursorTip.ahk` 的改动已提交（`git status -- CursorTip.ahk` 无未提交变更），避免发行的代码与 git 不一致。

发行产物是一个压缩包 `CursorTip_v{版本号}.zip`，包含：
- `CursorTip_v{版本号}.exe`（编译本体）
- `README.txt`（面向用户的中英文说明）

### Step R2: 生成更新日志

你应该从 git 提交记录中提取本次版本的变更，按以下格式生成更新日志。

#### 提取变更

从上一个版本提交到当前 `HEAD`，只看修改 `CursorTip.ahk` 的提交：

```bash
git log <上一个版本提交>..HEAD --oneline -- CursorTip.ahk
```

将提交按类型分类：

| 提交前缀 | 归属类别 |
|:---|:---|
| `feat` | ✨ 新增功能 |
| `fix` | 🐞 修复问题 |
| `refactor`、`perf`、`style`、`chore` | 🚀 优化改进 |
| `docs`、`test`、`ci` | 不列入更新日志 |

#### 写更新日志

按照历史发行格式（参考 v1.0.1），面向用户而非开发者：

```markdown
## vX.Y.Z

一句话概述本次版本重点（可选）。

### ✨ 新增功能
- 面向用户的描述（从 feat 提交提炼，用用户能理解的语言）

### 🐞 修复问题
- 修复了 XXX（从 fix 提交提炼）

### 🚀 优化改进
- 优化了 XXX（从 refactor/perf/style/chore 提交提炼）
```

**写法要求**：
- 每条用 `- ` 短横线列表
- 用面向用户的语言，不要用 commit message 原文
- 类别可以为空（某类没有提交就省略该栏）
- emoji 前缀固定：`✨`、`🐞`、`🚀`

#### 展示给用户确认

将生成的更新日志展示给用户，等用户确认或修改后再继续。

### Step R2b: 生成面向用户的 README

发行包里的 `README.txt` 是面向用户的简明说明，不是项目的开发文档 `README.md`。

你应该生成一份中英文双语的 `README.txt`，内容包括：

```text
CursorTip vX.Y.Z
================

轻量级 Windows 桌面状态提示工具
A lightweight Windows desktop status indicator

功能 / Features
----------------
- 大小写 + 输入法状态实时提示 / Caps Lock + IME state indicator
- 复制操作即时反馈（字符数/图片/文件数）/ Copy feedback (chars/image/files)
- 中英文双语界面 / Bilingual interface (Chinese / English)
- 支持跟随鼠标、屏幕中央、顶部、底部等位置 / Multiple tip positions
- 开机自启 / Run at startup

使用 / Usage
------------
1. 双击运行 CursorTip.exe，托盘图标出现即可使用
   Double-click CursorTip.exe to run. Tray icon appears when ready.
2. 右键托盘图标打开设置
   Right-click tray icon for settings.

系统要求 / Requirements
----------------------
- Windows 10 / 11

本版本更新 / What's New (vX.Y.Z)
---------------------------------
（此处填入 Step R2 生成的更新日志内容，去掉 markdown 格式）

许可 / License
--------------
MIT
```

**要求**：
- 版本号和更新日志内容必须是本次发行的实际值
- 更新日志部分去掉 markdown 标记（`#`、`-` 前缀可保留），保持纯文本
- 生成后写入 `dist/README.txt`

### Step R3: 提交版本号更新（如未提交）

如果版本号已更新且尚未提交，先提交：

```bash
git add CursorTip.ahk
git commit -m "chore: bump version to vX.Y.Z"
```

### Step R4: 打包压缩包

将编译本体和用户说明打包为一个压缩包：

```bash
cd dist && zip CursorTip_v{版本号}.zip CursorTip_v{版本号}.exe README.txt
```

打包完成后确认 `dist/CursorTip_v{版本号}.zip` 存在且包含两个文件。

### Step R5: 创建 GitHub Release

通过 GitHub MCP 创建 Release：

- **Tag**: `v{版本号}`
- **Name**: `CursorTip v{版本号}`
- **Body**: Step R2 中用户确认的更新日志内容（GitHub Release 页面展示）
- **Asset**: 上传 `dist/CursorTip_v{版本号}.zip`（用户实际下载的压缩包）

使用 `mcp__github__create_repository_release` 或对应工具创建。

### Step R6: 推送

将本地提交和 tag 推送到远程：

```bash
git push origin main
git push origin v{版本号}
```

### Step R7: 确认发行完成

报告：
- Release 链接：`https://github.com/zeno528/CursorTip/releases/tag/v{版本号}`
- 压缩包附件是否上传成功
- 本地与远程是否同步

---

## 发行流程示例

**用户说："可以发行了"**

假设当前版本 `1.0.1`，编译产物 `dist/CursorTip_v1.0.2.exe` 已存在：

1. 确认 `dist/CursorTip_v1.0.2.exe` 存在，`CursorTip.ahk` 中 `VERSION` 已是 `1.0.2`，工作区干净
2. 分析 `1.0.1` 到 `HEAD` 之间修改 `CursorTip.ahk` 的提交，生成更新日志：

   ```markdown
   ## v1.0.2

   ### 🐞 修复问题
   - 修复设置界面按钮顺序不合理，将「保存」移至最后并设为默认按钮
   ```

3. 展示更新日志给用户确认
4. 生成 `dist/README.txt`（面向用户的中英文说明，含本版本更新日志）
5. 提交版本号（如未提交）
6. 打包 `dist/CursorTip_v1.0.2.zip`（含 EXE + README.txt）
7. 创建 GitHub Release，上传压缩包
8. 推送提交和 tag
9. 报告发行完成及 Release 链接
