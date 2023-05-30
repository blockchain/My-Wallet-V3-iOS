// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Coincore",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "Coincore",
            targets: ["Coincore"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Observability"),
        .package(path: "../Money"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "Coincore",
            dependencies: [
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "ObservabilityKit", package: "Observability"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool")
            ],
            path: "Sources/Domain"
        ),
        .target(
            name: "CoincoreMock",
            dependencies: [
                .target(name: "Coincore")
            ],
            path: "Sources/Mock"
        ),
        .testTarget(
            name: "CoincoreTests",
            dependencies: [
                .target(name: "Coincore")
            ],
            path: "Tests/Domain"
        )
    ]
)
