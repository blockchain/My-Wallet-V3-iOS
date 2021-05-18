//
//  Localization+Transaction.swift
//  Localization
//
//  Created by Alex McGregor on 11/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension LocalizationConstants {
    public enum Transaction {
        public enum TargetSource {
            public enum Card { }
        }
        public enum Confirmation {
            public enum Error { }
        }
        public enum Send {
            public enum AmountPresenter {
                public enum LimitView { }
            }
        }
        public enum Swap {
            public enum KYC { }
            public enum Completion {
                public enum Pending { }
                public enum Success { }
                public enum Failure { }
            }
            public enum AmountPresenter {
                public enum LimitView { }
            }
        }
    }
}

extension LocalizationConstants.Transaction.Swap.AmountPresenter.LimitView {
    public static let useMin = NSLocalizedString(
        "The minimum swap is %@",
        comment: "The minimum swap is"
    )
    public static let useMax = NSLocalizedString(
        "You can swap up to %@",
        comment: "You can swap up to"
    )
}

public extension LocalizationConstants.Transaction.Swap.KYC {

    static let overSilverLimitWarning = NSLocalizedString(
        "Tap here to upgrade your profile and swap this amount.",
        comment: "Tap here to upgrade your profile and swap this amount."
    )
    static let title = NSLocalizedString(
        "Verify Your Email & Swap Today.",
        comment: ""
    )
    static let subtitle = NSLocalizedString(
        "Get access to swap in seconds by completing your profile and getting Silver access.",
        comment: ""
    )
    static let card1Title = NSLocalizedString(
        "Verify Your Email",
        comment: ""
    )
    static let card1Subtitle = NSLocalizedString(
        "Confirm your email address to protect your Blockchain.com Wallet.",
        comment: ""
    )
    static let card2Title = NSLocalizedString(
        "Add Your Name and Address",
        comment: ""
    )
    static let card2Subtitle = NSLocalizedString(
        "We need to know your name and address to comply with local laws.",
        comment: ""
    )
    static let card3Title = NSLocalizedString(
        "Start Swapping",
        comment: ""
    )
    static let card3Subtitle = NSLocalizedString(
        "Instantly exchange your crypto.",
        comment: ""
    )
    static let verifyNow = NSLocalizedString(
        "Verify Now",
        comment: ""
    )
}

public extension LocalizationConstants.Transaction {
    static let next = NSLocalizedString(
        "Next",
        comment: "Next"
    )
    static let receive = NSLocalizedString(
        "Receive",
        comment: "Receive"
    )
    static let available = NSLocalizedString(
        "Available",
        comment: "Available"
    )
    static let newSwap = NSLocalizedString(
        "New Swap",
        comment: "New Swap"
    )
    static let from = NSLocalizedString(
        "From",
        comment: "From"
    )
    static let to = NSLocalizedString(
        "To",
        comment: "To"
    )
    static let selectAWallet = NSLocalizedString(
        "Select a Wallet",
        comment: "Select a Wallet"
    )
    static let orSelectAWallet = NSLocalizedString(
        "or Select a Wallet",
        comment: "Select a Wallet"
    )
}

public extension LocalizationConstants.Transaction.Send {
    static let send = NSLocalizedString(
        "Send",
        comment: "Send"
    )
    static let sendMax = NSLocalizedString(
        "Send Max",
        comment: "Send Max"
    )
    static let from = NSLocalizedString(
        "From",
        comment: "From"
    )
    static let to = NSLocalizedString(
        "To",
        comment: "To"
    )
}

public extension LocalizationConstants.Transaction.TargetSource.Card {
    static let internalSendOnly = NSLocalizedString("Internal Send Only", comment: "Internal Send Only")
    // swiftlint:disable line_length
    static let description = NSLocalizedString(
        "At this time, you can only transfer %@ from your Trade Wallet to your %@ Wallet. Once %@ is in your Wallet you can transfer to external addresses.",
        comment: "At this time, you can only transfer %@ from your Trade Wallet to your %@ Wallet. Once %@ is in your Wallet you can transfer to external addresses."
    )
}

public extension LocalizationConstants.Transaction.Send.AmountPresenter.LimitView {
    static let useMin = NSLocalizedString(
        "The minimum send is %@",
        comment: "The minimum send is"
    )
    static let useMax = NSLocalizedString(
        "You can send up to %@",
        comment: "You can send up to"
    )
}

