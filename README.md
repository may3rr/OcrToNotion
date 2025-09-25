# OcrToNotion App Intents

**✅ 这个代码可以在 Apple Shortcuts（快捷指令）中运行！**

一个完整的 App Intents 扩展，专门为 Apple Shortcuts 设计，可以在 iOS / iPadOS 上通过快捷指令完成以下自动化流程：

1. 获取最近截图并进行 OCR 文本识别。
2. 调用配置的 GPT 模型将截图内容解析为 JSON 格式的任务。
3. 将任务同步创建到指定的 Notion 数据库中。

> 📱 **Shortcuts 兼容性**: 详细的使用指南请查看 [SHORTCUTS_COMPATIBILITY.md](SHORTCUTS_COMPATIBILITY.md)

## 目录结构

```
AppIntents/
├── Models/
│   └── TodoItem.swift           # LLM 输出 JSON 的数据模型
├── Services/
│   ├── GPTService.swift         # 封装 gpt-5-nano API 调用
│   ├── JSONDecoder+yyyyMMdd.swift
│   ├── NotionService.swift      # 将任务写入 Notion 的网络层
│   └── OCRService.swift         # 基于 Vision 的 OCR
└── ProcessScreenshotIntent.swift # 组合整个流程的 App Intent
```

## 快捷指令运行流程

1. **触发方式**：将快捷指令绑定到轻点背面或 Action Button。
2. **获取截图**：使用快捷指令内置动作「获取最近的屏幕快照」。
3. **OCR**：将截图文件传给本项目提供的 `ProcessScreenshotIntent`。
4. **LLM 解析**：App Intent 在后台调用 gpt-5-nano，输出合法 JSON。
5. **Notion 写入**：根据 JSON 自动在 Notion 数据库中创建任务并返回任务链接。

## App Intent 参数

| 参数         | 类型        | 说明                                 |
|--------------|-------------|--------------------------------------|
| `screenshot` | `IntentFile`| 快捷指令传入的截图文件               |
| `currentDate`| `Date`      | 便于 LLM 解析自然语言日期的参考日期 |

App Intent 的返回值为一个 `URL` 数组，表示在 Notion 中创建的任务页面地址。

## 依赖与框架

* **Vision**：完成截图的文字识别。
* **AppIntents**：定义快捷指令可调用的 Intent。
* **Security**：从 Keychain 中读取敏感凭据。
* **Foundation / URLSession**：访问远程 API。

请确保在 `Info.plist` 中为 App Intents 扩展增加对网络访问的 `NSAppTransportSecurity` 配置（如果调用的 API 非 HTTPS，需要额外豁免）。

## 密钥管理

敏感信息不会硬编码在源码中。`Secrets` 结构体通过 `KeychainHelper` 从系统钥匙串读取下列键值：

| Keychain Key               | 说明                                       |
|---------------------------|--------------------------------------------|
| `gpt_api_key`             | GPT 服务的 API Token                       |
| `gpt_endpoint`            | GPT Chat Completions Endpoint（例如 `https://api.gpt.ge/v1/chat/completions`） |
| `gpt_model`               | 调用的模型名称（例如 `gpt-5-nano`）        |
| `notion_token`            | Notion 集成的 Access Token                 |
| `notion_data_source_id`   | Notion 数据源 ID                           |
| `notion_pages_endpoint`   | Notion 创建页面的 Endpoint（例如 `https://api.notion.com/v1/pages`） |
| `notion_api_version`      | Notion API 版本号（例如 `2025-09-03`）     |

建议在 App 内提供调试界面或使用配置描述文件，将用户提供的密钥与 Endpoint/版本信息写入 Keychain。

## 错误处理

* `OCRService` 在无法识别截图时会抛出 `OCRServiceError`。
* `GPTService`/`NotionService` 对非 2xx HTTP 状态抛出 `invalidResponse`。
* `Secrets` 在缺失凭据时抛出 `SecretsError.missingKey`，可在快捷指令中捕获并提示用户。

## 与快捷指令集成

1. 在 Xcode 中为 iOS 17+ 目标创建带 App Intents Extension 的项目，将上述源码放入扩展目标。
2. 在 `AppIntents` 文件夹中注册 `ProcessScreenshotIntent`。编译后，快捷指令应用会自动发现新的 Intent。
3. 在快捷指令中串联动作：
   - 获取最近的屏幕快照
   - 调用 `OCR 截图并同步到 Notion`（传入截图与当前日期）
   - 对返回的链接进行后续处理（例如打开或通知）。

## 可选优化

* 为 LLM 请求添加重试策略或温度调节参数。
* 将 `generateTodos` 改为流式解析，处理大段文本。
* 在 Notion 返回失败时记录日志并提示用户。

## 隐私提醒

请勿将真实的 API Key 和 Token 保存在版本控制中。建议通过 CI 注入或在运行时由用户输入后写入 Keychain。
