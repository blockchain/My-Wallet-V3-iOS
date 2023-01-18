// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// swiftlint:disable line_length

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
    public enum SuperAppIntro {
        public enum CarouselPage1 {}
        public enum CarouselPage2 {}
        public enum CarouselPage3 {}
        public enum CarouselPage4 {}
    }
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
        "Introducing the %@",
        comment: "Introducing the %@"
    )
    public static let subtitle = NSLocalizedString(
        "Explore all of Web3 and DeFi in one place",
        comment: "Explore all of Web3 and DeFi in one place"
    )

    public static let step1Title = NSLocalizedString(
        "Self-Custody Your Assets",
        comment: "Self-Custody Your Assets"
    )
    public static let step1Subtitle = NSLocalizedString(
        "DeFi wallets are on-chain",
        comment: "DeFi wallets are on-chain"
    )
    public static let step2Title = NSLocalizedString(
        "Multi-chain Support",
        comment: "Multi-chain Support"
    )
    public static let step2Subtitle = NSLocalizedString(
        "Manage your portfolio across 7 chains",
        comment: "Manage your portfolio across 7 chains"
    )
    public static let step3Title = NSLocalizedString(
        "Connect to Decentralized Finance",
        comment: "Connect to Decentralized Finance"
    )
    public static let step3Subtitle = NSLocalizedString(
        "Log into DApps and sign transactions",
        comment: "Log into DApps and sign transactions"
    )

    public static let enableButton = NSLocalizedString(
        "Enable %@",
        comment: "Enable DeFi Wallet"
    )
}

extension LocalizationConstants.SuperAppIntro {
    public static let getStartedButton = NSLocalizedString(
        "Get Started",
        comment: "Get Started"
    )
}

extension LocalizationConstants.SuperAppIntro.CarouselPage1 {
    public static let title = NSLocalizedString(
        "Your Wallet just got better",
        comment: "Your Wallet just got better"
    )
    public static let subtitle = NSLocalizedString(
        "We’ve made some major improvements to the Blockchain.com app.",
        comment: "We’ve made some major improvements to the Blockchain.com app."
    )
}

extension LocalizationConstants.SuperAppIntro.CarouselPage2 {
    public static let title = NSLocalizedString(
        "A new way to navigate",
        comment: "A new way to navigate"
    )
    public static let subtitle = NSLocalizedString(
        "Switch easily between your Trading Account and %@.",
        comment: "Switch easily between your Trading Account and DeFi Wallet."
    )
}

extension LocalizationConstants.SuperAppIntro.CarouselPage3 {
    public static let title = NSLocalizedString(
        "Your new home for DeFi",
        comment: "Your new home for DeFi"
    )
    public static let subtitle = NSLocalizedString(
        "Access your %@ and engage with web3 and decentralized finance.",
        comment: "Access your %@ and engage with web3 and decentralized finance."
    )

    public static let badge = NSLocalizedString(
        "Held by You",
        comment: "Held by You"
    )
}

extension LocalizationConstants.SuperAppIntro.CarouselPage4 {
    public static let title = NSLocalizedString(
        "Your trading account",
        comment: "Your trading account"
    )

    public static let subtitle = NSLocalizedString(
        "Access your Trading and Rewards accounts and buy and sell crypto.",
        comment: "Access your Trading and Rewards accounts and buy and sell crypto."
    )

    public static let badge = NSLocalizedString(
        "Held by Blockchain.com",
        comment: "Held by Blockchain.com"
    )
}

extension LocalizationConstants.DefiBuyCryptoSheet {
    public static let message = NSLocalizedString(
        "We don’t support buying crypto into your %@ at this time. You can buy from your Trading Account and send to your %@.",
        comment: "We don’t support buying crypto into your DeFi Wallet at this time. You can buy from your Trading Account and send to your DeFi Wallet."
    )

    public static let ctaButton = NSLocalizedString(
        "Open Trading Account",
        comment: "Open Trading Account"
    )
}
