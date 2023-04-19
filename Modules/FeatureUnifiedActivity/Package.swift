// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureUnifiedActivity",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureUnifiedActivity",
            targets: ["UnifiedActivityDomain", "UnifiedActivityData", "UnifiedActivityUI"]
        ),
        .library(
            name: "UnifiedActivityDomain",
            targets: ["UnifiedActivityDomain"]
        ),
        .library(
            name: "UnifiedActivityData",
            targets: ["UnifiedActivityData"]
        ),
        .library(
            name: "UnifiedActivityUI",
            targets: ["UnifiedActivityUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.3.1"),
        .package(url: "https://github.com/groue/GRDBQuery.git", from: "0.6.0"),
        .package(path: "../Analytics"),
        .package(path: "../DelegatedSelfCustody"),
        .package(path: "../Errors"),
        .package(path: "../Localization"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "UnifiedActivityDomain",
            dependencies: [
                .product(name: "DelegatedSelfCustodyDomain", package: "DelegatedSelfCustody"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "UnifiedActivityData",
            dependencies: [
                .target(name: "UnifiedActivityDomain"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "GRDBQuery", package: "GRDBQuery"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "DelegatedSelfCustodyDomain", package: "DelegatedSelfCustody"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "UnifiedActivityUI",
            dependencies: [
                .target(name: "UnifiedActivityDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool")
            ]
        )
    ]
)
