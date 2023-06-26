// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]
        ),
        .library(
            name: "AnalyticsKitMock",
            targets: ["AnalyticsKitMock"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AnalyticsKit"
        ),
        .target(
            name: "AnalyticsKitMock",
            dependencies: [
                .target(name: "AnalyticsKit")
            ]
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            dependencies: [
                .target(name: "AnalyticsKit")
            ]
        )
    ]
)
