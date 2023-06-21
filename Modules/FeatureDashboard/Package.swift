// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureDashboard",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "FeatureDashboard", targets: ["FeatureDashboardUI", "FeatureDashboardDomain", "FeatureDashboardData"]),
        .library(name: "FeatureDashboardUI", targets: ["FeatureDashboardUI"]),
        .library(name: "FeatureDashboardDomain", targets: ["FeatureDashboardDomain"]),
        .library(name: "FeatureDashboardData", targets: ["FeatureDashboardData"])
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
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../FeaturePaymentsIntegration"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../FeatureWithdrawalLocks"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../FeatureBackupRecoveryPhrase"),
        .package(path: "../FeatureUnifiedActivity"),
        .package(path: "../FeatureReferral"),
        .package(path: "../FeatureTopMoversCrypto"),
        .package(path: "../FeatureCoin"),
        .package(path: "../FeatureProducts")
    ],
    targets: [
        .target(
            name: "FeatureDashboardUI",
            dependencies: [
                .target(name: "FeatureDashboardDomain"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "FeaturePlaidUI", package: "FeaturePaymentsIntegration"),
                .product(name: "FeatureTransactionUI", package: "FeatureTransaction"),
                .product(name: "FeatureWithdrawalLocksUI", package: "FeatureWithdrawalLocks"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "FeatureReferralDomain", package: "FeatureReferral"),
                .product(name: "FeatureReferralUI", package: "FeatureReferral"),
                .product(name: "FeatureBackupRecoveryPhraseUI", package: "FeatureBackupRecoveryPhrase"),
                .product(name: "UnifiedActivityDomain", package: "FeatureUnifiedActivity"),
                .product(name: "UnifiedActivityUI", package: "FeatureUnifiedActivity"),
                .product(name: "FeatureTopMoversCryptoUI", package: "FeatureTopMoversCrypto"),
                .product(name: "FeatureTopMoversCryptoDomain", package: "FeatureTopMoversCrypto"),
                .product(name: "FeatureCoinUI", package: "FeatureCoin"),
                .product(name: "FeatureCoinDomain", package: "FeatureCoin"),
                .product(name: "FeatureProductsDomain", package: "FeatureProducts")
            ]
        ),
        .target(
            name: "FeatureDashboardDomain",
            dependencies: [
                .product(name: "FeatureBackupRecoveryPhraseUI", package: "FeatureBackupRecoveryPhrase"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureDashboardData",
            dependencies: [
                .target(name: "FeatureDashboardDomain"),
                .product(name: "UnifiedActivityDomain", package: "FeatureUnifiedActivity"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureDashboardUITests",
            dependencies: [
                .target(name: "FeatureDashboardUI")
            ]
        )
    ]
)
