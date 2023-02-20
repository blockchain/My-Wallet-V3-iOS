// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Money",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "MoneyKit",
            targets: ["MoneyKit"]
        ),
        .library(
            name: "MoneyDataKit",
            targets: ["MoneyDataKit"]
        ),
        .library(
            name: "MoneyDomainKit",
            targets: ["MoneyDomainKit"]
        ),
        .library(
            name: "MoneyDomainKitMock",
            targets: ["MoneyDomainKitMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.3.0"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Errors"),
        .package(path: "../Tool"),
        .package(path: "../Localization"),
        .package(path: "../Network")
    ],
    targets: [
        .target(
            name: "MoneyKit",
            dependencies: [
                .target(name: "MoneyDataKit"),
                .target(name: "MoneyDomainKit")
            ]
        ),
        .target(
            name: "MoneyDomainKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "MoneyDataKit",
            dependencies: [
                .target(name: "MoneyDomainKit"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool")
            ],
            resources: [
                .copy("Resources/local-currencies-coin.json"),
                .copy("Resources/local-currencies-custodial.json"),
                .copy("Resources/local-currencies-ethereum-erc20.json"),
                .copy("Resources/local-currencies-other-erc20.json"),
                .copy("Resources/local-network-config.json")
            ]
        ),
        .target(
            name: "MoneyDomainKitMock",
            dependencies: [
                .target(name: "MoneyDomainKit")
            ]
        ),
        .testTarget(
            name: "MoneyDomainKitTests",
            dependencies: [
                .target(name: "MoneyDomainKit"),
                .target(name: "MoneyDomainKitMock")
            ]
        ),
        .testTarget(
            name: "MoneyDataKitTests",
            dependencies: [
                .target(name: "MoneyDataKit"),
                .target(name: "MoneyDomainKitMock"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
