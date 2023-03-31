// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureTour",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureTour",
            targets: [
                "FeatureTourData",
                "FeatureTourDomain",
                "FeatureTourUI"
            ]
        ),
        .library(
            name: "FeatureTourUI",
            targets: ["FeatureTourUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.52.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.11.0"
        ),
        .package(url: "https://github.com/dchatzieleftheriou-bc/DIKit.git", exact: "1.0.1"),
        .package(path: "../Localization"),
        .package(path: "../Platform"),
        .package(path: "../UIComponents"),
        .package(path: "../ComposableArchitectureExtensions")
    ],
    targets: [
        .target(
            name: "FeatureTourData",
            dependencies: [
                "FeatureTourDomain"
            ],
            path: "Data"
        ),
        .target(
            name: "FeatureTourDomain",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Domain"
        ),
        .target(
            name: "FeatureTourUI",
            dependencies: [
                .target(name: "FeatureTourDomain"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions")
            ],
            path: "UI"
        ),
        .testTarget(
            name: "FeatureTourTests",
            dependencies: [
                .target(name: "FeatureTourData"),
                .target(name: "FeatureTourDomain"),
                .target(name: "FeatureTourUI"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DIKit", package: "DIKit")
            ],
            path: "Tests",
            exclude: ["__Snapshots__"]
        )
    ]
)
