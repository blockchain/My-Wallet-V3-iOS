// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Money",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "MoneyKit",
            targets: ["MoneyKit"]
        ),
        .library(
            name: "MoneyKitMock",
            targets: ["MoneyKitMock"]
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
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool")
            ],
            resources: [
                .copy("Data/Resources/local-currencies-coin.json"),
                .copy("Data/Resources/local-currencies-custodial.json"),
                .copy("Data/Resources/local-currencies-ethereum-erc20.json"),
                .copy("Data/Resources/local-currencies-other-erc20.json"),
                .copy("Data/Resources/local-network-config.json")
            ]
        ),
        .target(
            name: "MoneyKitMock",
            dependencies: [
                .target(name: "MoneyKit")
            ]
        ),
        .testTarget(
            name: "MoneyKitTests",
            dependencies: [
                .target(name: "MoneyKit"),
                .target(name: "MoneyKitMock"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
