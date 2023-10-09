// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureAnnouncements",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
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
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.59.0"),
        .package(url: "https://github.com/dchatzieleftheriou-bc/DIKit.git", exact: "1.0.1"),
        .package(path: "../Blockchain"),
        .package(path: "../Tool"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Localization")
    ],
    targets: [
        .target(
            name: "FeatureAnnouncementsUI",
            dependencies: [
                .target(name: "FeatureAnnouncementsDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .target(
            name: "FeatureAnnouncementsDomain",
            dependencies: [
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "BlockchainUI", package: "Blockchain")
            ]
        ),
        .target(
            name: "FeatureAnnouncementsData",
            dependencies: [
                .target(name: "FeatureAnnouncementsDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network")
            ]
        )
    ]
)
