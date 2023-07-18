// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "RxTool",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
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
            from: "6.6.0"
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
