// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "AnyCoding",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "AnyCoding", targets: ["AnyCoding"])
    ],
    dependencies: [
        .package(path: "../Extensions")
    ],
    targets: [
        .target(
            name: "AnyCoding",
            dependencies: [
                .product(name: "SwiftExtensions", package: "Extensions")
            ]
        ),
        .testTarget(
            name: "AnyCodingTests",
            dependencies: ["AnyCoding"]
        )
    ]
)
