// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureCheckout",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "FeatureCheckout", targets: ["FeatureCheckoutDomain"]),
        .library(name: "FeatureCheckoutDomain", targets: ["FeatureCheckoutDomain"]),
        .library(name: "FeatureCheckoutUI", targets: ["FeatureCheckoutUI"])
    ],
    dependencies: [
        .package(path: "../../../Blockchain"),
        .package(path: "../../../Test")
    ],
    targets: [
        .target(
            name: "FeatureCheckoutDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain")
            ]
        ),
        .target(
            name: "FeatureCheckoutUI",
            dependencies: [
                .target(name: "FeatureCheckoutDomain"),
                .product(name: "BlockchainUI", package: "Blockchain")
            ]
        ),
        .testTarget(
            name: "FeatureCheckoutDomainTests",
            dependencies: [
                .target(name: "FeatureCheckoutDomain"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureCheckoutUITests",
            dependencies: [
                .target(name: "FeatureCheckoutUI"),
                .product(name: "TestKit", package: "Test")
            ],
            exclude: [
                "__Snapshots__"
            ]
        )
    ]
)
