// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureAnnouncements",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureAnnouncements",
            targets: [
                "FeatureAnnouncementsData",
                "FeatureAnnouncementsDomain",
                "FeatureAnnouncementsUI"
            ]
        ),
        .library(
            name: "FeatureAnnouncementsDomain",
            targets: ["FeatureAnnouncementsDomain"]
        ),
        .library(
            name: "FeatureAnnouncementsData",
            targets: ["FeatureAnnouncementsData"]
        ),
        .library(
            name: "FeatureAnnouncementsUI",
            targets: ["FeatureAnnouncementsUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
        .package(url: "https://github.com/dchatzieleftheriou-bc/DIKit.git", exact: "1.0.1"),
        .package(path: "../Tool"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Localization"),
        .package(path: "../Platform")
    ],
    targets: [
        .target(
            name: "FeatureAnnouncementsUI",
            dependencies: [
                .target(name: "FeatureAnnouncementsDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                )
            ]
        ),
        .target(
            name: "FeatureAnnouncementsDomain",
            dependencies: [
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace")
            ]
        ),
        .target(
            name: "FeatureAnnouncementsData",
            dependencies: [
                .target(name: "FeatureAnnouncementsDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform")
            ]
        )
    ]
)
