// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeaturePaymentsIntegration",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeaturePlaidData",
            targets: ["FeaturePlaidData"]
        ),
        .library(
            name: "FeaturePlaidDomain",
            targets: ["FeaturePlaidDomain"]
        ),
        .library(
            name: "FeaturePlaidUI",
            targets: ["FeaturePlaidUI"]
        ),
        .library(
            name: "FeatureWireTransfer",
            targets: ["FeatureWireTransfer"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Blockchain"),
        .package(path: "../Network"),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "FeaturePlaidData",
            dependencies: [
                .target(name: "FeaturePlaidDomain"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "NetworkKit", package: "Network")
            ],
            path: "./Sources/FeaturePlaid/FeaturePlaidData"
        ),
        .target(
            name: "FeaturePlaidDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain")
            ],
            path: "./Sources/FeaturePlaid/FeaturePlaidDomain"
        ),
        .target(
            name: "FeaturePlaidUI",
            dependencies: [
                .target(name: "FeaturePlaidDomain"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain")
            ],
            path: "./Sources/FeaturePlaid/FeaturePlaidUI"
        ),
        .target(
            name: "FeatureWireTransfer",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .testTarget(
            name: "FeaturePlaidTests",
            dependencies: [
                .target(name: "FeaturePlaidDomain"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
