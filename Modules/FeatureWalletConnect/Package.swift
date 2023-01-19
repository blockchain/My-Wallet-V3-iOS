// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureWalletConnect",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureWalletConnect",
            targets: [
                "FeatureWalletConnectDomain",
                "FeatureWalletConnectData",
                "FeatureWalletConnectUI"
            ]
        ),
        .library(
            name: "FeatureWalletConnectDomain",
            targets: ["FeatureWalletConnectDomain"]
        ),
        .library(
            name: "FeatureWalletConnectData",
            targets: ["FeatureWalletConnectData"]
        ),
        .library(
            name: "FeatureWalletConnectUI",
            targets: ["FeatureWalletConnectUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.42.0"
        ),
        .package(
            url: "https://github.com/WalletConnect/WalletConnectSwift.git",
            exact: "1.7.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../Localization"),
        .package(path: "../UIComponents"),
        .package(path: "../CryptoAssets"),
        .package(path: "../Platform"),
        .package(path: "../WalletPayload"),
        .package(path: "../Metadata")
    ],
    targets: [
        .target(
            name: "FeatureWalletConnectDomain",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "EthereumKit", package: "CryptoAssets"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "WalletConnectSwift", package: "WalletConnectSwift")
            ]
        ),
        .target(
            name: "FeatureWalletConnectData",
            dependencies: [
                .target(name: "FeatureWalletConnectDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "EthereumKit", package: "CryptoAssets"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "WalletConnectSwift", package: "WalletConnectSwift"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "MetadataKit", package: "Metadata")
            ]
        ),
        .target(
            name: "FeatureWalletConnectUI",
            dependencies: [
                .target(name: "FeatureWalletConnectDomain"),
                .target(name: "FeatureWalletConnectData"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        )
    ]
)
