// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "FeatureNotificationPreferences",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureNotificationPreferences",
            targets: [
                "FeatureNotificationPreferencesDomain",
                "FeatureNotificationPreferencesUI",
                "FeatureNotificationPreferencesData"
            ]
        ),
        .library(
            name: "FeatureNotificationPreferencesDetails",
            targets: ["FeatureNotificationPreferencesDetailsUI"]
        ),
        .library(
            name: "FeatureNotificationPreferencesMocks",
            targets: ["FeatureNotificationPreferencesMocks"]
        ),
        .library(
            name: "FeatureNotificationPreferencesDomain",
            targets: ["FeatureNotificationPreferencesDomain"]
        ),
        .library(
            name: "FeatureNotificationPreferencesUI",
            targets: ["FeatureNotificationPreferencesUI"]
        ),
        .library(
            name: "FeatureNotificationPreferencesData",
            targets: ["FeatureNotificationPreferencesData"]
        ),
        .library(
            name: "FeatureNotificationPreferencesDetailsUI",
            targets: ["FeatureNotificationPreferencesDetailsUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.42.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.10.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Errors"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureNotificationPreferencesDomain",
            dependencies: [
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                )
            ],
            path: "Sources/NotificationPreferences/NotificationPreferencesDomain"
        ),
        .target(
            name: "FeatureNotificationPreferencesData",
            dependencies: [
                .target(
                    name: "FeatureNotificationPreferencesDomain"
                ),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                )
            ],
            path: "Sources/NotificationPreferences/NotificationPreferencesData"
        ),
        .target(
            name: "FeatureNotificationPreferencesUI",
            dependencies: [
                .target(name: "FeatureNotificationPreferencesDomain"),
                .target(name: "FeatureNotificationPreferencesDetailsUI"),
                .target(name: "FeatureNotificationPreferencesMocks"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "AnalyticsKit",
                    package: "Analytics"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "ToolKit",
                    package: "Tool"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(
                    name: "ComposableArchitectureExtensions",
                    package: "ComposableArchitectureExtensions"
                )
            ],
            path: "Sources/NotificationPreferences/NotificationPreferencesUI"
        ),
        .target(
            name: "FeatureNotificationPreferencesDetailsUI",
            dependencies: [
                .target(
                    name: "FeatureNotificationPreferencesDomain"
                ),
                .target(name: "FeatureNotificationPreferencesMocks"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "AnalyticsKit",
                    package: "Analytics"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "ToolKit",
                    package: "Tool"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "ComposableArchitectureExtensions",
                    package: "ComposableArchitectureExtensions"
                )
            ],
            path: "Sources/NotificationPreferencesDetails/NotificationPreferencesDetailsUI"
        ),
        .target(
            name: "FeatureNotificationPreferencesMocks",
            dependencies: [
                .target(name: "FeatureNotificationPreferencesDomain")
            ],
            path: "Sources/FeatureNotificationPreferencesMocks"
        ),
        .testTarget(
            name: "FeatureNotificationPreferencesUITests",
            dependencies: [
                .target(name: "FeatureNotificationPreferencesUI"),
                .target(name: "FeatureNotificationPreferencesData"),
                .target(name: "FeatureNotificationPreferencesDomain"),
                .target(name: "FeatureNotificationPreferencesMocks"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
