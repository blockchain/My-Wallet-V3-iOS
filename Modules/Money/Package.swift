// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Money",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
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
        .package(url: "https://github.com/pointfreeco/swift-clocks.git", from: "0.3.0"),
        .package(path: "../Errors"),
        .package(path: "../Tool"),
        .package(path: "../Network")
    ],
    targets: [
        .target(
            name: "MoneyKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Clocks", package: "swift-clocks")
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
