// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureQuickActions",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureQuickActions",
            targets: ["FeatureQuickActions"]
        )
    ],
    dependencies: [
        .package(path: "../Blockchain")
    ],
    targets: [
        .target(
            name: "FeatureQuickActions",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain")
            ]
        )
    ]
)
