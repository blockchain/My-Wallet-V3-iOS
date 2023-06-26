// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "RxAnalytics",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
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
