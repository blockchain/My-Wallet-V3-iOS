// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureStaking",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureStaking",
            targets: ["FeatureStakingData"]
        ),
        .library(name: "FeatureStakingData", targets: ["FeatureStakingData"]),
        .library(name: "FeatureStakingDomain", targets: ["FeatureStakingDomain"]),
        .library(name: "FeatureStakingUI", targets: ["FeatureStakingUI"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Blockchain")
    ],
    targets: [
        .target(
            name: "FeatureStakingData",
            dependencies: [
                .target(name: "FeatureStakingDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Blockchain", package: "Blockchain")
            ]
        ),
        .target(
            name: "FeatureStakingDomain",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureStakingUI",
            dependencies: [
                .target(name: "FeatureStakingDomain"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .testTarget(
            name: "FeatureStakingDataTests",
            dependencies: ["FeatureStakingData"]
        ),
        .testTarget(
            name: "FeatureStakingDomainTests",
            dependencies: ["FeatureStakingDomain"]
        ),
        .testTarget(
            name: "FeatureStakingUITests",
            dependencies: ["FeatureStakingUI"]
        )
    ]
)
