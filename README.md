# Lightroom Classic HEIC (HDR) 导出插件

这是一个专为 macOS 上的 Lightroom Classic 用户设计的高性能导出插件。它旨在解决 Lightroom 原生导出对 HEIC (HEIF) 格式支持的不足，并特别针对 HDR (高动态范围) 照片进行了深度优化。

## 🌟 核心特性

- **16位 Display P3 转换管线**：完美承载 Lightroom PV3 引擎的 HDR 亮度数据，确保从 RAW 到 HEIC 的 100% 色彩与动态还原。
- **自动垃圾回收 (Garbage Collection)**：利用 Lightroom 底层架构，在转码完成后由系统自动清理数以 GB 计的中间 TIFF 文件，保持磁盘整洁。
- **macOS 原生硬件加速**：直接驱动 Apple 芯片中的媒体处理引擎 (Media Engine) 与 GPU，享受系统级、极速的 HEIC 编码体验。
- **无缝 UI 集成**：精读并适配了 Lightroom Export Service 架构，像原生功能一样内嵌在导出界面的“导出到”菜单中。
- **简体中文本地化**：硬编码中文 UI，提供最直观的操作体验。

## 🚀 快速开始

1. **下载或克隆**此仓库到您的 Mac 上。
2. 打开 Lightroom Classic，前往 **文件 -> 插件管理器**。
3. 点击 **添加 (Add)**，并选择 `HEICExport.lrdevplugin` 文件夹。
4. 在“导出”对话框顶部的 **“导出到 (Export To)”** 下拉菜单中选择 **“HEIC 导出 (HDR)”**。
5. (可选) 在导出面板中调整 **HEIC 压缩质量**。
6. 点击 **导出**，选择目标文件夹，即可完成转码。

## 🛠️ 技术要求

- **操作系统**：macOS 14 (Sonoma) 或更高版本 (依赖原生 `sips` 功能)。
- **硬件**：推荐使用 Apple Silicon (M1/M2/M3) 系列芯片以获得最佳转码性能。
- **软件**：Lightroom Classic v13.0 或更高版本。

## 📄 许可说明

本项目采用 MIT 许可证。
