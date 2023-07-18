// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeaturePin",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeaturePin",
            targets: ["FeaturePin"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.6.0"
        ),
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Extensions"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../FeatureSettings"),
        .package(path: "../Localization"),
        .package(path: "../Platform"),
        .package(path: "../RemoteNotifications"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../WalletPayload")
    ],
    targets: [
        .target(
            name: "FeaturePin",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "FeatureAuthenticationUI", package: "FeatureAuthentication"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureSettingsDomain", package: "FeatureSettings"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RemoteNotificationsKit", package: "RemoteNotifications"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        )
    ]
)
