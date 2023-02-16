// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "BlockchainComponentLibrary",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "BlockchainComponentLibrary",
            targets: [
                "BlockchainComponentLibrary"
            ]
        ),
        .library(
            name: "Examples",
            targets: [
                "Examples"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.10.0"
        ),
        .package(
            url: "https://github.com/apple/swift-markdown.git",
            revision: "52563fc74a540b29854fde20e836b27394be2749"
        ),
        .package(
            url: "https://github.com/airbnb/lottie-ios.git",
            from: "3.3.0"
        ),
        .package(
            url: "https://github.com/kean/Nuke.git",
            from: "11.3.0"
        ),
        .package(path: "../Extensions")
    ],
    targets: [
        .target(
            name: "BlockchainComponentLibrary",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "NukeExtensions", package: "Nuke"),
                .product(name: "Extensions", package: "Extensions")
            ],
            resources: [
                .process("Resources/Fonts"),
                .copy("Resources/Animation/loader.json")
            ]
        ),
        .testTarget(
            name: "BlockchainComponentLibraryTests",
            dependencies: [
                .target(name: "BlockchainComponentLibrary"),
                .target(name: "Examples"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: [
                "1 - Base/__Snapshots__",
                "2 - Primitives/__Snapshots__",
                "2 - Primitives/Buttons/__Snapshots__",
                "3 - Compositions/__Snapshots__",
                "3 - Compositions/Rows/__Snapshots__",
                "3 - Compositions/SectionHeaders/__Snapshots__",
                "3 - Compositions/Sheets/__Snapshots__",
                "Utilities/__Snapshots__"
            ]
        ),
        .target(
            name: "Examples",
            dependencies: [
                "BlockchainComponentLibrary"
            ]
        )
    ]
)
