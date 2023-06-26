// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "CommonCrypto",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "CommonCryptoKit", targets: ["CommonCryptoKit"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            from: "1.5.1"
        ),
        .package(
            url: "https://github.com/oliveratkinson-bc/wallet-core.git",
            exact: "2.9.8-blockchain"
        ),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "CommonCryptoKit",
            dependencies: [
                .product(name: "WalletCore", package: "wallet-core"),
                .product(name: "SwiftProtobuf", package: "wallet-core"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        .testTarget(
            name: "CommonCryptoKitTests",
            dependencies: [
                "CommonCryptoKit",
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
