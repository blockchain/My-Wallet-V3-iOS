// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
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
