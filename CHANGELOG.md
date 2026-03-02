# Changelog

All notable changes to CapsCopyTip will be documented in this file.

## [1.3.0] - 2026-03-03

### Added
- ✨ 内置 CaretIndicator 光标指示器（在文本光标旁显示语言状态）
- ✨ 设置界面添加"显示中/英状态"开关（依赖大小写提示）
- 🖼️ 添加应用图标（macOS Big Sur 风格）

### Changed
- 🖼️ 优化设置窗口布局
- ♻️ 整理项目目录结构（archive/ 存放历史版本，assets/ 存放资源文件）
- ⚙️ 更新 .gitignore 忽略项目规则文件

### Fixed
- 🐛 修复 Shift 键触发逻辑，排除组合键干扰
- 🐛 使用正确的 Stop() 方法停止光标指示器

## [1.1.0] - 2026-03-02

### Added
- ✨ 设置界面添加 GitHub 链接
- ⚙️ 添加鼠标偏移距离设置（`tipMouseOffset`，默认 2 像素）
- ⚙️ 添加版本号全局变量 `VERSION` 统一管理
- 🖥️ 添加开机启动功能
- 🔄 添加恢复默认设置按钮

### Changed
- 🏷️ 项目重命名为 CapsCopyTip（原 AllInOneNotification）
- 🎨 字体默认大小改为 9（原 14）
- 🎨 字体默认加粗改为 true

### Fixed
- 🐛 修复提示窗口闪烁问题（使用 WM_SETREDRAW）
- 🐛 修复跟随鼠标时位置越来越远的问题
- 🐛 修复设置保存后不即时生效的问题
- 🐛 修复"设置已保存"提示不消失的问题
- 🐛 修复屏幕中央位置设置不热加载的问题
- 🐛 修复 IME 状态查询权限错误问题

## [1.0.0] - 2026-02-XX

### Added
- ✨ 大小写提示功能（CapsLock 状态检测）
- ✨ 输入法中/英状态显示
- ✨ 复制提示功能（字符数/图片/文件数）
- ✨ 托盘菜单（设置、重启、退出）
- ✨ 设置窗口（功能开关、显示时长、提示位置、字体样式）
- ✨ 配置文件持久化（config.ini）
