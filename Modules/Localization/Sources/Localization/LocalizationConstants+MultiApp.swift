// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum SuperApp {
        public enum AppChrome {}
        public enum Dashboard {
            public enum QuickActions {}
            public enum GetStarted {
                public enum Trading {}
                public enum Pkw {}
            }
        }

        public enum AllAssets {
            public enum Filter {}
        }

        public enum AllActivity {}
        public enum ActivityDetails {}
        public enum Help {}

        public enum Prices {
            public enum Search {}
            public enum Filter {}
        }
    }
}

extension LocalizationConstants.SuperApp {
    public static let trading = NSLocalizedString(
        "Account",
        comment: "Account title"
    )
    public static let pkw = NSLocalizedString(
        "DeFi Wallet",
        comment: "DeFi Wallet title"
    )
}

extension LocalizationConstants.SuperApp.AppChrome {
    public static let totalBalance = NSLocalizedString(
        "Total Balance",
        comment: "Total Balance title"
    )
}

extension LocalizationConstants.SuperApp.AllAssets {
    public static let title = NSLocalizedString(
        "All assets",
        comment: "All assets"
    )

    public static let searchPlaceholder = NSLocalizedString(
        "Search coin",
        comment: "Search coin"
    )

    public static let cancelButton = NSLocalizedString(
        "Cancel",
        comment: "Cancel"
    )

    public static var noResults = NSLocalizedString(
        "😞 No results",
        comment: "😞 No results"
    )
}

extension LocalizationConstants.SuperApp.Prices.Search {
    public static let searchPlaceholder = NSLocalizedString(
        "Search coin",
        comment: "Search coin"
    )

    public static let cancelButton = NSLocalizedString(
        "Cancel",
        comment: "Cancel"
    )

    public static var noResults = NSLocalizedString(
        "😞 No results",
        comment: "😞 No results"
    )
}

extension LocalizationConstants.SuperApp.Prices.Filter {
    public static let all = NSLocalizedString(
        "All",
        comment: "Filter Button: Display all assets."
    )

    public static let favorites = NSLocalizedString(
        "Favorites",
        comment: "Filter Button: Display only assets tagged as Favorite."
    )

    public static var tradable = NSLocalizedString(
        "Tradable",
        comment: "Filter Button: Display only assets that can be traded (Buy/Sell/Swap)."
    )
}

extension LocalizationConstants.SuperApp.AllActivity {
    public static let title = NSLocalizedString(
        "Activity",
        comment: "Activity"
    )

    public static let searchPlaceholder = NSLocalizedString(
        "Search coin, type or date",
        comment: "Search coin, type or date"
    )

    public static var noResults = NSLocalizedString(
        "😞 No results",
        comment: "😞 No results"
    )

    public static let cancelButton = NSLocalizedString(
        "Cancel",
        comment: "Cancel"
    )

    public static let pendingActivityModalTitle = NSLocalizedString(
        "Pending Activity",
        comment: "Pending Activity"
    )

    public static let pendingActivityModalText = NSLocalizedString(
        """
                    Your transactions can vary in time to complete depending on your bank or network traffic for on-chain transactions.
                    \n\n
                    We update your total balance as if a pending transaction has been completed. If for any reason the transaction fails, your funds will be returned.
                    """,
        comment: "Pending Activity Modal Info Text"
    )

    public static let pendingActivityCTAButton = NSLocalizedString(
        "Got it",
        comment: "Got it"
    )
}

extension LocalizationConstants.SuperApp.Help {
    public static let chat = NSLocalizedString(
        "Chat with support",
        comment: "Chat with support"
    )

    public static let supportCenter = NSLocalizedString(
        "View support center",
        comment: "View support center"
    )
}

extension LocalizationConstants.SuperApp.AllAssets.Filter {
    public static let title = NSLocalizedString(
        "Filter Assets",
        comment: "Filter Assets"
    )

    public static let showSmallBalancesLabel = NSLocalizedString(
        "Show small balances",
        comment: "Show small balances"
    )

    public static let showButton = NSLocalizedString(
        "Show",
        comment: "Show"
    )

    public static var resetButton = NSLocalizedString(
        "Reset",
        comment: "Reset"
    )
}

extension LocalizationConstants.SuperApp.Dashboard {
    public static let assetsLabel = NSLocalizedString(
        "Assets",
        comment: "Assets"
    )

    public static let activitySectionHeader = NSLocalizedString(
        "Activity",
        comment: "Activity"
    )

