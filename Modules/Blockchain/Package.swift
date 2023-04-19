// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "Blockchain", targets: ["Blockchain"]),
        .library(name: "BlockchainUI", targets: ["BlockchainUI"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.52.0"
        ),
        .package(path: "../AnyCoding"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Errors"),
        .package(path: "../Extensions"),
        .package(path: "../Keychain"),
        .package(path: "../Localization"),
        .package(path: "../Money")
    ],
    targets: [
        .target(
            name: "Blockchain",
            dependencies: [
                .product(name: "AnyCoding", package: "AnyCoding"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "KeychainKit", package: "Keychain"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "BlockchainUI",
            dependencies: [
                .target(name: "Blockchain"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitectureExtensions", package: "ComposableArchitectureExtensions"),
                .product(name: "ErrorsUI", package: "Errors")
            ]
        )
    ]
)
