// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RxAnalytics",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "RxAnalyticsKit",
            targets: ["RxAnalyticsKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.5.0"
        ),
        .package(path: "../Analytics")
    ],
    targets: [
        .target(
            name: "RxAnalyticsKit",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "RxSwift", package: "RxSwift")
            ]
        )
    ]
)
