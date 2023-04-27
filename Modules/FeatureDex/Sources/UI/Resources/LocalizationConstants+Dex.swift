// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum L10n {
    enum AssetPicker {}
    enum Onboarding {}
    enum Main {
        enum NoBalance {}
    }
    enum Confirmation {}
    enum Settings {}
}

extension L10n.AssetPicker {

    static var noResults = NSLocalizedString(
        "😞 No results",
        comment: "😞 No results"
    )
}

extension L10n.Settings {

    static let title = NSLocalizedString(
        "Allowed Slippage",
        comment: "Dex: Settings: title"
    )

    static let body = NSLocalizedString(
        "Slippage is the max percentage of price you're willing to allow for your swap to go through. If price changes beyond that, the swap will revert and your assets will be returned.",
        comment: "Dex: Settings: body"
    )
}

extension L10n.Main {

    static let max = NSLocalizedString(
        "Max",
        comment: "Dex: Main"
    )

    static let balance = NSLocalizedString(
        "Balance",
        comment: "Dex: Main"
    )

    static let select = NSLocalizedString(
        "Select",
        comment: "Dex: Main"
    )

    static let estimatedFee = NSLocalizedString(
        "Estimated fee",
        comment: "Dex: Main"
    )

    static let flip = NSLocalizedString(
        "Flip",
        comment: "Dex: Main"
    )

    static let settings = NSLocalizedString(
        "Settings",
        comment: "Dex: Main"
    )
}

extension L10n.Main.NoBalance {

    static let title = NSLocalizedString(
        "To get started, transfer to your wallets",
        comment: "Dex: Main"
    )

    static let body = NSLocalizedString(
        "Transfer from your Blockchain.com Account, send from any exchange, or ask a friend!",
        comment: "Dex: Main"
    )

    static let button = NSLocalizedString(
        "Receive",
        comment: "Dex: Main"
    )
}

extension L10n.Confirmation {
    static let gotIt = NSLocalizedString(
        "Got it",
        comment: "Dex: Main"
    )

    static let exchangeRate = NSLocalizedString(
        "Exchange Rate",
        comment: "Dex: Main"
    )

    static let allowedSlippage = NSLocalizedString(
        "Allowed Slippage",
        comment: "Dex: Main"
    )

    static let minAmount = NSLocalizedString(
        "Min. Amount",
        comment: "Dex: Main"
    )

    static let minAmountDescription = NSLocalizedString(
        "The minimum amount you are guaranteed to receive. If the price changes more than 0.5%, your transaction will revert.",
        comment: "Dex: Main"
    )

    static let networkFee = NSLocalizedString(
        "Network Fee",
        comment: "Dex: Main"
    )

    static let networkFeeDescription = NSLocalizedString(
        "A fee paid to process your transaction. This must be paid in %@.",
        comment: "Dex: Main"
    )

    static let blockchainFee = NSLocalizedString(
        "Blockchain.com fee",
        comment: "Dex: Main"
    )

    static let blockchainFeeDescription = NSLocalizedString(
        "This is a small fee for using the Blockchain.com DEX service.",
        comment: "Dex: Main"
    )

    static let swap = NSLocalizedString(
        "Swap",
        comment: "Dex: Main"
    )

    static let priceUpdated = NSLocalizedString(
        "Price updated",
        comment: "Dex: Main"
    )

    static let accept = NSLocalizedString(
        "Accept",
        comment: "Dex: Main"
    )

    static let disclaimer = NSLocalizedString(
        "Input is estimated. You will receive at least %@ or the transaction will revert and assets will be returned to your wallet.",
        comment: "Dex: Main"
    )

    static let notEnoughBalance = NSLocalizedString(
        "Not enough %@ to cover swap and fees.",
        comment: "Dex: Main"
    )

    static let notEnoughBalanceButton = NSLocalizedString(
        "Not enough %@",
        comment: "Dex: Main"
    )
}

extension L10n.Onboarding {
    static let button = NSLocalizedString(
        "Start Trading",
        comment: "Dex: Intro button"
    )

    enum Welcome {
        static let title = NSLocalizedString(
            "Welcome to the DEX",
            comment: "Dex: Intro Step 1 title"
        )
        static let description = NSLocalizedString(
            "A decentralized exchange (DEX) is a peer-to-peer marketplace that lets you swap cryptocurrencies.",
            comment: "Dex: Intro Step 1 description"
        )
    }

    enum SwapTokens {
        static let title = NSLocalizedString(
            "Swap 1000+ tokens",
            comment: "Dex: Intro Step 2 title"
        )
        static let description = NSLocalizedString(
            "Swap ETH, UNI, USDT, DAI, and more.",
            comment: "Dex: Intro Step 2 description"
        )
    }

    enum KeepControl {
        static let title = NSLocalizedString(
            "Keep control of your funds",
            comment: "Dex: Intro Step 3 title"
        )
        static let description = NSLocalizedString(
            "When you trade on a DEX, you keep access to your private keys––it’s \"your keys, your crypto.\" Blockchain.com doesn’t hold these funds.",
            comment: "Dex: Intro Step 3 description"
        )
    }
}
