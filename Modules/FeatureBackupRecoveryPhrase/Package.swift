// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureBackupRecoveryPhrase",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureBackupRecoveryPhrase",
            targets: ["FeatureBackupRecoveryPhraseUI", "FeatureBackupRecoveryPhraseData", "FeatureBackupRecoveryPhraseDomain"]
        ),
        .library(
            name: "FeatureBackupRecoveryPhraseUI",
            targets: ["FeatureBackupRecoveryPhraseUI"]
        ),
        .library(
            name: "FeatureBackupRecoveryPhraseData",
            targets: ["FeatureBackupRecoveryPhraseData"]
        ),
        .library(
            name: "FeatureBackupRecoveryPhraseDomain",
            targets: ["FeatureBackupRecoveryPhraseDomain"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/dchatzieleftheriou-bc/DIKit.git", exact: "1.0.1"),
        .package(path: "../Tool"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../Platform"),
        .package(path: "../Network"),
        .package(path: "../WalletPayload"),
        .package(path: "../Localization"),
        .package(path: "../Blockchain"),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "FeatureBackupRecoveryPhraseUI",
            dependencies: [
                .target(name: "FeatureBackupRecoveryPhraseDomain"),
                .product(
                    name: "ToolKit",
                    package: "Tool"
                ),
                .product(
                    name: "BlockchainUI",
                    package: "Blockchain"
                ),
                .product(
                    name: "WalletPayloadKit",
                    package: "WalletPayload"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                )
            ]
        ),
        .target(
            name: "FeatureBackupRecoveryPhraseData",
            dependencies: [
                .target(
                    name: "FeatureBackupRecoveryPhraseDomain"
                 ),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "DIKit",
                    package: "DIKit"
                )
            ]
        ),
        .target(
            name: "FeatureBackupRecoveryPhraseDomain",
            dependencies: [
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "PlatformKit", package: "Platform")
            ]
        ),
        .testTarget(
            name: "FeatureBackupRecoveryPhraseUITests",
            dependencies: [
                .target(name: "FeatureBackupRecoveryPhraseUI"),
                .target(name: "FeatureBackupRecoveryPhraseData"),
                .target(name: "FeatureBackupRecoveryPhraseDomain"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
