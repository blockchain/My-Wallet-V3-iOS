// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureQRCodeScanner",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureQRCodeScanner",
            targets: ["FeatureQRCodeScannerUI", "FeatureQRCodeScannerData", "FeatureQRCodeScannerDomain"]
        ),
        .library(
            name: "FeatureQRCodeScannerUI",
            targets: ["FeatureQRCodeScannerUI"]
        ),
        .library(
            name: "FeatureQRCodeScannerData",
            targets: ["FeatureQRCodeScannerData"]
        ),
        .library(
            name: "FeatureQRCodeScannerDomain",
            targets: ["FeatureQRCodeScannerDomain"]
        ),
        .library(
            name: "FeatureQRCodeScannerMock",
            targets: ["FeatureQRCodeScannerMock"]
        ),
        .library(
            name: "FeatureQRCodeScannerUIMock",
            targets: ["FeatureQRCodeScannerUIMock"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "0.52.0"
        ),
        .package(path: "../Localization"),
        .package(path: "../UIComponents"),
        .package(path: "../Platform"),
        .package(path: "../FeatureWalletConnect")
    ],
    targets: [
        .target(
            name: "FeatureQRCodeScannerDomain",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform")
            ]
        ),
        .target(
            name: "FeatureQRCodeScannerData",
            dependencies: [
                .target(name: "FeatureQRCodeScannerDomain"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "DIKit", package: "DIKit")
            ]
        ),
        .target(
            name: "FeatureQRCodeScannerUI",
            dependencies: [
                .target(name: "FeatureQRCodeScannerData"),
                .target(name: "FeatureQRCodeScannerDomain"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "FeatureWalletConnectDomain", package: "FeatureWalletConnect")
            ]
        ),
        .target(
            name: "FeatureQRCodeScannerMock",
            dependencies: [
                .target(name: "FeatureQRCodeScannerData"),
                .target(name: "FeatureQRCodeScannerDomain"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        ),
        .target(
            name: "FeatureQRCodeScannerUIMock",
            dependencies: [
                .target(name: "FeatureQRCodeScannerUI"),
                .target(name: "FeatureQRCodeScannerData"),
                .target(name: "FeatureQRCodeScannerDomain")
            ]
        ),
        .testTarget(
            name: "FeatureQRCodeScannerTests",
            dependencies: [
                .target(name: "FeatureQRCodeScannerData"),
                .target(name: "FeatureQRCodeScannerMock"),
                .target(name: "FeatureQRCodeScannerUI"),
                .target(name: "FeatureQRCodeScannerUIMock"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "PlatformUIKitMock", package: "Platform")
            ]
        )
    ]
)
