// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureCardPayment",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureCardPayment",
            targets: ["FeatureCardPaymentData", "FeatureCardPaymentDomain", "FeatureCardPaymentUI"]
        ),
        .library(
            name: "FeatureCardPaymentUI",
            targets: ["FeatureCardPaymentUI"]
        ),
        .library(
            name: "FeatureCardPaymentDomain",
            targets: ["FeatureCardPaymentDomain"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.55.1"
        ),
        .package(
            url: "https://github.com/stripe/stripe-ios",
            from: "22.8.0"
        ),
        .package(
            url: "https://github.com/checkout/frames-ios.git",
            from: "3.5.2"
        ),
        .package(path: "../Analytics"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../Money")
    ],
    targets: [
        .target(
            name: "FeatureCardPaymentDomain",
            dependencies: [
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "FeatureCardPaymentData",
            dependencies: [
                .target(name: "FeatureCardPaymentDomain"),
                .target(name: "FeatureCardPaymentDependencies"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "MoneyKit", package: "Money")
            ]
        ),
        .target(
            name: "FeatureCardPaymentUI",
            dependencies: [
                .target(name: "FeatureCardPaymentDomain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "Frames", package: "frames-ios"),
                .product(name: "Stripe", package: "stripe-ios")
            ]
        ),
        .target(
            name: "FeatureCardPaymentDependencies",
            dependencies: [
                .product(name: "Frames", package: "frames-ios"),
                .product(name: "Stripe", package: "stripe-ios")
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        )
    ]
)
