// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ComposableArchitectureExtensions",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "ComposableArchitectureExtensions",
            targets: ["ComposableArchitectureExtensions"]
        ),
        .library(
            name: "ComposableNavigation",
            targets: ["ComposableNavigation"]
        )
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
            url: "https://github.com/apple/swift-algorithms.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-custom-dump",
            from: "0.5.0"
        ),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace")
    ],
    targets: [
        .target(
            name: "ComposableArchitectureExtensions",
            dependencies: [
                .target(name: "ComposableNavigation"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "CustomDump", package: "swift-custom-dump")
            ],
            exclude: [
                "Prefetching/README.md"
            ]
        ),
        .target(
            name: "ComposableNavigation",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace")
            ],
            exclude: [
                "README.md"
            ]
        ),
        .testTarget(
            name: "ComposableNavigationTests",
            dependencies: ["ComposableNavigation"]
        ),
        .testTarget(
            name: "ComposableArchitectureExtensionsTests",
            dependencies: ["ComposableArchitectureExtensions"]
        )
    ]
)
