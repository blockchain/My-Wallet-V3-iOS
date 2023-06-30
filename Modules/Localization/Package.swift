// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Localization",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "Localization", targets: ["Localization"])
    ],
    targets: [
        .target(name: "Localization")
    ]
)
