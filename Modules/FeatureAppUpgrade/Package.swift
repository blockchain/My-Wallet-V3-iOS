// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureAppUpgrade",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureAppUpgrade",
            targets: ["FeatureAppUpgradeDomain", "FeatureAppUpgradeUI"]
        ),
        .library(
            name: "FeatureAppUpgradeDomain",
            targets: ["FeatureAppUpgradeDomain"]
        ),
        .library(
            name: "FeatureAppUpgradeUI",
            targets: ["FeatureAppUpgradeUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.4"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.53.2"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.11.0"
        ),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../Localization"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureAppUpgradeDomain",
            dependencies: []
        ),
        .target(
            name: "FeatureAppUpgradeUI",
            dependencies: [
                .target(name: "FeatureAppUpgradeDomain"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureAppUpgradeUITests",
            dependencies: [
                .target(name: "FeatureAppUpgradeUI"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "ToolKit", package: "Tool")
            ],
            exclude: ["__Snapshots__"]
        )
    ]
)
