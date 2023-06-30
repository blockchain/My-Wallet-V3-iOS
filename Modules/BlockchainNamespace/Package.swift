// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "BlockchainNamespace",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "BlockchainNamespace",
            targets: ["BlockchainNamespace"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/thousandyears/Lexicon.git",
            from: "0.6.3"
        ),
        .package(
            url: "https://github.com/thousandyears/OptionalSubscripts.git",
            from: "0.1.0"
        ),
        .package(path: "../Extensions"),
        .package(path: "../Keychain"),
        .package(path: "../AnyCoding")
    ],
    targets: [
        .target(
            name: "BlockchainNamespace",
            dependencies: [
                .target(name: "FirebaseProtocol"),
                .product(name: "Lexicon", package: "Lexicon"),
                .product(name: "OptionalSubscripts", package: "OptionalSubscripts"),
                .product(name: "AnyCoding", package: "AnyCoding"),
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "KeychainKit", package: "Keychain")
            ],
            resources: [
                .copy("blockchain.lexicon")
            ]
        ),
        .target(
            name: "FirebaseProtocol"
        ),
        .testTarget(
            name: "BlockchainNamespaceTests",
            dependencies: ["BlockchainNamespace"],
            resources: [
                .copy("test.lexicon")
            ]
        )
    ]
)
