// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureCustomerSupport",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureCustomerSupportUI",
            targets: ["FeatureCustomerSupportUI"]
        )
    ],
    dependencies: [
        .package(path: "../Blockchain"),
        .package(path: "../Network"),
    ],
    targets: [
        .target(
            name: "FeatureCustomerSupportUI",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "NetworkKit", package: "Network"),
            ]
        ),
        .testTarget(
            name: "FeatureCustomerSupportUITests",
            dependencies: ["FeatureCustomerSupportUI"]
        )
    ]
)
