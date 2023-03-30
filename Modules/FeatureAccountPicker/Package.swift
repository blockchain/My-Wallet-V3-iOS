// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureAccountPicker",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureAccountPicker",
            targets: [
                "FeatureAccountPickerData",
                "FeatureAccountPickerDomain",
                "FeatureAccountPickerUI"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.42.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.11.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.9.1"
        ),
        .package(path: "../Blockchain"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Errors"),
        .package(path: "../Localization"),
        .package(path: "../Platform"),
        .package(path: "../Test"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureAccountPickerData",
            dependencies: [
                .target(name: "FeatureAccountPickerDomain")
            ],
            path: "Data"
        ),
        .target(
            name: "FeatureAccountPickerDomain",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Domain"
        ),
        .target(
            name: "FeatureAccountPickerUI",
            dependencies: [
                .target(name: "FeatureAccountPickerDomain"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitectureExtensions", package: "ComposableArchitectureExtensions"),
                .product(name: "ErrorsUI", package: "Errors"),
                .product(name: "PlatformKit", package: "Platform"),
            ],
            path: "UI"
        ),
        .testTarget(
            name: "FeatureAccountPickerTests",
            dependencies: [
                .target(name: "FeatureAccountPickerData"),
                .target(name: "FeatureAccountPickerDomain"),
                .target(name: "FeatureAccountPickerUI"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "UIComponents", package: "UIComponents")
            ],
            path: "Tests",
            exclude: ["__Snapshots__"]
        )
    ]
)
