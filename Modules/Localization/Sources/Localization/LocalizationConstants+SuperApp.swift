// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum AppMode {}
}

extension LocalizationConstants {
    public enum DefiWalletIntro {}
}

extension LocalizationConstants {
    public enum AppModeSwitcher {}
}

extension LocalizationConstants {
    public enum DefiBuyCryptoSheet {}
}

extension LocalizationConstants {
    public enum SuperAppIntro {}
}

extension LocalizationConstants.AppMode {
    public static let privateKeyWallet = NonLocalizedConstants.defiWalletTitle

    public static let tradingAccount = NSLocalizedString(
        "Accounts",
        comment: "Accounts"
    )
}

extension LocalizationConstants.AppModeSwitcher {
    public static let totalBalanceLabel = NSLocalizedString(
        "Your Total Balance",
        comment: "Your Total Balance"
    )
    public static let defiSubtitle = NSLocalizedString(
        "Enable to get Started",
        comment: "Enable to get Started"
    )
    public static let defiDescription = NSLocalizedString(
        "Connect to web3 apps, collect NFTs, and swap on DEXs.",
        comment: "Connect to web3 apps, collect NFTs, and swap on DEXs."
    )
}

extension LocalizationConstants.DefiWalletIntro {
    public static let title = NSLocalizedString(
        "Introducing your non-custodial \nDeFi Wallet",
        comment: "Introducing your non-custodial \nDeFi Wallet"
    )
    public static let subtitle = NSLocalizedString(
        "Use Bitcoin and DeFi, all in on place.",
        comment: "Explore all of Web3 and DeFi in one place"
    )

    public static let step1Title = NSLocalizedString(
        "Self-Custody Your Assets",
        comment: "Self-Custody Your Assets"
    )
    public static let step1Subtitle = NSLocalizedString(
        "Your DeFi Wallet is on chain",
        comment: "Your DeFi Wallet is on chain"
    )
    public static let step2Title = NSLocalizedString(
        "Multi-chain Support",
        comment: "Multi-chain Support"
    )
    public static let step2Subtitle = NSLocalizedString(
        "Manage your assets across multiple chains",
        comment: "Manage your assets across multiple chains"
    )
    public static let step3Title = NSLocalizedString(
        "Connect to DeFi",
        comment: "Connect to DeFi"
    )
    public static let step3Subtitle = NSLocalizedString(
        "Log into DApps and sign transactions",
        comment: "Log into DApps and sign transactions"
    )

    public static let enableButton = NSLocalizedString(
        "Go to DeFi Wallet",
        comment: "Go to DeFi Wallet"
    )
}

extension LocalizationConstants.SuperAppIntro {
    public static let getStartedButton = NSLocalizedString(
        "Get Started",
        comment: "Get Started"
    )
}

extension LocalizationConstants.DefiBuyCryptoSheet {
    public static let message = NSLocalizedString(
        "We don’t support buying crypto into your %@ at this time. You can buy from your Blockchain.com Account and send to your %@.",
        comment: "We don’t support buying crypto into your DeFi Wallet at this time. You can buy from your Blockchain.com Account and send to your DeFi Wallet."
    )

    public static let ctaButton = NSLocalizedString(
        "Open Blockchain.com Account",
        comment: "Open Blockchain.com Account"
    )
}
