// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Errors",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Errors",
            targets: ["Errors"]
        ),
        .library(
            name: "ErrorsUI",
            targets: ["ErrorsUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.11.1"
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.4"
        ),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../Localization"),
        .package(path: "../Extensions"),
        .package(path: "../AnyCoding")
    ],
    targets: [
        .target(
            name: "Errors",
            dependencies: [
                .product(name: "AnyCoding", package: "AnyCoding"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .target(
            name: "ErrorsUI",
            dependencies: [
                .target(name: "Errors")
            ]
        ),
        .testTarget(
            name: "ErrorsTests",
            dependencies: [
                .target(name: "Errors")
            ]
        ),

        .testTarget(
            name: "ErrorsUITests",
            dependencies: [
                .target(name: "ErrorsUI"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: ["__Snapshots__"]
        )
    ]
)
