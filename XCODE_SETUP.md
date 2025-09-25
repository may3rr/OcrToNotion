# Xcode Project Setup Instructions

## 快速设置指南 / Quick Setup Guide

### 1. 创建新的 iOS 应用项目

1. 打开 Xcode
2. 选择 "Create a new Xcode project"
3. 选择 iOS → App
4. 填写项目信息：
   - Product Name: `OcrToNotion`
   - Bundle Identifier: `com.yourname.OcrToNotion`
   - Language: Swift
   - Interface: SwiftUI
   - Minimum Deployment: iOS 17.0

### 2. 添加源文件

1. 将 `AppIntents/` 文件夹拖入 Xcode 项目
2. 添加 `OcrToNotionApp.swift` 和 `ContentView.swift`
3. 替换默认的 `Info.plist` 文件

### 3. 配置项目设置

1. **Target Settings**:
   - Deployment Target: iOS 17.0+
   - Supported Device Families: iPhone, iPad

2. **Build Settings**:
   - Enable App Intents: YES
   - Swift Language Version: Swift 5

3. **Capabilities** (Signing & Capabilities):
   - App Groups (如果需要)
   - Keychain Sharing (推荐)

### 4. Info.plist 配置

确保 Info.plist 包含以下配置（已包含在提供的文件中）：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 5. 构建和安装

1. 选择真实设备或模拟器
2. 运行项目 (⌘+R)
3. 应用安装后，App Intents 会自动注册到 Shortcuts

### 6. 在 Shortcuts 中使用

1. 打开 Shortcuts 应用
2. 搜索 "OCR 截图并同步到 Notion"
3. 添加到您的快捷指令中

## 故障排除

**如果在 Shortcuts 中找不到 Intent：**
1. 确保应用已在设备上运行至少一次
2. 检查 iOS 版本是否为 17.0+
3. 重启 Shortcuts 应用

**如果遇到权限错误：**
1. 确保已配置 Keychain 密钥
2. 检查网络访问权限
3. 验证 API 端点和密钥的正确性