public extension LocalizationConstants.Transaction.Swap {
    static let title = swap
    static let swap = NSLocalizedString(
        "Swap",
        comment: "Swap"
    )
    static let swapMax = NSLocalizedString(
        "Swap Max",
        comment: "Swap Max"
    )
    static let confirmationDisclaimer = NSLocalizedString(
        "The amounts you send and receive may change slightly due to market activity. Once an order starts, we are unable to stop it.",
        comment: "Confirmation screen disclaimer."
    )
    static let sourceAccountPicketSubtitle = NSLocalizedString(
        "Which wallet do you want to Swap from?",
        comment: "Swap Source Account Picket Header Subtitle"
    )
    static let destinationAccountPicketSubtitle = NSLocalizedString(
        "Which crypto do you want to Swap for?",
        comment: "Swap Destination Account Picket Header Subtitle"
    )
    static let swapAForB = NSLocalizedString(
        "Swap %@ for %@",
        comment: "Swap %@ for %@"
    )
    static let send = NSLocalizedString(
        "Send %@",
        comment: "Send %@"
    )
    static let sell = NSLocalizedString(
        "Sell %@",
        comment: "Sell %@"
    )
    static let deposit = NSLocalizedString(
        "Confirm Transfer",
        comment: "Confirm Transfer"
    )
    static let newSwapDisclaimer = NSLocalizedString(
        "Confirm the wallet you want to Swap from and choose the wallet you want to Receive into.",
        comment: "Confirm the wallet you want to Swap from and choose the wallet you want to Receive into."
    )
}

public extension LocalizationConstants.Transaction.Swap.Completion.Pending {
    static let title = NSLocalizedString(
        "Swapping %@ for %@",
        comment: "Swapping %@ for %@"
    )
    static let description = NSLocalizedString(
        "We're completing your swap now.",
        comment: "We're completing your swap now."
    )
}

public extension LocalizationConstants.Transaction.Swap.Completion.Success {
    static let title = NSLocalizedString(
        "Swap Complete",
        comment: "Swap Complete"
    )
    static let description = NSLocalizedString(
        "Your %@ is now available in your Wallet.",
        comment: "Your %@ is now available in your Wallet."
    )
    static let action = NSLocalizedString(
        "OK",
        comment: "OK"
    )
}

public extension LocalizationConstants.Transaction.Swap.Completion.Failure {
    static let title = NSLocalizedString(
        "Oops! Something Went Wrong.",
        comment: "Oops! Something Went Wrong."
    )
    static let description = NSLocalizedString(
        "Don’t worry. Your crypto is safe. Please try again or contact our Suppport Team for help.",
        comment: "Don’t worry. Your crypto is safe. Please try again or contact our Suppport Team for help."
    )
    static let action = NSLocalizedString(
        "OK",
        comment: "OK"
    )
}

public extension LocalizationConstants.Transaction.Confirmation.Error {
    static let title = NSLocalizedString("Error", comment: "Error")
    static let insufficientFunds = NSLocalizedString(
        "You have insufficient funds in this account to process this transaction",
        comment: ""
    )
    static let insufficientGas = NSLocalizedString(
        "You do not have enough ETH to process this transaction.",
        comment: ""
    )
    static let optionInvalid = NSLocalizedString(
        "Please ensure you've agreed to our Terms.",
        comment: ""
    )
    static let invoiceExpired = NSLocalizedString(
        "BitPay Invoice Expired",
        comment: ""
    )
    static let underMinLimit = NSLocalizedString(
        "%@ Min",
        comment: ""
    )
    static let underMinBitcoinFee = NSLocalizedString(
        "Minimum 1 sat/byte required",
        comment: ""
    )
    static let invalidAmount = NSLocalizedString(
        "Invalid fee",
        comment: ""
    )
    static let transactionInFlight = NSLocalizedString(
        "A transaction is already in progress",
        comment: ""
    )
    static let generic = NSLocalizedString(
        "An unexpected error has occurred. Please try again.",
        comment: ""
    )
}

public extension LocalizationConstants.Transaction.Confirmation {
    static let price = NSLocalizedString(
        "%@ Price",
        comment: "%@ Price"
    )
    static let total = NSLocalizedString(
        "Total",
        comment: "Total"
    )
    static let to = NSLocalizedString(
        "To",
        comment: "To"
    )
    static let from = NSLocalizedString(
        "From",
        comment: "From"
    )
    static let networkFee = NSLocalizedString(
        "%@ Network Fee",
        comment: "%@ Network Fee"
    )
    static let exchangeRate = NSLocalizedString(
        "Exchange Rate",
        comment: "Exchange Rate"
    )
    static let description = NSLocalizedString(
        "Description",
        comment: "Description"
    )
    static let memo = NSLocalizedString(
        "Memo",
        comment: "Memo"
    )
    static let confirm = NSLocalizedString(
        "Confirm",
        comment: "Confirm"
    )
    static let cancel = NSLocalizedString(
        "Cancel",
        comment: "Cancel"
    )
}
