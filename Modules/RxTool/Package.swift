// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RxTool",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "RxToolKit",
            targets: ["RxToolKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.5.0"
        ),
        .package(path: "../Tool"),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "RxToolKit",
            dependencies: [
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "RxToolKitTests",
            dependencies: [
                .target(name: "RxToolKit"),
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
