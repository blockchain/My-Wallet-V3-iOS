// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureDashboard",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "FeatureDashboard", targets: ["FeatureDashboardUI", "FeatureDashboardDomain", "FeatureDashboardData"]),
        .library(name: "FeatureDashboardUI", targets: ["FeatureDashboardUI"]),
        .library(name: "FeatureDashboardDomain", targets: ["FeatureDashboardDomain"]),
        .library(name: "FeatureDashboardData", targets: ["FeatureDashboardData"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../FeatureBackupRecoveryPhrase"),
        .package(path: "../FeatureCoin"),
        .package(path: "../FeaturePaymentsIntegration"),
        .package(path: "../FeatureProducts"),
        .package(path: "../FeatureReferral"),
        .package(path: "../FeatureTopMoversCrypto"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../FeatureUnifiedActivity"),
        .package(path: "../FeatureWithdrawalLocks"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureDashboardUI",
            dependencies: [
                .target(name: "FeatureDashboardDomain"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "FeatureBackupRecoveryPhraseUI", package: "FeatureBackupRecoveryPhrase"),
                .product(name: "FeatureCoinDomain", package: "FeatureCoin"),
                .product(name: "FeatureCoinUI", package: "FeatureCoin"),
                .product(name: "FeaturePlaidUI", package: "FeaturePaymentsIntegration"),
                .product(name: "FeatureProductsDomain", package: "FeatureProducts"),
                .product(name: "FeatureReferralDomain", package: "FeatureReferral"),
                .product(name: "FeatureReferralUI", package: "FeatureReferral"),
                .product(name: "FeatureTopMoversCryptoDomain", package: "FeatureTopMoversCrypto"),
                .product(name: "FeatureTopMoversCryptoUI", package: "FeatureTopMoversCrypto"),
                .product(name: "FeatureTransactionUI", package: "FeatureTransaction"),
                .product(name: "FeatureWithdrawalLocksUI", package: "FeatureWithdrawalLocks"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "UnifiedActivityDomain", package: "FeatureUnifiedActivity"),
                .product(name: "UnifiedActivityUI", package: "FeatureUnifiedActivity")
            ]
        ),
        .target(
            name: "FeatureDashboardDomain",
            dependencies: [
                .product(name: "FeatureBackupRecoveryPhraseUI", package: "FeatureBackupRecoveryPhrase"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UnifiedActivityDomain", package: "FeatureUnifiedActivity")
            ]
        ),
        .target(
            name: "FeatureDashboardData",
            dependencies: [
                .target(name: "FeatureDashboardDomain"),
                .product(name: "UnifiedActivityDomain", package: "FeatureUnifiedActivity"),
                .product(name: "DIKit", package: "DIKit"),
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
