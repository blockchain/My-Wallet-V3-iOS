// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

// MARK: Groups

extension LocalizationConstants {
    public enum Activity {
        public enum Message {}
        public enum Details {}
        public enum MainScreen {}
        public enum Pax {}
    }
}

// MARK: MainScreen

extension LocalizationConstants.Activity.MainScreen {
    public static let title = NSLocalizedString(
        "Activity",
        comment: "Activity Screen: title"
    )
    public enum MessageView {
        public static let sharedWithBlockchain = NSLocalizedString("Shared With Blockchain", comment: "Shared With Blockchain")
    }

    public enum Empty {
        public static let title = NSLocalizedString("You Have No Activity", comment: "You Have No Activity")
        public static let subtitle = NSLocalizedString("All your transactions will show up here.", comment: "All your transactions will show up here.")
    }

    public enum Item {
        public static let allWallets = NSLocalizedString("All Wallets", comment: "All Wallets")
        public static let pending = NSLocalizedString("Pending", comment: "Pending")
        public static let rewardsEarned = NSLocalizedString("Rewards Earned", comment: "Rewards Earned")
        public static let wallet = NSLocalizedString("Wallet", comment: "Wallet")
        public static let trade = NSLocalizedString("Trade", comment: "Trade")
        public static let tradeWallet = trade + " " + wallet
        public static let confirmations = NSLocalizedString("Confirmations", comment: "Confirmations")
        public static let of = NSLocalizedString("of", comment: "of")
        public static let failed = NSLocalizedString("Failed", comment: "Failed")
        public static let send = NSLocalizedString("Sent", comment: "Sent")
        public static let sending = NSLocalizedString("Sending", comment: "Sending")
        public static let deposit = NSLocalizedString("Deposited", comment: "Deposited")
        public static let withdraw = NSLocalizedString("Withdrawn", comment: "Withdrawn")
        public static let depositing = NSLocalizedString("Depositing", comment: "Depositing")
        public static let withdrawing = NSLocalizedString("Withdrawing", comment: "Withdrawing")
        public static let added = NSLocalizedString("Added", comment: "Added")
        public static let debited = NSLocalizedString("Debited", comment: "Debited")
        public static let staked = NSLocalizedString("Staked", comment: "Staked")
        public static let subscribed = NSLocalizedString("Subscribed", comment: "Subscribed")
        public static let buy = NSLocalizedString("Bought", comment: "Bought")
        public static let buying = NSLocalizedString("Buying", comment: "Buying")
        public static let pendingSwap = NSLocalizedString("Swapping", comment: "Pending Swap Title")
        public static let swap = NSLocalizedString("Swapped", comment: "Swapped")
        public static let receive = NSLocalizedString("Received", comment: "Received")
        public static let receiving = NSLocalizedString("Receiving", comment: "Receiving")
        public static let pendingSell = NSLocalizedString("Selling", comment: "Pending Sell Title")
        public static let sell = NSLocalizedString("Sold", comment: "Sold")
    }
}

// MARK: - MessageView

extension LocalizationConstants.Activity.Message {
    public static let name = NSLocalizedString("My Transaction", comment: "My Transaction")
}

// MARK: Details

extension LocalizationConstants.Activity.Details {

    public static let companyName = NSLocalizedString("Blockchain.com", comment: "Blockchain.com")
    public static let rewardsAccount = NSLocalizedString("Rewards Account", comment: "Rewards Account")
    public static let activeRewardsAccount = NSLocalizedString("Active Rewards Account", comment: "Active Rewards Account")
    public static let stakingAccount = NSLocalizedString("Staking Account", comment: "Staking Account")
    public static let noDescription = NSLocalizedString("No description", comment: "No description")
    public static let confirmations = NSLocalizedString("Confirmations", comment: "Confirmations")
    public static let of = NSLocalizedString("of", comment: "of")

    public static let completed = NSLocalizedString("Completed", comment: "Completed")
    public static let pending = NSLocalizedString("Pending", comment: "Pending")
    public static let manualReview = NSLocalizedString("Manual Review", comment: "Manual Review")
    public static let failed = NSLocalizedString("Failed", comment: "Failed")
    public static let refunded = NSLocalizedString("Refunded", comment: "Refunded")
    public static let replaced = NSLocalizedString("Replaced", comment: "Replaced")
    public static let myWallet = NSLocalizedString("My %@ Wallet", comment: "My [Currency Code] Wallet")
    public static let wallet = NSLocalizedString("Wallet", comment: "Wallet")

    public enum Title {
        public static let buy = NSLocalizedString("Buy", comment: "Buy")
        public static let buying = NSLocalizedString("Buying", comment: "Buying")
        public static let bought = NSLocalizedString("Bought", comment: "Bought")

        public static let sell = NSLocalizedString("Sell", comment: "Sold")
        public static let selling = NSLocalizedString("Selling", comment: "Selling")
        public static let sold = NSLocalizedString("Sold", comment: "Sold")

        public static let swap = NSLocalizedString("Swap", comment: "Swap")
        public static let swapping = NSLocalizedString("Swapping", comment: "Swapping")
        public static let swaped = NSLocalizedString("Swapped", comment: "Swapped")

        public static let deposit = NSLocalizedString("Deposit", comment: "Deposit")
        public static let depositing = NSLocalizedString("Depositing", comment: "Depositing")
        public static let deposited = NSLocalizedString("Deposited", comment: "Deposited")

        public static let withdrawal = NSLocalizedString("Withdrawal", comment: "Withdrawal")
        public static let withdrawing = NSLocalizedString("Withdrawing", comment: "Withdrawing")
        public static let withdrawn = NSLocalizedString("Withdrawn", comment: "Withdrawn")

        public static let gas = NSLocalizedString("Gas", comment: "'Gas' title")
        public static let receive = NSLocalizedString("Received", comment: "Received")
        public static let send = NSLocalizedString("Sent", comment: "Sent")

        public static let rewardsEarned = NSLocalizedString("Rewards Earned", comment: "Rewards Earned")
        public static let added = NSLocalizedString("Added", comment: "Added")
        public static let subscribed = NSLocalizedString("Subscribed", comment: "Subscribed")
        public static let staked = NSLocalizedString("Staked", comment: "Staked")
        public static let debited = NSLocalizedString("Debited", comment: "Debited")
    }

    public enum Button {
        public static let viewOnExplorer = NSLocalizedString(
            "View on Blockchain.com Explorer",
            comment: "Button title, button takes user to explorer webpage"
        )
        public static let viewOnStellarChainIO = NSLocalizedString(
            "View on StellarChain.io",
            comment: "Button title, button takes user to StellarChain webpage"
        )
    }
}
