// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureUserDeletion",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureUserDeletionData",
            targets: ["FeatureUserDeletionData"]
        ),
        .library(
            name: "FeatureUserDeletionDomain",
            targets: ["FeatureUserDeletionDomain"]
        ),
        .library(
            name: "FeatureUserDeletionUI",
            targets: ["FeatureUserDeletionUI"]
        ),
        .library(name: "FeatureUserDeletionMock", targets: ["FeatureUserDeletionDomainMock"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "1.2.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Errors"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "FeatureUserDeletionData",
            dependencies: [
                .target(name: "FeatureUserDeletionDomain"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureUserDeletionDomain",
            dependencies: [
                .product(name: "Errors", package: "Errors")
            ]
        ),
        .target(
            name: "FeatureUserDeletionUI",
            dependencies: [
                .target(name: "FeatureUserDeletionDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableArchitectureExtensions", package: "ComposableArchitectureExtensions"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .target(
            name: "FeatureUserDeletionDomainMock",
            dependencies: [
                .target(name: "FeatureUserDeletionDomain")
            ]
        ),
        .testTarget(
            name: "FeatureUserDeletionUITests",
            dependencies: [
                .target(name: "FeatureUserDeletionDomain"),
                .target(name: "FeatureUserDeletionUI"),
                .target(name: "FeatureUserDeletionDomainMock"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "TestKit", package: "Test")
            ],
            exclude: ["__Snapshots__"]
        )
    ]
)
