// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

extension LocalizationConstants {
    public enum Dashboard {
        public enum AllActivity {}
        public enum AssetDetails {}
        public enum BalanceCell {}
        public enum Portfolio {}
        public enum Prices {}
        public enum Announcements {}
    }
}

extension LocalizationConstants.Dashboard.BalanceCell {
    public enum Title {
        public static let trading = NSLocalizedString("Trading", comment: "Trading")
        public static let savings = NSLocalizedString("Rewards", comment: "Rewards")
    }

    public enum Description {
        public static let savingsPrefix = NSLocalizedString("Earn", comment: "Earn 3% annually")
        public static let savingsSuffix = NSLocalizedString("% annually", comment: "Earn 3% annually")
    }

    public static let pending = NSLocalizedString("Pending", comment: "Pending")
}

extension LocalizationConstants.Dashboard.Portfolio {

    public static let onHoldTitle = NSLocalizedString(
        "On Hold",
        comment: "Withdrawal Locks: On Hold Title"
    )

    public static let totalBalance = NSLocalizedString(
        "Total Balance",
        comment: "Dashboard: total balance component - title"
    )
    public static let balance = NSLocalizedString(
        "Balance",
        comment: "Dashboard: balance component - title"
    )
    public enum EmptyState {
        public static let title = NSLocalizedString(
            "Welcome to Blockchain.com!",
            comment: "Dashboard: Empty State - title"
        )
        public static let subtitle = NSLocalizedString(
            "All your crypto balances will show up here once you buy or receive.",
            comment: "Dashboard: Empty State - subtitle"
        )
        public static let cta = NSLocalizedString(
            "Buy Crypto",
            comment: "Dashboard: Empty State - cta"
        )
    }
}

extension LocalizationConstants.Dashboard.AllActivity {
    public static let pendingSection = NSLocalizedString(
        "Pending",
        comment: "AllActivity: Pending - search placeholder."
    )
}

extension LocalizationConstants.Dashboard.Prices {
    public static let searchPlaceholder = NSLocalizedString(
        "Search Coins",
        comment: "Dashboard: Prices - search placeholder."
    )
    public static let noResults = NSLocalizedString(
        "No Results",
        comment: "Dashboard: Prices - no results when filtering."
    )
}

extension LocalizationConstants.Dashboard.Announcements {
    public static let recoveryPhraseBackupTitle = NSLocalizedString(
        "Secure your wallets",
        comment: "Dashboard DeFi Announcement: Secure your wallets"
    )
    public static let recoveryPhraseBackupMessage = NSLocalizedString(
        "Backup your Seed Phrase to keep your DeFi Wallet safe",
        comment: "Dashboard DeFi Announcement: Backup your Seed Phrase to keep your DeFi Wallet safe"
    )

    public enum DeFiOnly {
        public static let title = NSLocalizedString(
            "Secure your wallet",
            comment: "Dashboard DeFi Only Announcement: Secure your wallet"
        )
        public static let message = NSLocalizedString(
            "Backup your Recovery Phrase",
            comment: "Dashboard DeFi Only Announcement: Backup your Recovery Phrase"
        )
    }
}
