// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Platform",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "PlatformKit", targets: ["PlatformKit"]),
        .library(name: "PlatformDataKit", targets: ["PlatformDataKit"]),
        .library(name: "PlatformUIKit", targets: ["PlatformUIKit"]),
        .library(name: "PlatformKitMock", targets: ["PlatformKitMock"]),
        .library(name: "PlatformUIKitMock", targets: ["PlatformUIKitMock"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.3.0"
        ),
        .package(
            url: "https://github.com/danielgindi/Charts.git",
            from: "4.1.0"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(
            url: "https://github.com/uber/RIBs.git",
            from: "0.13.2"
        ),
        .package(
            url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
            from: "5.0.2"
        ),
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.6.0"
        ),
        .package(
            url: "https://github.com/marmelroy/PhoneNumberKit.git",
            from: "3.5.6"
        ),
        .package(
            url: "https://github.com/oliveratkinson-bc/zxcvbn-ios.git",
            branch: "swift-package-manager"
        ),
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../AnyCoding"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../CommonCrypto"),
        .package(path: "../Coincore"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../DelegatedSelfCustody"),
        .package(path: "../Errors"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../FeatureCardPayment"),
        .package(path: "../FeatureForm"),
        .package(path: "../FeatureOpenBanking"),
        .package(path: "../FeatureStaking"),
        .package(path: "../Localization"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../RxAnalytics"),
        .package(path: "../RxTool"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../WalletPayload")
    ],
    targets: [
        .target(
            name: "PlatformKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "AnyCoding", package: "AnyCoding"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "Coincore", package: "Coincore"),
                .product(name: "DelegatedSelfCustodyKit", package: "DelegatedSelfCustody"),
                // TODO: refactor this to use `FeatureAuthenticationDomain` as this shouldn't depend on DataKit
                .product(name: "FeatureAuthenticationData", package: "FeatureAuthentication"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureStakingDomain", package: "FeatureStaking"),
                .product(name: "FeatureFormDomain", package: "FeatureForm"),
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitectureExtensions", package: "ComposableArchitectureExtensions"),
                .product(name: "RxToolKit", package: "RxTool"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "FeatureOpenBankingDomain", package: "FeatureOpenBanking"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment")
            ]
        ),
        .target(
            name: "PlatformDataKit",
            dependencies: [
                .target(name: "PlatformKit"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment")
            ]
        ),
        .target(
            name: "PlatformUIKit",
            dependencies: [
                .target(name: "PlatformKit"),
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxAnalyticsKit", package: "RxAnalytics"),
                .product(name: "Charts", package: "Charts"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                .product(name: "Zxcvbn", package: "zxcvbn-ios"),
                .product(name: "FeatureOpenBankingUI", package: "FeatureOpenBanking"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment")
            ],
            resources: [
                .copy("PlatformUIKitAssets.xcassets")
            ]
        ),
        .target(
            name: "PlatformKitMock",
            dependencies: [
                .target(name: "PlatformKit")
            ]
        ),
        .target(
            name: "PlatformUIKitMock",
            dependencies: [
                .target(name: "PlatformUIKit"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        ),
        .testTarget(
            name: "PlatformKitTests",
            dependencies: [
                .target(name: "PlatformKit"),
                .target(name: "PlatformKitMock"),
                .product(name: "MoneyKitMock", package: "Money"),
                .product(name: "FeatureAuthenticationMock", package: "FeatureAuthentication"),
                .product(name: "NetworkKitMock", package: "Network"),
                .product(name: "ToolKitMock", package: "Tool"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift")
            ],
            resources: [
                .copy("Fixtures/wallet-data.json")
            ]
        ),
        .testTarget(
            name: "PlatformUIKitTests",
            dependencies: [
                .target(name: "PlatformKitMock"),
                .target(name: "PlatformUIKit"),
                .target(name: "PlatformUIKitMock"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift")
            ]
        )
    ]
)
