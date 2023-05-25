// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureAddressSearch",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureAddressSearch",
            targets: [
                "FeatureAddressSearchDomain",
                "FeatureAddressSearchUI",
                "FeatureAddressSearchData"
            ]
        ),
        .library(
            name: "FeatureAddressSearchUI",
            targets: ["FeatureAddressSearchUI"]
        ),
        .library(
            name: "FeatureAddressSearchDomain",
            targets: ["FeatureAddressSearchDomain"]
        ),
        .library(
            name: "FeatureAddressSearchMock",
            targets: ["FeatureAddressSearchMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.53.2"
        ),
        .package(path: "../Localization"),
        .package(path: "../UIComponents"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Tool"),
        .package(path: "../Money")
    ],
    targets: [
        .target(
            name: "FeatureAddressSearchDomain",
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
            name: "FeatureAddressSearchData",
            dependencies: [
                .target(name: "FeatureAddressSearchDomain"),
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
            name: "FeatureAddressSearchUI",
            dependencies: [
                .target(name: "FeatureAddressSearchDomain"),
                .target(name: "FeatureAddressSearchData"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ErrorsUI", package: "Errors")
            ]
        ),
        .target(
            name: "FeatureAddressSearchMock",
            dependencies: [
                .target(name: "FeatureAddressSearchData"),
                .target(name: "FeatureAddressSearchDomain")
            ]
        ),
        .testTarget(
            name: "FeatureAddressSearchDataTests",
            dependencies: [
                .target(name: "FeatureAddressSearchData")
            ]
        ),
        .testTarget(
            name: "FeatureAddressSearchDomainTests",
            dependencies: [
                .target(name: "FeatureAddressSearchDomain")
            ]
        ),
        .testTarget(
            name: "FeatureAddressSearchUITests",
            dependencies: [
                .target(name: "FeatureAddressSearchUI"),
                .target(name: "FeatureAddressSearchMock")
            ]
        )
    ]
)
