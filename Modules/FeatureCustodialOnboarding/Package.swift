// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureCustodialOnboarding",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureCustodialOnboarding",
            targets: ["FeatureCustodialOnboarding"]
        )
    ],
    dependencies: [
        .package(path: "../Blockchain"),
        .package(path: "../FeatureQuickActions"),
        .package(path: "../FeatureExternalTradingMigration"),
        .package(path: "../Network")
    ],
    targets: [
        .target(
            name: "FeatureCustodialOnboarding",
            dependencies: [
                .product(
                    name: "Blockchain",
                    package: "Blockchain"
                ),
                .product(
                    name: "BlockchainUI",
                    package: "Blockchain"
                ),
                .product(
                    name: "FeatureQuickActions",
                    package: "FeatureQuickActions"
                ),
                .product(
                    name: "FeatureExternalTradingMigrationUI",
                    package: "FeatureExternalTradingMigration"
                ),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                )
            ]
        ),
        .testTarget(
            name: "FeatureCustodialOnboardingTests",
            dependencies: ["FeatureCustodialOnboarding"]
        )
    ]
)
