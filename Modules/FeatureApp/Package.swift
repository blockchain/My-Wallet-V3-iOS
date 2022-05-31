// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "FeatureApp",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "FeatureApp", targets: ["FeatureAppUI", "FeatureAppDomain"]),
        .library(name: "FeatureAppUI", targets: ["FeatureAppUI"]),
        .library(name: "FeatureAppDomain", targets: ["FeatureAppDomain"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.2.0"
        ),
        .package(
            url: "https://github.com/jackpooleybc/DIKit.git",
            branch: "safe-property-wrappers"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.34.0"
        ),
        .package(
            url: "https://github.com/embrace-io/embrace-spm",
            from: "5.7.7"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../CryptoAssets"),
        .package(path: "../FeatureActivity"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../FeatureCardIssuing"),
        .package(path: "../FeatureCardPayment"),
        .package(path: "../FeatureCoin"),
        .package(path: "../FeatureDashboard"),
        .package(path: "../FeatureDebug"),
        .package(path: "../FeatureInterest"),
        .package(path: "../FeatureOnboarding"),
        .package(path: "../FeatureOpenBanking"),
        .package(path: "../FeatureQRCodeScanner"),
        .package(path: "../FeatureProducts"),
        .package(path: "../FeatureSettings"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../FeatureAppUpgrade"),
        .package(path: "../FeatureWalletConnect"),
        .package(path: "../FeatureWithdrawalLocks"),
        .package(path: "../Localization"),
        .package(path: "../Money"),
        .package(path: "../Observability"),
        .package(path: "../Platform"),
        .package(path: "../RemoteNotifications"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../WalletPayload")
    ],
    targets: [
        .target(
            name: "FeatureAppUI",
            dependencies: [
                .target(name: "FeatureAppDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "BitcoinChainKit", package: "CryptoAssets"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Embrace", package: "embrace-spm"),
                .product(name: "ERC20Kit", package: "CryptoAssets"),
                .product(name: "FeatureActivityUI", package: "FeatureActivity"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureAuthenticationUI", package: "FeatureAuthentication"),
                .product(name: "FeatureCardIssuingDomain", package: "FeatureCardIssuing"),
                .product(name: "FeatureCardIssuingUI", package: "FeatureCardIssuing"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment"),
                .product(name: "FeatureCoinDomain", package: "FeatureCoin"),
                .product(name: "FeatureCoinData", package: "FeatureCoin"),
                .product(name: "FeatureCoinUI", package: "FeatureCoin"),
                .product(name: "FeatureDashboardUI", package: "FeatureDashboard"),
                .product(name: "FeatureDebugUI", package: "FeatureDebug"),
                .product(name: "FeatureInterestUI", package: "FeatureInterest"),
                .product(name: "FeatureOnboardingUI", package: "FeatureOnboarding"),
                .product(name: "FeatureOpenBankingDomain", package: "FeatureOpenBanking"),
                .product(name: "FeatureOpenBankingUI", package: "FeatureOpenBanking"),
                .product(name: "FeatureQRCodeScannerDomain", package: "FeatureQRCodeScanner"),
                .product(name: "FeatureQRCodeScannerUI", package: "FeatureQRCodeScanner"),
                .product(name: "FeatureSettingsDomain", package: "FeatureSettings"),
                .product(name: "FeatureSettingsUI", package: "FeatureSettings"),
                .product(name: "FeatureTransactionUI", package: "FeatureTransaction"),
                .product(name: "FeatureAppUpgradeDomain", package: "FeatureAppUpgrade"),
                .product(name: "FeatureAppUpgradeUI", package: "FeatureAppUpgrade"),
                .product(name: "FeatureWalletConnectDomain", package: "FeatureWalletConnect"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ObservabilityKit", package: "Observability"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RemoteNotificationsKit", package: "RemoteNotifications"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "FeatureCardIssuingUI", package: "FeatureCardIssuing"),
                .product(name: "FeatureCardIssuingDomain", package: "FeatureCardIssuing")
            ]
        ),
        .target(
            name: "FeatureAppDomain",
            dependencies: [
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureProductsDomain", package: "FeatureProducts"),
                .product(name: "FeatureSettingsDomain", package: "FeatureSettings"),
                .product(name: "FeatureWithdrawalLocksData", package: "FeatureWithdrawalLocks"),
                .product(name: "FeatureWithdrawalLocksDomain", package: "FeatureWithdrawalLocks"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        )
    ]
)
