// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "WalletPayload",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "WalletPayloadKit", targets: ["WalletPayloadKit"]),
        .library(name: "WalletPayloadDataKit", targets: ["WalletPayloadDataKit"]),
        .library(name: "WalletPayloadKitMock", targets: ["WalletPayloadKitMock"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/dchatzieleftheriou-bc/DIKit.git",
            exact: "1.0.1"
        ),
        .package(path: "../Observability"),
        .package(path: "../Localization"),
        .package(path: "../CommonCrypto"),
        .package(path: "../Keychain"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Metadata"),
        .package(path: "../Test"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "WalletPayloadKit",
            dependencies: [
                .product(name: "ObservabilityKit", package: "Observability"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "KeychainKit", package: "Keychain"),
                .product(name: "MetadataKit", package: "Metadata"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "DIKit", package: "DIKit")
            ]
        ),
        .target(
            name: "WalletPayloadDataKit",
            dependencies: [
                .target(name: "WalletPayloadKit"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "KeychainKit", package: "Keychain"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "WalletPayloadKitMock",
            dependencies: [
                .target(name: "WalletPayloadKit"),
                .target(name: "WalletPayloadDataKit")
            ]
        ),
        .testTarget(
            name: "WalletPayloadKitTests",
            dependencies: [
                .target(name: "WalletPayloadDataKit"),
                .target(name: "WalletPayloadKit"),
                .target(name: "WalletPayloadKitMock"),
                .product(name: "ObservabilityKit", package: "Observability"),
                .product(name: "MetadataKitMock", package: "Metadata"),
                .product(name: "KeychainKitMock", package: "Keychain"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "NetworkKitMock", package: "Network"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "ToolKitMock", package: "Tool")
            ],
            resources: [
                .copy("Fixtures/wallet-wrapper-v4.json"),
                .copy("Fixtures/wallet-data.json"),
                .copy("Fixtures/address-label.json"),
                .copy("Fixtures/hdaccount.v3.json"),
                .copy("Fixtures/hdaccount.v3.broken.json"),
                .copy("Fixtures/hdaccount.v4.json"),
                .copy("Fixtures/hdaccount.v4.broken.json"),
                .copy("Fixtures/hdaccount.v4.unknown.json"),
                .copy("Fixtures/wallet.v3.json"),
                .copy("Fixtures/wallet.v4.json"),
                .copy("Fixtures/wallet.v3.broken.json"),
                .copy("Fixtures/wallet.v4.broken.json"),
                .copy("Fixtures/wallet.v4-secpass.json"),
                .copy("Fixtures/wallet.v4.broken_addressCache.json"),
                .copy("Fixtures/hdwallet.v3.json"),
                .copy("Fixtures/hdwallet.v4.json"),
                .copy("Fixtures/hdwallet.unknown.json"),
                .copy("Fixtures/hdaccount.v4.missingCache.json")
            ]
        )
    ]
)
