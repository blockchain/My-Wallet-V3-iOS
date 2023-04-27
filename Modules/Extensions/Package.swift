// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Extensions",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "Extensions", targets: ["Extensions"]),
        .library(name: "CombineExtensions", targets: ["CombineExtensions"]),
        .library(name: "SwiftExtensions", targets: ["SwiftExtensions"]),
        .library(name: "SwiftUIExtensions", targets: ["SwiftUIExtensions"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.4"
        ),
        .package(
            url: "https://github.com/apple/swift-async-algorithms.git",
            revision: "cf70e78632e990cd041fef21044e54fa5fdd1c56"
        ),
        .package(
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.9.1"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths",
            from: "0.11.0"
        )
    ],
    targets: [
        .target(
            name: "Extensions",
            dependencies: [
                "AsyncExtensions",
                "CombineExtensions",
                "SwiftExtensions",
                "SwiftUIExtensions",
                .target(
                    name: "UIKitExtensions",
                    condition: .when(platforms: [.iOS])
                )
            ]
        ),
        .target(
            name: "AsyncExtensions",
            dependencies: [
                "SwiftExtensions",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
        .target(
            name: "CombineExtensions",
            dependencies: [
                .target(name: "SwiftExtensions"),
                .product(name: "CombineSchedulers", package: "combine-schedulers")
            ]
        ),
        .target(
            name: "SwiftExtensions",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "CasePaths", package: "swift-case-paths")
            ]
        ),
        .target(
            name: "SwiftUIExtensions",
            dependencies: ["SwiftExtensions"]
        ),
        .target(
            name: "UIKitExtensions",
            dependencies: ["SwiftExtensions"]
        ),
        .testTarget(
            name: "ExtensionsTests",
            dependencies: ["Extensions"]
        ),
        .testTarget(
            name: "AsyncExtensionsTests",
            dependencies: ["AsyncExtensions"]
        ),
        .testTarget(
            name: "CombineExtensionsTests",
            dependencies: ["AsyncExtensions", "CombineExtensions"]
        ),
        .testTarget(
            name: "SwiftExtensionsTests",
            dependencies: ["SwiftExtensions"]
        )
    ]
)
