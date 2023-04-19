// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureReceive",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureReceive",
            targets: ["FeatureReceiveDomain", "FeatureReceiveUI"]
        ),
        .library(
            name: "FeatureReceiveDomain",
            targets: ["FeatureReceiveDomain"]
        ),
        .library(
            name: "FeatureReceiveUI",
            targets: ["FeatureReceiveUI"]
        )
    ],
    dependencies: [
        .package(path: "../Analytics"),
        .package(path: "../Blockchain"),
        .package(path: "../Errors"),
        .package(path: "../FeatureKYC"),
        .package(path: "../Localization"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureReceiveDomain",
            dependencies: [
                .product(name: "Errors", package: "Errors"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "FeatureTransactionUI", package: "FeatureTransaction"),
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .target(
            name: "FeatureReceiveUI",
            dependencies: [
                .target(name: "FeatureReceiveDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "ErrorsUI", package: "Errors"),
                .product(name: "FeatureKYCDomain", package: "FeatureKYC"),
                .product(name: "FeatureKYCUI", package: "FeatureKYC"),
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .testTarget(
            name: "FeatureReceiveUITests",
            dependencies: [
                .target(name: "FeatureReceiveUI")
            ]
        )
    ]
)
