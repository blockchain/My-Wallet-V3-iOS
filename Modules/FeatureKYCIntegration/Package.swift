// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureKYCIntegration",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureProveData",
            targets: ["FeatureProveData"]
        ),
        .library(
            name: "FeatureProveDomain",
            targets: ["FeatureProveDomain"]
        ),
        .library(
            name: "FeatureProveUI",
            targets: ["FeatureProveUI"]
        )
    ],
    dependencies: [
        .package(path: "../Blockchain"),
        .package(path: "../FeatureForm"),
        .package(path: "../Network"),
        .package(path: "../Test"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureProveData",
            dependencies: [
                .target(name: "FeatureProveDomain"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "NetworkKit", package: "Network")
            ],
            path: "./Sources/FeatureProve/FeatureProveData"
        ),
        .target(
            name: "FeatureProveDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "FeatureFormDomain", package: "FeatureForm")
            ],
            path: "./Sources/FeatureProve/FeatureProveDomain"
        ),
        .target(
            name: "FeatureProveUI",
            dependencies: [
                .target(name: "FeatureProveDomain"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "FeatureFormDomain", package: "FeatureForm"),
                .product(name: "FeatureFormUI", package: "FeatureForm"),
                .product(name: "UIComponents", package: "UIComponents")
            ],
            path: "./Sources/FeatureProve/FeatureProveUI",
            resources: [
                .copy("Media.xcassets")
            ]
        ),
        .testTarget(
            name: "FeatureProveDataTests",
            dependencies: [
                .target(name: "FeatureProveData")
            ],
            path: "./Tests/FeatureProveTests/FeatureProveDataTests"
        ),
        .testTarget(
            name: "FeatureProveDomainTests",
            dependencies: [
                .target(name: "FeatureProveDomain")
            ],
            path: "./Tests/FeatureProveTests/FeatureProveDomainTests"
        ),
        .testTarget(
            name: "FeatureProveUITests",
            dependencies: [
                .target(name: "FeatureProveUI")
            ],
            path: "./Tests/FeatureProveTests/FeatureProveUITests"
        )
    ]
)
