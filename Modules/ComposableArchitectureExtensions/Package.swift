// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ComposableArchitectureExtensions",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
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
            exact: "0.52.0"
        ),
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
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
