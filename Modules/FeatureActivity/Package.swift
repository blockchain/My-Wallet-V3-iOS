// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureActivity",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureActivity",
            targets: ["FeatureActivityDomain", "FeatureActivityUI", "FeatureActivityData"]
        ),
        .library(
            name: "FeatureActivityDomain",
            targets: ["FeatureActivityDomain"]
        ),
        .library(
            name: "FeatureActivityData",
            targets: ["FeatureActivityData"]
        ),
        .library(
            name: "FeatureActivityUI",
            targets: ["FeatureActivityUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.5.0"
        ),
        .package(
            url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
            from: "5.0.2"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Analytics"),
        .package(path: "../CryptoAssets"),
        .package(path: "../Errors"),
        .package(path: "../Localization"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Platform"),
        .package(path: "../RxTool"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureActivityDomain",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxToolKit", package: "RxTool")
            ]
        ),
        .target(
            name: "FeatureActivityData",
            dependencies: [
                .target(name: "FeatureActivityDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureActivityUI",
            dependencies: [
                .target(name: "FeatureActivityDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BitcoinCashKit", package: "CryptoAssets"),
                .product(name: "BitcoinKit", package: "CryptoAssets"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "ERC20Kit", package: "CryptoAssets"),
                .product(name: "EthereumKit", package: "CryptoAssets"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "StellarKit", package: "CryptoAssets"),
                .product(name: "ToolKit", package: "Tool")
            ]
        )
    ]
)
