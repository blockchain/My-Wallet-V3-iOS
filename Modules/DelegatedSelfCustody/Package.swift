// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DelegatedSelfCustody",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "DelegatedSelfCustodyKit",
            targets: ["DelegatedSelfCustodyDomain", "DelegatedSelfCustodyData"]
        ),
        .library(
            name: "DelegatedSelfCustodyDomain",
            targets: ["DelegatedSelfCustodyDomain"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            from: "1.5.1"
        ),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Errors"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Test"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "DelegatedSelfCustodyDomain",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "DelegatedSelfCustodyData",
            dependencies: [
                .target(name: "DelegatedSelfCustodyDomain"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "DelegatedSelfCustodyDataTests",
            dependencies: [
                .target(name: "DelegatedSelfCustodyData"),
                .target(name: "DelegatedSelfCustodyDomain"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
