// swift-tools-version: 5.9
// 注意：此项目需要在 iOS 设备或模拟器上构建，因为它依赖于 AppIntents 框架
// This project requires building on iOS device/simulator as it depends on AppIntents framework

import PackageDescription

let package = Package(
    name: "OcrToNotion",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "OcrToNotionAppIntents",
            targets: ["OcrToNotionAppIntents"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OcrToNotionAppIntents",
            dependencies: [],
            path: "AppIntents",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
    ]
)