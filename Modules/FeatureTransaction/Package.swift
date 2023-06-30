// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureTransaction",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureTransaction",
            targets: ["FeatureTransactionDomain", "FeatureTransactionData", "FeatureTransactionUI"]
        ),
        .library(
            name: "FeatureTransactionDomain",
            targets: ["FeatureTransactionDomain"]
        ),
        .library(
            name: "FeatureTransactionData",
            targets: ["FeatureTransactionData"]
        ),
        .library(
            name: "FeatureTransactionUI",
            targets: ["FeatureTransactionUI"]
        ),
        .library(
            name: "FeatureTransactionDomainMock",
            targets: ["FeatureTransactionDomainMock"]
        ),
        .library(
            name: "FeatureTransactionUIMock",
            targets: ["FeatureTransactionUIMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.54.1"
        ),
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.3.0"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.6.0"
        ),
        .package(
            url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
            from: "5.0.2"
        ),
        .package(
            url: "https://github.com/uber/RIBs.git",
            from: "0.13.2"
        ),
        .package(path: "../Analytics"),
        .package(path: "../Blockchain"),
        .package(path: "../DelegatedSelfCustody"),
        .package(path: "../Errors"),
        .package(path: "../FeatureKYC"),
        .package(path: "../FeaturePaymentsIntegration"),
        .package(path: "../FeatureProducts"),
        .package(path: "../FeatureStaking"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Platform"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../FeatureWithdrawalLocks"),
        .package(path: "Modules/BIND"),
        .package(path: "Modules/Checkout"),
        .package(path: "Modules/Entry")
    ],
    targets: [
        .target(
            name: "FeatureTransactionDomain",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "DelegatedSelfCustodyKit", package: "DelegatedSelfCustody"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "FeaturePlaidDomain", package: "FeaturePaymentsIntegration"),
                .product(name: "FeatureProductsDomain", package: "FeatureProducts"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureTransactionData",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BINDWithdrawData", package: "BIND"),
                .product(name: "FeatureTransactionEntryDomain", package: "Entry")
            ]
        ),
        .target(
            name: "FeatureTransactionUI",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BINDWithdrawDomain", package: "BIND"),
                .product(name: "BINDWithdrawUI", package: "BIND"),
                .product(name: "FeatureTransactionEntryUI", package: "Entry"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ErrorsUI", package: "Errors"),
                .product(name: "FeatureCheckoutUI", package: "Checkout"),
                .product(name: "FeatureKYCDomain", package: "FeatureKYC"),
                .product(name: "FeatureKYCUI", package: "FeatureKYC"),
                .product(name: "FeatureStakingUI", package: "FeatureStaking"),
                .product(name: "FeaturePlaidUI", package: "FeaturePaymentsIntegration"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "FeatureWithdrawalLocksUI", package: "FeatureWithdrawalLocks"),
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        ),
        .target(
            name: "FeatureTransactionDomainMock",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureTransactionUIMock",
            dependencies: [
                .target(name: "FeatureTransactionUI"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionDomainTests",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .target(name: "FeatureTransactionDomainMock"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "FeatureProductsDomain", package: "FeatureProducts"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionDataTests",
            dependencies: [
                .target(name: "FeatureTransactionData"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionUITests",
            dependencies: [
                .target(name: "FeatureTransactionDomainMock"),
                .target(name: "FeatureTransactionUI"),
                .target(name: "FeatureTransactionUIMock"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "PlatformUIKitMock", package: "Platform"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
