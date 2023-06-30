// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeaturePaymentsIntegration",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
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
            name: "FeatureVGSData",
            targets: ["FeatureVGSData"]
        ),
        .library(
            name: "FeatureVGSDomain",
            targets: ["FeatureVGSDomain"]
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
            name: "FeatureVGSData",
            dependencies: [
                .target(name: "FeatureVGSDomain"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "NetworkKit", package: "Network")
            ],
            path: "Sources/FeatureVGS/FeatureVGSData"
        ),
        .target(
            name: "FeatureVGSDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain")
            ],
            path: "Sources/FeatureVGS/FeatureVGSDomain"
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
