// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum Onboarding {}
}

extension LocalizationConstants.Onboarding {

    public enum ChecklistOverview {

        public static let title = NSLocalizedString(
            "Complete Your Profile",
            comment: "Onboarding checklist overview title"
        )

        public static let subtitle = NSLocalizedString(
            "Buy Crypto Today",
            comment: "Onboarding checklist overview subtitle"
        )
    }

    public enum Checklist {

        public static let screenTitle = NSLocalizedString(
            "Complete Your Profile.\nBuy Crypto Today.",
            comment: "Onboarding checklist view title"
        )

        public static let screenSubtitle = NSLocalizedString(
            "Finish setting up your Blockchain.com account and start buying crypto today.",
            comment: "Onboarding checklist view subtitle"
        )

        public static let listTitle = NSLocalizedString(
            "Your steps towards owning the future.",
            comment: "Onboarding checklist title"
        )

        public static let pendingPlaceholder = NSLocalizedString(
            "Processing...",
            comment: "Onboarding checklist item subtitle displaying that the item's status is being actioned upon"
        )

        public static let verifyIdentityTitle = NSLocalizedString(
            "Verify Your ID",
            comment: "Onboarding checklist item title - verify identity"
        )

        public static let verifyIdentitySubtitle = NSLocalizedString(
            "3 Minutes",
            comment: "Onboarding checklist item subtitle - verify identity"
        )

        public static let linkPaymentMethodsTitle = NSLocalizedString(
            "Link a Payment Method",
            comment: "Onboarding checklist item title - link payment methods"
        )

        public static let linkPaymentMethodsSubtitle = NSLocalizedString(
            "2 Minutes",
            comment: "Onboarding checklist item subtitle - link payment methods"
        )

        public static let buyCryptoTitle = NSLocalizedString(
            "Buy Crypto",
            comment: "Onboarding checklist item title - buy crypto"
        )

        public static let buyCryptoSubtitle = NSLocalizedString(
            "10 Seconds",
            comment: "Onboarding checklist item subtitle - buy crypto"
        )

        public static let requestCryptoTitle = NSLocalizedString(
            "Receive Crypto",
            comment: ""
        )

        public static let requestCryptoSubtitle: String? = nil
    }

    public enum CryptoBalanceRequired {

        public static let title = NSLocalizedString(
            "You’ll need some crypto first!",
            comment: ""
        )

        public static let subtitle = NSLocalizedString(
            "Link a bank or card and buy now or receive from a friend. Once you hold a balance, you can swap crypto at anytime.",
            comment: ""
        )
    }
}

extension LocalizationConstants.Onboarding {

    public enum UITour {

        public static let tourNextStepCTA = NSLocalizedString(
            "Next",
            comment: "Onboarding UI Tour - Next Step CTA"
        )

        public static let tourFinishTourCTA = NSLocalizedString(
            "Buy Now",
            comment: "Onboarding UI Tour - Finish Tour CTA"
        )

        public static let stepHomeTitle = NSLocalizedString(
            "See Your Balances",
            comment: "Onboarding UI Tour - 'Home' Tab Tour - Title"
        )

        public static let stepHomeMessage = NSLocalizedString(
            "Quickly check how your portfolio is performing. How much are you up today?",
            comment: "Onboarding UI Tour - 'Home' Tab Tour - Message"
        )

        public static let stepPricesTitle = NSLocalizedString(
            "Discover New Coins",
            comment: "Onboarding UI Tour - 'Prices' Tab Tour - Title"
        )

        public static let stepPricesMessage = NSLocalizedString(
            "Track the live price of over 1,200 coins and find new ones to add to your wallet.",
            comment: "Onboarding UI Tour - 'Prices' Tab Tour - Message"
        )

        public static let stepBuySellTitle = NSLocalizedString(
            "Buy & Sell",
            comment: "Onboarding UI Tour - 'Buy & Sell' Tab Tour - Title"
        )

        public static let stepBuySellMessage = NSLocalizedString(
            "Use your card or link your bank to buy crypto in seconds. Quick, easy & secure.",
            comment: "Onboarding UI Tour - 'Buy & Sell' Tab Tour - Message"
        )

        public static let stepActivityTitle = NSLocalizedString(
            "See All Transactions",
            comment: "Onboarding UI Tour - 'Activity' Tab Tour - Title"
        )

        public static let stepActivityMessage = NSLocalizedString(
            "Know exactly when you bought, sold or swapped and at what price.",
            comment: "Onboarding UI Tour - 'Activity' Tab Tour - Message"
        )

        public static let stepFabTitle = NSLocalizedString(
            "Instantly Trade",
            comment: "Onboarding UI Tour - 'Trade' (FAB Menu) Tab Tour - Title"
        )

        public static let stepFabMessage = NSLocalizedString(
            "Whether you want to swap with speed or send to a friend - we’ve got you covered!",
            comment: "Onboarding UI Tour - 'Trade' (FAB Menu) Tab Tour - Message"
        )

        public static let stepChecklistTitle = NSLocalizedString(
            "Get Set Up to Buy",
            comment: "Onboarding UI Tour - 'New User Checklist' Tour - Title"
        )

        public static let stepChecklistMessage = NSLocalizedString(
            "Add a card or link a bank to start buying crypto in seconds.",
            comment: "Onboarding UI Tour - 'New User Checklist' Tour - Message"
        )
    }
}

extension LocalizationConstants.Onboarding {
    public static let createNewWallet = NSLocalizedString("Create New Wallet", comment: "")
    public static let termsOfServiceAndPrivacyPolicyNoticePrefix = NSLocalizedString("By creating a wallet you agree to Blockchain’s", comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they create a wallet")
    public static let automaticPairing = NSLocalizedString("Automatic Pairing", comment: "")
    public static let recoverFunds = NSLocalizedString("Recover Funds", comment: "")
    public static let recoverFundsOnlyIfForgotCredentials = NSLocalizedString("You should always pair or login if you have access to your Wallet ID and password. Recovering your funds will create a new Wallet ID. Would you like to continue?", comment: "")
    public static let askToUserOldWalletTitle = NSLocalizedString("We’ve detected a previous installation of Blockchain Wallet on your phone.", comment: "")
    public static let askToUserOldWalletMessage = NSLocalizedString("Please choose from the options below.", comment: "")
    public static let loginExistingWallet = NSLocalizedString("Login existing Wallet", comment: "")
}
