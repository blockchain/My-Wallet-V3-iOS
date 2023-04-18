// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureTopMoversCrypto",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "FeatureTopMoversCrypto", targets: ["FeatureTopMoversCryptoUI", "FeatureTopMoversCryptoDomain"]),
        .library(name: "FeatureTopMoversCryptoUI", targets: ["FeatureTopMoversCryptoUI"]),
        .library(name: "FeatureTopMoversCryptoDomain", targets: ["FeatureTopMoversCryptoDomain"])
    ],
    dependencies: [
        .package(path: "../Blockchain"),
        .package(path: "../Money")
    ],
    targets: [
        .target(
            name: "FeatureTopMoversCryptoUI",
            dependencies: [
                .product(name: "BlockchainUI", package: "Blockchain"),
                .target(name: "FeatureTopMoversCryptoDomain")
            ]
        ),
        .target(
            name: "FeatureTopMoversCryptoDomain",
            dependencies: [
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .testTarget(
            name: "FeatureTopMoversCryptoUITests",
            dependencies: ["FeatureTopMoversCryptoUI"]
        ),
        .testTarget(
            name: "FeatureTopMoversCryptoDomainTests",
            dependencies: ["FeatureTopMoversCryptoDomain"]
        )
    ]
)
