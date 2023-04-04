// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureCustomerSupport",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureCustomerSupportUI",
            targets: ["FeatureCustomerSupportUI"]
        )
    ],
    dependencies: [
        .package(path: "../BlockchainNamespace")
    ],
    targets: [
        .target(
            name: "FeatureCustomerSupportUI",
            dependencies: [
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace")
            ]
        ),
        .testTarget(
            name: "FeatureCustomerSupportUITests",
            dependencies: ["FeatureCustomerSupportUI"]
        )
    ]
)
