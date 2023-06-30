// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FraudIntelligence",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
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
