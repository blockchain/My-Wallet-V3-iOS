// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureNFT",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureNFT",
            targets: [
                "FeatureNFTDomain",
                "FeatureNFTUI"
            ]
        ),
        .library(
            name: "FeatureNFTUI",
            targets: ["FeatureNFTUI"]
        ),
        .library(
            name: "FeatureNFTDomain",
            targets: ["FeatureNFTDomain"]
        )
    ],
    dependencies: [
        .package(path: "../Network"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../Money")
    ],
    targets: [
        .target(
            name: "FeatureNFTDomain",
            dependencies: [
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureNFTUI",
            dependencies: [
                .target(name: "FeatureNFTDomain"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary")
            ]
        )
    ]
)
