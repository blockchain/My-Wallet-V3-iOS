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
            "Private Key Wallet",
            comment: "Used for naming non custodial wallets."
        )

        public static let myInterestWallet = NSLocalizedString(
            "Interest Account",
            comment: "Used for naming interest accounts."
        )

        public static let myTradingAccount = NSLocalizedString(
            "Trading Account",
            comment: "Used for naming trading accounts."
        )
        
        public static let myExchangeAccount = NSLocalizedString(
            "Exchange Account",
            comment: "Used for naming exchange accounts."
        )

        public static func fiatAccount(_ fiatName: String) -> String {
            let format = NSLocalizedString(
                "%@ Account",
                comment: "Must contain %@. Used for naming fiat accounts. eg USD Account."
            )
            return String(format: format, fiatName)
        }

        public static let lowFees = NSLocalizedString(
            "Low Fees",
            comment: "Low Fees"
        )

        public static let faster = NSLocalizedString(
            "Faster",
            comment: "Faster"
        )

        public static let legacyMyBitcoinWallet = NSLocalizedString(
            "My Bitcoin Wallet",
            comment: "My Bitcoin Wallet"
        )
    }

    public enum AccountGroup {
        public static let allWallets = NSLocalizedString(
            "All Wallets",
            comment: "All Wallets"
        )

        public static let myWallets = NSLocalizedString(
            "%@ Wallets",
            comment: "Must contain %@. Used for naming account groups e.g. Ethereum Wallets"
        )

        public static let myCustodialWallets = NSLocalizedString(
            "%@ Custodial Accounts",
            comment: "Must contain %@. Used for naming trading account groups e.g. Ethereum Custodial Wallets"
        )
    }
}
