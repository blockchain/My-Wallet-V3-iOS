// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureDex",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
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
            exact: "0.52.0"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Analytics"),
        .package(path: "../DelegatedSelfCustody"),
        .package(path: "../Errors"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureDexDomain",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DelegatedSelfCustodyDomain", package: "DelegatedSelfCustody"),
                .product(name: "MoneyKit", package: "Money")
            ],
            path: "Sources/Domain"
        ),
        .target(
            name: "FeatureDexData",
            dependencies: [
                .target(name: "FeatureDexDomain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DIKit", package: "DIKit"),
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
                .target(name: "FeatureDexData"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DelegatedSelfCustodyDomain", package: "DelegatedSelfCustody"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents")
            ],
            path: "Sources/UI"
        )
    ]
)
