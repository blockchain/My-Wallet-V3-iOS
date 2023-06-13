// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureDebug",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "FeatureDebug", targets: ["FeatureDebugUI"]),
        .library(name: "FeatureDebugUI", targets: ["FeatureDebugUI"])
    ],
    dependencies: [
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../Blockchain"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureDebugUI",
            dependencies: [
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Examples", package: "BlockchainComponentLibrary"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain")
            ]
        ),
        .testTarget(
            name: "FeatureDebugUITests",
            dependencies: [
                .target(name: "FeatureDebugUI")
            ]
        )
    ]
)
