# Shortcuts 兼容性指南 / Shortcuts Compatibility Guide

## 答案：是的，这个代码可以在 Shortcuts（快捷指令）中运行

**YES, this code CAN run in Apple Shortcuts!**

## 现状 / Current Status

这个项目已经是一个完整的 App Intents 实现，专门设计用于 Apple Shortcuts 集成。

### ✅ 已经兼容 Shortcuts 的功能

1. **正确的 App Intents 实现**
   - 使用 `AppIntents` 框架
   - `ProcessScreenshotIntent` 实现了 `AppIntent` 协议
   - 正确定义了参数：`@Parameter(title: "截图文件")` 和 `@Parameter(title: "当前日期")`
   - 返回正确的结果类型：`IntentResult & ReturnsValue<[URL]>`

2. **完整的功能流程**
   - OCR 文字识别（基于 Vision 框架）
   - GPT API 调用解析待办事项
   - Notion API 集成创建任务
   - 安全的密钥管理（Keychain）

3. **本地化支持**
   - 中文界面文本
   - 支持中文和英文 OCR 识别

## 在 Shortcuts 中使用的步骤

### 1. 构建 iOS 应用

由于这是一个 App Intents 扩展，您需要：

1. 在 Xcode 中创建 iOS 应用项目
2. 将 `AppIntents` 文件夹中的代码添加到项目
3. 配置正确的 Info.plist（已提供）
4. 在真实设备或模拟器上构建并安装应用

### 2. 配置 API 密钥

在应用首次运行后，需要将以下密钥存储在系统钥匙串中：

```
gpt_api_key              - GPT API 密钥
gpt_endpoint             - GPT API 端点
gpt_model                - GPT 模型名称
notion_token             - Notion 集成令牌
notion_data_source_id    - Notion 数据库 ID
notion_pages_endpoint    - Notion 页面 API 端点
notion_api_version       - Notion API 版本
```

### 3. 在 Shortcuts 中使用

1. 打开 Shortcuts 应用
2. 搜索 "OCR 截图并同步到 Notion"
3. 创建快捷指令流程：
   ```
   获取最新屏幕截图 → OCR 截图并同步到 Notion → 处理返回的 URL
   ```

## 项目结构

```
OcrToNotion/
├── AppIntents/
│   ├── Models/
│   │   └── TodoItem.swift           # 数据模型
│   ├── Services/
│   │   ├── OCRService.swift         # OCR 服务
│   │   ├── GPTService.swift         # GPT API 服务
│   │   ├── NotionService.swift      # Notion API 服务
│   │   └── JSONDecoder+yyyyMMdd.swift
│   └── ProcessScreenshotIntent.swift # 主要的 App Intent
├── Info.plist                      # 应用配置
├── OcrToNotionApp.swift            # 应用入口
├── ContentView.swift               # 用户界面
└── Package.swift                   # Swift Package 定义
```

## 技术要求

- iOS 17.0+
- Xcode 15.0+
- 真实设备（用于完整测试）

## 常见问题

**Q: 为什么不能在 Linux 上构建？**
A: AppIntents 是 iOS 专有框架，只能在 macOS/iOS 环境下构建。

**Q: 如何在 Shortcuts 中调试？**
A: 使用 Xcode 的 Console 应用查看设备日志，或在代码中添加 `print()` 语句。

**Q: 可以直接使用吗？**
A: 需要先配置 GPT 和 Notion API 密钥，然后在 iOS 设备上安装应用。

## 总结

这个代码**完全可以**在 Apple Shortcuts 中运行。它是一个专门为 Shortcuts 设计的 App Intents 扩展，提供了从截图识别到 Notion 任务创建的完整自动化流程。