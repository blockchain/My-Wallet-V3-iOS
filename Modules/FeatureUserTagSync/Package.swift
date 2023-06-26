// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureUserTagSync",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureUserTagSync",
            targets: ["FeatureUserTagSyncDomain", "FeatureUserTagSyncData"]
        ),
        .library(
            name: "FeatureUserTagSyncDomain",
            targets: ["FeatureUserTagSyncDomain"]
        ),
        .library(
            name: "FeatureUserTagSyncData",
            targets: ["FeatureUserTagSyncData"]
        )
    ],
    dependencies: [
        .package(path: "../Tool"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../BlockchainNamespace")
    ],
    targets: [
        .target(
            name: "FeatureUserTagSyncData",
            dependencies: [
                .target(name: "FeatureUserTagSyncDomain"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureUserTagSyncDomain",
            dependencies: [
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Errors", package: "Errors")
            ]
        ),
        .testTarget(
            name: "FeatureUserTagSyncDomainTests",
            dependencies: [
                .target(name: "FeatureUserTagSyncDomain"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace")
            ]
        )
    ]
)
