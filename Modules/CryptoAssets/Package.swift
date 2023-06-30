// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "CryptoAssets",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "BitcoinCashKit", targets: ["BitcoinCashKit"]),
        .library(name: "BitcoinChainKit", targets: ["BitcoinChainKit"]),
        .library(name: "BitcoinKit", targets: ["BitcoinKit"]),
        .library(name: "EthereumKit", targets: ["EthereumKit"]),
        .library(name: "EthereumDataKit", targets: ["EthereumDataKit"]),
        .library(name: "ERC20Kit", targets: ["ERC20Kit"]),
        .library(name: "ERC20DataKit", targets: ["ERC20DataKit"]),
        .library(name: "StellarKit", targets: ["StellarKit"]),
        .library(name: "BitcoinChainKitMock", targets: ["BitcoinChainKitMock"]),
        .library(name: "BitcoinKitMock", targets: ["BitcoinKitMock"]),
        .library(name: "EthereumKitMock", targets: ["EthereumKitMock"]),
        .library(name: "ERC20KitMock", targets: ["ERC20KitMock"]),
        .library(name: "StellarKitMock", targets: ["StellarKitMock"])
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
            from: "6.5.0"
        ),
        .package(
            url: "https://github.com/Soneso/stellar-ios-mac-sdk.git",
            exact: "2.2.5"
        ),
        .package(
            url: "https://github.com/oliveratkinson-bc/wallet-core.git",
            from: "2.9.8-blockchain"
        ),
        .package(
            url: "https://github.com/paulo-bc/YenomBitcoinKit.git",
            branch: "paulo/dust-mixing-crypto-swift"
        ),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Metadata"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Money"),
        .package(path: "../Platform"),
        .package(path: "../FeatureCryptoDomain"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../WalletPayload")
    ],
    targets: [
        .target(
            name: "BitcoinCashKit",
            dependencies: [
                .target(name: "BitcoinChainKit"),
                .target(name: "_BitcoinSDK"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "FeatureCryptoDomainDomain", package: "FeatureCryptoDomain"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "BitcoinChainKit",
            dependencies: [
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "WalletCore", package: "wallet-core"),
                .product(name: "MetadataKit", package: "Metadata")
            ]
        ),
        .target(
            name: "BitcoinKit",
            dependencies: [
                .target(name: "BitcoinChainKit"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "FeatureCryptoDomainDomain", package: "FeatureCryptoDomain"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "WalletCore", package: "wallet-core")
            ]
        ),
        .target(
            name: "ERC20DataKit",
            dependencies: [
                .target(name: "ERC20Kit"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "ERC20Kit",
            dependencies: [
                .target(name: "EthereumKit"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "EthereumDataKit",
            dependencies: [
                .target(name: "EthereumKit")
            ]
        ),
        .target(
            name: "EthereumKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "FeatureCryptoDomainDomain", package: "FeatureCryptoDomain"),
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "MetadataKit", package: "Metadata"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "WalletCore", package: "wallet-core"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
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
        .target(
            name: "_BitcoinSDK",
            dependencies: [.product(name: "YenomBitcoinKit", package: "YenomBitcoinKit")],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
        .target(
            name: "BitcoinChainKitMock",
            dependencies: [
                .target(name: "BitcoinChainKit")
            ]
        ),
        .target(
            name: "BitcoinKitMock",
            dependencies: [
                .target(name: "BitcoinKit")
            ]
        ),
        .target(
            name: "ERC20DataKitMock",
            dependencies: [
                .target(name: "ERC20DataKit")
            ]
        ),
        .target(
            name: "ERC20KitMock",
            dependencies: [
                .target(name: "ERC20Kit")
            ]
        ),
        .target(
            name: "EthereumKitMock",
            dependencies: [
                .target(name: "EthereumKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .target(
            name: "StellarKitMock",
            dependencies: [
                .target(name: "StellarKit"),
                .product(name: "RxSwift", package: "RxSwift")
            ]
        ),
        .testTarget(
            name: "BitcoinCashKitTests",
            dependencies: [
                .target(name: "BitcoinCashKit"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "BitcoinChainKitTests",
            dependencies: [
                .target(name: "BitcoinChainKit"),
                .target(name: "BitcoinChainKitMock"),
                .product(name: "TestKit", package: "Test")
            ],
            resources: [
                .process("Fixtures")
            ]
        ),
        .testTarget(
            name: "BitcoinKitTests",
            dependencies: [
                .target(name: "BitcoinKit"),
                .target(name: "BitcoinKitMock"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "ERC20DataKitTests",
            dependencies: [
                .target(name: "ERC20DataKit"),
                .target(name: "ERC20DataKitMock"),
                .target(name: "ERC20Kit"),
                .target(name: "ERC20KitMock"),
                .target(name: "EthereumKit"),
                .product(name: "MoneyKitMock", package: "Money"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "ERC20KitTests",
            dependencies: [
                .target(name: "ERC20Kit"),
                .target(name: "ERC20KitMock"),
                .product(name: "MoneyKitMock", package: "Money"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "EthereumKitTests",
            dependencies: [
                .target(name: "EthereumKit"),
                .target(name: "EthereumKitMock"),
                .product(name: "MoneyKitMock", package: "Money"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "StellarKitTests",
            dependencies: [
                .target(name: "StellarKit"),
                .target(name: "StellarKitMock"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "RxBlocking", package: "RxSwift")
            ],
            resources: [
                .copy("account_response.json")
            ]
        )
    ]
)
