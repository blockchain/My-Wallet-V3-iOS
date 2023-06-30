// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "AnyCoding",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
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