    public static let seeAllLabel = NSLocalizedString(
        "See all",
        comment: "See all"
    )

    public static let helpSectionHeader = NSLocalizedString(
        "Need help?",
        comment: "Need help?"
    )
}

extension LocalizationConstants.SuperApp.Dashboard.QuickActions {
    public static let more = NSLocalizedString(
        "More",
        comment: "More"
    )
}

extension LocalizationConstants.SuperApp.Dashboard.GetStarted.Trading {
    public static let toGetStartedTitle = NSLocalizedString(
        "To get started, buy your first BTC.",
        comment: "To get started, buy your first BTC."
    )

    public static let toGetStartedBuyOtherAmountButtonTitle = NSLocalizedString(
        "Other",
        comment: "Other Amount"
    )
    public static let toGetStartedBuyOtherCryptoButtonTitle = NSLocalizedString(
        "Buy a different crypto",
        comment: "Buy a different crypto"
    )
}

extension LocalizationConstants.SuperApp.Dashboard.GetStarted.Pkw {
    public static let toGetStartedTitle = NSLocalizedString(
        "To get started, transfer to\nyour wallets",
        comment: "Get started Title: To get started, transfer to\nyour wallets"
    )

    public static let toGetStartedSubtitle = NSLocalizedString(
        "Transfer from your Blockchain.com\nAccount, send from any exchange,\nor ask a friend!",
        comment: "Get started Subtitle: Transfer from your Blockchain.com\nAccount, send from any exchange,\nor ask a friend!"
    )

    public static let toGetStartedReceiveCryptoButtonTitle = NSLocalizedString(
        "Receive",
        comment: "Receive Button"
    )
}

extension LocalizationConstants.SuperApp.ActivityDetails {
    public static let fromLabel = NSLocalizedString(
        "From",
        comment: "From"
    )

    public static let toLabel = NSLocalizedString(
        "To",
        comment: "To"
    )

    public static let feeLabel = NSLocalizedString(
        "Fees",
        comment: "Fees"
    )

    public static let amountLabel = NSLocalizedString(
        "Amount",
        comment: "Amount"
    )

    public static let priceLabel = NSLocalizedString(
        "Price",
        comment: "Price"
    )

    public static let totalLabel = NSLocalizedString(
        "Total",
        comment: "Total"
    )

    public static let statusLabel = NSLocalizedString(
        "Status",
        comment: "Status"
    )

    public static let networkLabel = NSLocalizedString(
        "Network",
        comment: "Network"
    )

    public static let dateLabel = NSLocalizedString(
        "Date",
        comment: "Date"
    )

    public static let transactionIdLabel = NSLocalizedString(
        "Transaction ID",
        comment: "Transaction ID"
    )

    public static let cashedOut = NSLocalizedString(
        "Cashed out",
        comment: "Cashed out"
    )

    public static let added = NSLocalizedString(
        "Added",
        comment: "Added"
    )

    public static let free = NSLocalizedString(
        "Free",
        comment: "Free"
    )

    public static let paymentTypeLabel = NSLocalizedString(
        "Type",
        comment: "Type"
    )

    public static let purchaseLabel = NSLocalizedString(
        "Purchase",
        comment: "Purchase"
    )

    public static let forLabel = NSLocalizedString(
        "For",
        comment: "For"
    )

    public static let exchangeLabel = NSLocalizedString(
        "Exchange Rate",
        comment: "Exchange Rate"
    )

    public static let paymentMethodApplePay = NSLocalizedString(
        "Apple Pay",
        comment: "Apple Pay"
    )

    public static let paymentMethodFunds = NSLocalizedString(
        "Funds",
        comment: "Funds"
    )

    public static let paymentMethodCard = NSLocalizedString(
        "Card",
        comment: "Card"
    )

    public static let paymentMethodBankAccount = NSLocalizedString(
        "Bank Account",
        comment: "Bank Account"
    )

    public static let paymentMethodBankTransfer = NSLocalizedString(
        "Bank Transfer",
        comment: "Bank Transfer"
    )

    public static let pendingStatus = NSLocalizedString(
        "Pending",
        comment: "Pending"
    )

    public static let failedStatus = NSLocalizedString(
        "Failed",
        comment: "Failed"
    )

    public static let completeStatus = NSLocalizedString(
        "Complete",
        comment: "Complete"
    )

    public static let copyTransactionButtonLabel = NSLocalizedString(
        "Copy Transaction ID",
        comment: "Copy Transaction ID"
    )
}
