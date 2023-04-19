// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "KeychainKit",
            targets: ["KeychainKit"]
        ),
        .library(
            name: "KeychainKitMock",
            targets: ["KeychainKitMock"]
        )
    ],
    targets: [
        .target(
            name: "KeychainKit"
        ),
        .target(
            name: "KeychainKitMock",
            dependencies: [
                .target(name: "KeychainKit")
            ]
        ),
        .testTarget(
            name: "KeychainKitTests",
            dependencies: [
                .target(name: "KeychainKit")
            ]
        )
    ]
)
