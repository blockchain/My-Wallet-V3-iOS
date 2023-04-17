// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Add_Test_Targets",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .executable(name: "add_test_targets", targets: ["Add_Test_Targets"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/tuist/XcodeProj.git",
            .upToNextMajor(from: "8.9.0")
        )
    ],
    targets: [
        .executableTarget(
            name: "Add_Test_Targets",
            dependencies: [
                .product(name: "XcodeProj", package: "XcodeProj")
            ],
            path: "Sources"
        )
    ]
)
