// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Permissions",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
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
