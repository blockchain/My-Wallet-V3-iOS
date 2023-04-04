// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureTransactionEntry",
    platforms: [.iOS(.v14), .macOS(.v13)],
    products: [
        .library(name: "FeatureTransactionEntryUI", targets: ["FeatureTransactionEntryUI"]),
        .library(name: "FeatureTransactionEntryDomain", targets: ["FeatureTransactionEntryDomain"])
    ],
    dependencies: [
        .package(path: "../../../Blockchain"),
        .package(path: "../../../FeatureTopMoversCrypto")
    ],
    targets: [
        .target(
            name: "FeatureTransactionEntryUI",
            dependencies: [
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "FeatureTopMoversCryptoUI", package: "FeatureTopMoversCrypto")
            ]
        ),
        .target(
            name: "FeatureTransactionEntryDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionEntryUITests",
            dependencies: ["FeatureTransactionEntryUI"]
        ),
        .testTarget(
            name: "FeatureTransactionEntryDomainTests",
            dependencies: ["FeatureTransactionEntryDomain"]
        )
    ]
)
