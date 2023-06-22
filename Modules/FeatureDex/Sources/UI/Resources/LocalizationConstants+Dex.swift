// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum L10n {
    enum Allowance {}
    enum AssetPicker {}
    enum Confirmation {}
    enum Execution {}
    enum NetworkPicker {}
    enum Onboarding {}
    enum ProductRouter {}
    enum Settings {}
    enum TransactionInProgress {}
    enum Main {
        enum NoBalance {}
        enum NoBalanceSheet {}
        enum Allowance {}
    }
}

extension L10n.ProductRouter {
    
    static var title = NSLocalizedString(
        "Select an option",
        comment: "Dex: ProductRouter: Screen title"
    )
    
    enum Swap {
        static var title = NSLocalizedString(
            "Blockchain.com Swap",
            comment: "Dex: ProductRouter: Swap title"
        )
        static var body = NSLocalizedString(
            "Cross-chain, limited token pairs",
            comment: "Dex: ProductRouter: Swap body"
        )
    }
    enum Dex {
        static var title = NSLocalizedString(
            "DEX Swap",
            comment: "Dex: ProductRouter: Dex title"
        )
        static var body = NSLocalizedString(
            "Swap thousands of tokens on Ethereum and Polygon",
            comment: "Dex: ProductRouter: Dex body"
        )
        static var new = NSLocalizedString(
            "New",
            comment: "Dex: ProductRouter: Dex new tag"
        )
    }
}

extension L10n.AssetPicker {

    static var noResults = NSLocalizedString(
        "😞 No results",
        comment: "😞 No results"
    )
}

extension L10n.NetworkPicker {

    static var selectNetwork = NSLocalizedString(
        "Select Network",
        comment: "Dex: NetworkPicker: Screen title"
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

    static let fetchingPrice = NSLocalizedString(
        "Fetching best price...",
        comment: "Dex: Main: Fetching best price"
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

    static let selectAToken = NSLocalizedString(
        "Select a token",
        comment: "Dex: Main"
    )

    static let noAssetsOnNetwork = NSLocalizedString(
        "No assets on %@",
        comment: "Dex: Main"
    )

    static let enterAnAmount = NSLocalizedString(
        "Enter an amount",
        comment: "Dex: Main"
    )

    static let previewSwap = NSLocalizedString(
        "Preview Swap",
        comment: "Dex: Main"
    )
}

extension L10n.TransactionInProgress {

    static let title = NSLocalizedString(
        "Transaction in process",
        comment: "Dex: Main: Transaction In Progress: title"
    )

    static let body = NSLocalizedString(
        "Your balances may not be accurate. Once the transaction is confirmed, your balances will update.",
        comment: "Dex: Main: Transaction In Progress: body"
    )
}

extension L10n.Main.Allowance {
    static let approved = NSLocalizedString(
        "Approved %@",
        comment: "Dex: Main"
    )

    static let approve = NSLocalizedString(
        "Approve %@",
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

extension L10n.Main.NoBalanceSheet {

    static let title = NSLocalizedString(
        "No assets on %@",
        comment: "Dex: Main"
    )

    static let body = NSLocalizedString(
        "You don't have any assets on %@. Deposit %@ to get started.",
        comment: "Dex: Main"
    )

    static let button = NSLocalizedString(
        "Deposit",
        comment: "Dex: Main"
    )
}

extension L10n.Allowance {
    static let title = NSLocalizedString(
        "Allow %@",
        comment: "Dex: Allowance"
    )

    static let body = NSLocalizedString(
        "To complete the swap, allow permission to use your %@. You only have to do this once per token.",
        comment: "Dex: Allowance"
    )

    static let estimatedFee = NSLocalizedString(
        "Estimated Fee",
        comment: "Dex: Allowance"
    )

    static let wallet = NSLocalizedString(
        "Wallet",
        comment: "Dex: Allowance"
    )

    static let network = NSLocalizedString(
        "Network",
        comment: "Dex: Allowance"
    )

    static let decline = NSLocalizedString(
        "Decline",
        comment: "Dex: Allowance"
    )

    static let approve = NSLocalizedString(
        "Approve",
        comment: "Dex: Allowance"
    )
}

extension L10n.Confirmation {
    static let title = NSLocalizedString(
        "Confirm Swap",
        comment: "Dex: Confirmation title"
    )

    static let exchangeRate = NSLocalizedString(
        "Exchange Rate",
        comment: "Dex: Main"
    )

    static let network = NSLocalizedString(
        "Network",
        comment: "Dex: Network"
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

extension L10n.Execution {
    enum InProgress {
        static let title = NSLocalizedString(
            "Swapping %@ for %@",
            comment: "Dex: Execution InProgress title"
        )
    }

    enum Success {
        static let title = L10n.Execution.InProgress.title
        static let body = NSLocalizedString(
            "You swap is being confirmed by the network. Track the confirmation on the Explorer or feel free to start a new swap.",
            comment: "Dex: Execution Success"
        )
    }
}
