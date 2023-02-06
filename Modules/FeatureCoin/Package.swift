// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureCoin",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "FeatureCoin", targets: [
            "FeatureCoinDomain",
            "FeatureCoinUI",
            "FeatureCoinData"
        ]),
        .library(name: "FeatureCoinDomain", targets: ["FeatureCoinDomain"]),
        .library(name: "FeatureCoinUI", targets: ["FeatureCoinUI"]),
        .library(name: "FeatureCoinData", targets: ["FeatureCoinData"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.42.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.11.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Localization"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Tool"),
        .package(path: "../Test"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureCoinDomain",
            dependencies: [
                .product(
                    name: "MoneyKit",
                    package: "Money"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "BlockchainNamespace",
                    package: "BlockchainNamespace"
                )
            ]
        ),
        .target(
            name: "FeatureCoinData",
            dependencies: [
                .target(
                    name: "FeatureCoinDomain"
                ),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "MoneyKit",
                    package: "Money"
                )
            ]
        ),
        .target(
            name: "FeatureCoinUI",
            dependencies: [
                .target(name: "FeatureCoinDomain"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "BlockchainNamespace",
                    package: "BlockchainNamespace"
                ),
                .product(
                    name: "AnalyticsKit",
                    package: "Analytics"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "ToolKit",
                    package: "Tool"
                ),
                .product(
                    name: "MoneyKit",
                    package: "Money"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "ComposableArchitectureExtensions",
                    package: "ComposableArchitectureExtensions"
                ),
                .product(
                    name: "UIComponents",
                    package: "UIComponents"
                )
            ]
        ),
        .testTarget(
            name: "FeatureCoinDomainTests",
            dependencies: [
                .target(name: "FeatureCoinDomain"),
                .product(
                    name: "TestKit",
                    package: "Test"
                )
            ]
        ),
        .testTarget(
            name: "FeatureCoinDataTests",
            dependencies: [
                .target(name: "FeatureCoinData")
            ]
        ),
        .testTarget(
            name: "FeatureCoinUITests",
            dependencies: [
                .target(name: "FeatureCoinUI"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: [
                "CoinView/__Snapshots__"
            ]
        )
    ]
)
