// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FraudIntelligence",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FraudIntelligence",
            targets: ["FraudIntelligence"]
        )
    ],
    dependencies: [
        .package(path: "../Blockchain")
    ],
    targets: [
        .target(
            name: "FraudIntelligence",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain")
            ]
        ),
        .testTarget(
            name: "FraudIntelligenceTests",
            dependencies: ["FraudIntelligence"]
        )
    ]
)
