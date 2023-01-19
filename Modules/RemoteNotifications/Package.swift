// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RemoteNotifications",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "RemoteNotificationsKit",
            targets: ["RemoteNotificationsKit"]
        ),
        .library(
            name: "RemoteNotificationsKitMock",
            targets: ["RemoteNotificationsKitMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Analytics"),
        .package(path: "../Network"),
        .package(path: "../Tool"),
        .package(path: "../FeatureAuthentication")
    ],
    targets: [
        .target(
            name: "RemoteNotificationsKit",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication")
            ]
        ),
        .target(
            name: "RemoteNotificationsKitMock",
            dependencies: [
                .target(name: "RemoteNotificationsKit")
            ],
            resources: [
                .copy("remote-notification-registration-failure.json"),
                .copy("remote-notification-registration-success.json")
            ]
        ),
        .testTarget(
            name: "RemoteNotificationsKitTests",
            dependencies: [
                .target(name: "RemoteNotificationsKit"),
                .target(name: "RemoteNotificationsKitMock"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "NetworkKitMock", package: "Network")
            ]
        )
    ]
)
