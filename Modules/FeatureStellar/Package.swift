// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "FeatureStellar",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "StellarKit", targets: ["StellarKit"])
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
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.6.0"
        ),
        .package(
            url: "https://github.com/Soneso/stellar-ios-mac-sdk.git",
            exact: "2.4.9"
        ),
        .package(path: "../Platform"),
        .package(path: "../FeatureCryptoDomain"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../Test"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "StellarKit",
            dependencies: [
                .target(name: "_StellarSDK"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "FeatureCryptoDomainDomain", package: "FeatureCryptoDomain"),
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "_StellarSDK",
            dependencies: [.product(name: "stellarsdk", package: "stellar-ios-mac-sdk")],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
        .testTarget(
            name: "StellarKitTests",
            dependencies: [
                .target(name: "StellarKit"),
                .product(name: "TestKit", package: "Test")
            ],
            resources: [ .copy("Resources/account_response.json") ]
        )
    ]
)
