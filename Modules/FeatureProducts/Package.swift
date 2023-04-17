// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureProducts",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureProductsData",
            targets: ["FeatureProductsData"]
        ),
        .library(
            name: "FeatureProductsDomain",
            targets: ["FeatureProductsDomain"]
        )
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Test"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureProductsData",
            dependencies: [
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                "FeatureProductsDomain"
            ]
        ),
        .target(
            name: "FeatureProductsDomain",
            dependencies: [
                .product(name: "Errors", package: "Errors"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureProductsDataTests",
            dependencies: [
                .product(name: "Errors", package: "Errors"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "ToolKitMock", package: "Tool"),
                "FeatureProductsData"
            ],
            resources: [
                .process("Fixtures")
            ]
        ),
        .testTarget(
            name: "FeatureProductsDomainTests",
            dependencies: [
                .product(name: "Errors", package: "Errors"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "ToolKitMock", package: "Tool"),
                "FeatureProductsDomain"
            ]
        )
    ]
)
