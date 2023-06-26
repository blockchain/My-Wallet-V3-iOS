// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Observability",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "ObservabilityKit",
            targets: ["ObservabilityKit"]
        )
    ],
    dependencies: [
        .package(name: "BlockchainNamespace", path: "../BlockchainNamespace"),
        .package(name: "Tool", path: "../Tool")
    ],
    targets: [
        .target(
            name: "ObservabilityKit",
            dependencies: [
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "ToolKit", package: "Tool")
            ]
        )
    ]
)
