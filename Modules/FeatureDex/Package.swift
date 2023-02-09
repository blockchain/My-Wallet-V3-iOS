// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureDex",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureDex",
            targets: ["DexDomain", "DexData", "DexUI"]
        ),
        .library(
            name: "DexDomain",
            targets: ["DexDomain"]
        ),
        .library(
            name: "DexData",
            targets: ["DexData"]
        ),
        .library(
            name: "DexUI",
            targets: ["DexUI"]
        )
    ],
    dependencies: [
        .package(path: "../Analytics"),
        .package(path: "../Errors"),
        .package(path: "../Localization"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "DexDomain",
            dependencies: [
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "DexData",
            dependencies: [
                .target(name: "DexDomain"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "DexUI",
            dependencies: [
                .target(name: "DexDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool")
            ]
        )
    ]
)
