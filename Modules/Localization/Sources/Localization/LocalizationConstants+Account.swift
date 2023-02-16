// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum Account {

        public static let myWallet = NonLocalizedConstants.defiWalletTitle

        public static let myInterestWallet = NSLocalizedString(
            "Passive Rewards",
            comment: "Used for naming rewards accounts."
        )

        public static let myStakingWallet = NSLocalizedString(
            "Staking Rewards",
            comment: "Used for naming staking accounts."
        )

        public static let myActiveRewardsWallet = NSLocalizedString(
            "Active Rewards",
            comment: "Used for naming active rewards accounts."
        )

        public static let myTradingAccount = NSLocalizedString(
            "Blockchain.com",
            comment: "Used for naming Blockchain.com Accounts."
        )

        public static let myExchangeAccount = NSLocalizedString(
            "Exchange",
            comment: "Used for naming exchange accounts."
        )
        public static let lowFees = NSLocalizedString(
            "Low Fees",
            comment: "Low Fees"
        )

        public static let faster = NSLocalizedString(
            "Faster",
            comment: "Faster"
        )

        public static let legacyPrivateKeyWallet = NSLocalizedString(
            "Private Key Wallet",
            comment: "Private Key Wallet"
        )

        public static let legacyMyBitcoinWallet = NSLocalizedString(
            "My Bitcoin Wallet",
            comment: "My Bitcoin Wallet"
        )

        public static let noFees = NSLocalizedString(
            "No Fees",
            comment: "No Fees"
        )

        public static let wireFee = NSLocalizedString(
            "Wire Fee",
            comment: "Wire Fee"
        )

        public static let minWithdraw = NSLocalizedString(
            "Min Withdraw",
            comment: "Min Withdraw"
        )
    }

    public enum AccountGroup {
        public static let allWallets = NSLocalizedString(
            "All Wallets",
            comment: "All Wallets"
        )

        public static let allAccounts = NSLocalizedString(
            "All Accounts",
            comment: "All Wallets"
        )

        public static let myWallets = NSLocalizedString(
            "%@ Wallets",
            comment: "Must contain %@. Used for naming account groups e.g. Ethereum Wallets"
        )
    }
}
