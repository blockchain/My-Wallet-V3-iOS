//
//  LocalizationConstants+Account.swift
//  Localization
//
//  Created by Paulo on 11/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum Account {
        public static let myWallet = NSLocalizedString(
            "%@ Wallet",
            comment: "Must contain %@. Used for naming wallets e.g. Ethereum Wallet"
        )

        public static let myInterestWallet = NSLocalizedString(
            "%@ Interest Wallet",
            comment: "Must contain %@. Used for naming interest account e.g. Ethereum Interest Wallet"
        )

        public static let myTradeAccount = NSLocalizedString(
            "%@ Trade Wallet",
            comment: "Must contain %@. Used for naming trading accounts e.g. Ethereum Trade Wallet"
        )
        
        public static let myExchangeAccount = NSLocalizedString(
            "%@ Exchange",
            comment: "Must contain %@. Used for naming trading accounts e.g. Ethereum Trade Wallet"
        )

        public static let lowFees = NSLocalizedString(
            "Low Fees",
            comment: "Low Fees"
        )

        public static let faster = NSLocalizedString(
            "Faster",
            comment: "Faster"
        )
    }

    public enum AccountGroup {
        public static let allWallets = NSLocalizedString(
            "All Wallets",
            comment: "All Wallets"
        )

        public static let myWallets = NSLocalizedString(
            "%@ Wallets",
            comment: "Must contain %@. Used for naming accounts e.g. Ethereum Wallets"
        )

        public static let myCustodialWallets = NSLocalizedString(
            "%@ Custodial Accounts",
            comment: "Must contain %@. Used for naming trading accounts e.g. Ethereum Custodial Wallets"
        )
    }
}
