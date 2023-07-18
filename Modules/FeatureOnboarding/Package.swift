// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureOnboarding",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureOnboarding",
            targets: ["FeatureOnboardingUI"]
        ),
        .library(
            name: "FeatureOnboardingUI",
            targets: ["FeatureOnboardingUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.54.1"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Localization"),
        .package(path: "../Test"),
        .package(path: "../Errors"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureOnboardingUI",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        ),
        .testTarget(
            name: "FeatureOnboardingUITests",
            dependencies: [
                .target(name: "FeatureOnboardingUI"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
