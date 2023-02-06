// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Permissions",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "PermissionsKit",
            targets: ["PermissionsKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../UIComponents"),
        .package(path: "../Localization"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "PermissionsKit",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        )
    ]
)
