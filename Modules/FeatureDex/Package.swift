// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureDex",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureDex",
            targets: ["FeatureDexDomain", "FeatureDexData", "FeatureDexUI"]
        )
    ],
    dependencies: [
        .package(path: "../Blockchain"),
        .package(path: "../DelegatedSelfCustody"),
        .package(path: "../FeatureUnifiedActivity"),
        .package(path: "../Network")
    ],
    targets: [
        .target(
            name: "FeatureDexDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "DelegatedSelfCustodyDomain", package: "DelegatedSelfCustody")
            ],
            path: "Sources/Domain"
        ),
        .target(
            name: "FeatureDexData",
            dependencies: [
                .target(name: "FeatureDexDomain"),
                .product(name: "DelegatedSelfCustodyDomain", package: "DelegatedSelfCustody"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "Blockchain", package: "Blockchain")
            ],
            path: "Sources/Data"
        ),
        .target(
            name: "FeatureDexUI",
            dependencies: [
                .target(name: "FeatureDexDomain"),
                .target(name: "FeatureDexData"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "DelegatedSelfCustodyDomain", package: "DelegatedSelfCustody"),
                .product(name: "UnifiedActivityDomain", package: "FeatureUnifiedActivity")
            ],
            path: "Sources/UI"
        )
    ]
)
