// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureSettings",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureSettings",
            targets: [
                "FeatureSettingsDomain",
                "FeatureSettingsUI"
            ]
        ),
        .library(
            name: "FeatureSettingsDomain",
            targets: ["FeatureSettingsDomain"]
        ),
        .library(
            name: "FeatureSettingsUI",
            targets: ["FeatureSettingsUI"]
        ),
        .library(
            name: "FeatureSettingsDomainMock",
            targets: ["FeatureSettingsDomainMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.5.0"
        ),
        .package(path: "../CommonCrypto"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../FeatureKYC"),
        .package(path: "../Network"),
        .package(path: "../Permissions"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../WalletPayload"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../FeatureCardPayment"),
        .package(path: "../FeatureBackupRecoveryPhrase"),
        .package(path: "../FeatureNotificationPreferences"),
        .package(path: "../FeatureReferral"),
        .package(path: "../FeatureUserDeletion")
    ],
    targets: [
        .target(
            name: "FeatureSettingsDomain",
            dependencies: [
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureKYCDomain", package: "FeatureKYC"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PermissionsKit", package: "Permissions"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
        .target(
            name: "FeatureSettingsUI",
            dependencies: [
                .target(name: "FeatureSettingsDomain"),
                .product(name: "FeatureKYCUI", package: "FeatureKYC"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "FeatureCardPaymentUI", package: "FeatureCardPayment"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment"),
                .product(name: "FeatureNotificationPreferencesUI", package: "FeatureNotificationPreferences"),
                .product(name: "FeatureReferralUI", package: "FeatureReferral"),
                .product(name: "FeatureUserDeletionData", package: "FeatureUserDeletion"),
                .product(name: "FeatureUserDeletionDomain", package: "FeatureUserDeletion"),
                .product(name: "FeatureUserDeletionUI", package: "FeatureUserDeletion"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "FeatureBackupRecoveryPhraseUI", package: "FeatureBackupRecoveryPhrase")
            ]
        ),
        .target(
            name: "FeatureSettingsDomainMock",
            dependencies: [
                .target(name: "FeatureSettingsDomain")
            ]
        ),
        .testTarget(
            name: "FeatureSettingsDomainTests",
            dependencies: [
                .target(name: "FeatureSettingsDomain")
            ]
        ),
        .testTarget(
            name: "FeatureSettingsUITests",
            dependencies: [
                .target(name: "FeatureSettingsUI")
            ]
        )
    ]
)
