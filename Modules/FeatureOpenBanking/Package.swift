// swift-tools-version: 5.8

import Foundation
import PackageDescription

let package = Package(
    name: "FeatureOpenBanking",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureOpenBanking",
            targets: ["FeatureOpenBankingData", "FeatureOpenBankingDomain", "FeatureOpenBankingUI"]
        ),
        .library(
            name: "FeatureOpenBankingData",
            targets: ["FeatureOpenBankingData"]
        ),
        .library(
            name: "FeatureOpenBankingDomain",
            targets: ["FeatureOpenBankingDomain"]
        ),
        .library(
            name: "FeatureOpenBankingUI",
            targets: ["FeatureOpenBankingUI"]
        )
    ],
    dependencies: [
        .package(path: "../Blockchain"),
        .package(path: "../Analytics"),
        .package(path: "../Network"),
        .package(path: "../Test"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureOpenBankingDomain",
            dependencies: [
                .product(name: "Blockchain", package: "Blockchain")
            ]
        ),
        .target(
            name: "FeatureOpenBankingData",
            dependencies: [
                .target(name: "FeatureOpenBankingDomain"),
                .product(name: "Blockchain", package: "Blockchain"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureOpenBankingUI",
            dependencies: [
                .target(name: "FeatureOpenBankingDomain"),
                .target(name: "FeatureOpenBankingData"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BlockchainUI", package: "Blockchain"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        ),
        .target(
            name: "FeatureOpenBankingTestFixture",
            dependencies: [
                .target(name: "FeatureOpenBankingData"),
                .target(name: "FeatureOpenBankingDomain"),
                .product(name: "TestKit", package: "Test")
            ],
            resources: [
                // $ cd Sources/OpenBankingTestFixture
                // $ fd --glob *.json | xargs -L 1 bash -c 'printf ".copy(\"%s\"),\n" "$*" ' bash
                .copy("fixture/DELETE/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/DELETE_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/5adf0e04-ffc5-42ce-bc5b-3ce465016292/GET_nabu-gateway_payments_banktransfer_5adf0e04-ffc5-42ce-bc5b-3ce465016292.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/GET_nabu-gateway_payments_banktransfer.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/GET_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c.json"),
                .copy("fixture/GET/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a/GET_nabu-gateway_payments_payment_b039317d-df85-413f-932d-2719346a839a.json"),
                .copy("fixture/GET/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a/GET_nabu-gateway_payments_payment_b039317d-df85-413f-932d-2719346a839a_pending.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/POST_nabu-gateway_payments_banktransfer.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/payment/POST_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c_payment.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/update/POST_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c_update.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/one-time-token/POST_nabu-gateway_payments_banktransfer_one-time-token.json")
            ]
        ),
        .testTarget(
            name: "FeatureOpenBankingDataTests",
            dependencies: [
                .target(name: "FeatureOpenBankingData"),
                .target(name: "FeatureOpenBankingTestFixture"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureOpenBankingDomainTests",
            dependencies: [
                .target(name: "FeatureOpenBankingData"),
                .target(name: "FeatureOpenBankingDomain"),
                .target(name: "FeatureOpenBankingTestFixture"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureOpenBankingUITests",
            dependencies: [
                .target(name: "FeatureOpenBankingUI"),
                .target(name: "FeatureOpenBankingTestFixture"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
