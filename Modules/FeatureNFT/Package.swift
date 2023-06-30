// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureNFT",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureNFT",
            targets: [
                "FeatureNFTDomain",
                "FeatureNFTUI",
                "FeatureNFTData"
            ]
        ),
        .library(
            name: "FeatureNFTUI",
            targets: ["FeatureNFTUI"]
        ),
        .library(
            name: "FeatureNFTDomain",
            targets: ["FeatureNFTDomain"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.54.1"
        ),
        .package(path: "../Localization"),
        .package(path: "../UIComponents"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureNFTDomain",
            dependencies: [
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "ToolKit",
                    package: "Tool"
                )
            ]
        ),
        .target(
            name: "FeatureNFTData",
            dependencies: [
                .target(name: "FeatureNFTDomain"),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                )
            ]
        ),
        .target(
            name: "FeatureNFTUI",
            dependencies: [
                .target(name: "FeatureNFTDomain"),
                .target(name: "FeatureNFTData"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureNFTDataTests",
            dependencies: [
                .target(name: "FeatureNFTData")
            ]
        ),
        .testTarget(
            name: "FeatureNFTDomainTests",
            dependencies: [
                .target(name: "FeatureNFTDomain")
            ]
        ),
        .testTarget(
            name: "FeatureNFTUITests",
            dependencies: [
                .target(name: "FeatureNFTUI")
            ]
        )
    ]
)
