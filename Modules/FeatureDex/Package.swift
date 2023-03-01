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
            targets: ["FeatureDexDomain", "FeatureDexData", "FeatureDexUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.42.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../Errors"),
        .package(path: "../Localization"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureDexDomain",
            dependencies: [
                .product(name: "MoneyKit", package: "Money")
            ],
            path: "Sources/Domain"
        ),
        .target(
            name: "FeatureDexData",
            dependencies: [
                .target(name: "FeatureDexDomain"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "NetworkKit", package: "Network")
            ],
            path: "Sources/Data"
        ),
        .target(
            name: "FeatureDexUI",
            dependencies: [
                .target(name: "FeatureDexDomain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents")
            ],
            path: "Sources/UI"
        )
    ]
)
