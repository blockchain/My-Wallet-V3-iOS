// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureExternalTradingMigration",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureExternalTradingMigration",
            targets: [
                "FeatureExternalTradingMigrationData",
                "FeatureExternalTradingMigrationDomain",
                "FeatureExternalTradingMigrationUI"
            ]
        ),
        .library(
            name: "FeatureExternalTradingMigrationDomain",
            targets: ["FeatureExternalTradingMigrationDomain"]
        ),
        .library(
            name: "FeatureExternalTradingMigrationData",
            targets: ["FeatureExternalTradingMigrationData"]
        ),
        .library(
            name: "FeatureExternalTradingMigrationUI",
            targets: ["FeatureExternalTradingMigrationUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.56.0"),
        .package(url: "https://github.com/dchatzieleftheriou-bc/DIKit.git", exact: "1.0.1"),
        .package(path: "../Blockchain"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Localization")
    ],
    targets: [
        .target(
            name: "FeatureExternalTradingMigrationUI",
            dependencies: [
                .target(name: "FeatureExternalTradingMigrationDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .target(
            name: "FeatureExternalTradingMigrationDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain")
            ]
        ),
        .target(
            name: "FeatureExternalTradingMigrationData",
            dependencies: [
                .target(name: "FeatureExternalTradingMigrationDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network")
            ]
        )
    ]
)
