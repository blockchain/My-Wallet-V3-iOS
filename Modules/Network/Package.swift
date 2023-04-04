// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        ),
        .library(
            name: "NetworkKitMock",
            targets: ["NetworkKitMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(name: "AnyCoding", path: "../AnyCoding"),
        .package(name: "Analytics", path: "../Analytics"),
        .package(name: "Test", path: "../Test"),
        .package(name: "Tool", path: "../Tool"),
        .package(name: "Errors", path: "../Errors")
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(name: "AnyCoding", package: "AnyCoding"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors")
            ]
        ),
        .target(
            name: "NetworkKitMock",
            dependencies: [
                .target(name: "NetworkKit"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                .target(name: "NetworkKit"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
