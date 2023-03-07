// swift-tools-version: 5.7
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
            name: "FeatureVGSData",
            targets: ["FeatureVGSData"]
        ),
        .library(
            name: "FeatureVGSDomain",
            targets: ["FeatureVGSDomain"]
        )
    ],
    dependencies: [
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
        .testTarget(
            name: "FeaturePlaidTests",
            dependencies: [
                .target(name: "FeaturePlaidDomain"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
