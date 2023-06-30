// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "Blockchain", targets: ["Blockchain"]),
        .library(name: "BlockchainUI", targets: ["BlockchainUI"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.54.1"
        ),
        .package(
            url: "https://github.com/pointfreeco/swiftui-navigation",
            exact: "0.7.2"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "0.5.1"
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
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "Dependencies", package: "swift-dependencies")
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
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
                .product(name: "ErrorsUI", package: "Errors")
            ]
        )
    ]
)
