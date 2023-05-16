// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureSuperAppIntro",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureSuperAppIntro",
            targets: ["FeatureSuperAppIntroUI"]
        ),
        .library(
            name: "FeatureSuperAppIntroUI",
            targets: ["FeatureSuperAppIntroUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
        .package(path: "../Tool"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Localization")
    ],
    targets: [
        .target(
            name: "FeatureSuperAppIntroUI",
            dependencies: [
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                )
            ]
        )
    ]
)
