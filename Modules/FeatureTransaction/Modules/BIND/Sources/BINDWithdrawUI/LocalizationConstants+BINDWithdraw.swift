// swiftlint:disable all

import Foundation
import enum Localization.LocalizationConstants

typealias L10n = LocalizationConstants.BIND

extension LocalizationConstants {

    enum BIND {

        static let search = (
            title: NSLocalizedString("Alias/CBU/CVU", comment: "BIND Withdraw: Search title"),
            placeholder: NSLocalizedString("Search", comment: "BIND Withdraw: Search placeholder")
        )

        static let empty = (
            info: NSLocalizedString(
                """
                Please, enter your bank Alias/CBU/CVU to link a new bank account in your name.

                If you enter an alias:
                - It has to be between 6 and 20 characters (letters, numbers, dash and dot)
                - Don’t include the letter “ñ”, accents, gaps and other special characters.
                """,
                comment: "BIND Withdraw: Empty state information shown when the customer has not entered an alias"
            ), ()
        )

        static let disclaimer = (
            title: NSLocalizedString("Bank Transfers Only", comment: "BIND Withdraw: Disclaimer title"),
            description: NSLocalizedString("Only send funds to a bank account in your name. If not, your withdrawal could be delayed or rejected.", comment: "BIND Withdraw: Disclaimer description")
        )

        static let action = (
            next: NSLocalizedString("Next", comment: "BIND Withdraw: 'Next' Call to Action"), ()
        )

        static let information = (
            bankName: NSLocalizedString("Bank Name", comment: "BIND Withdraw: Bank Name"),
            alias: NSLocalizedString("Alias", comment: "BIND Withdraw: Alias"),
            accountHolder: NSLocalizedString("Account Holder", comment: "BIND Withdraw: Account Holder"),
            accountType: NSLocalizedString("Account Type", comment: "BIND Withdraw: Account Type"),
            CBU: NSLocalizedString("CBU", comment: "BIND Withdraw: CBU"),
            CUIL: NSLocalizedString("CUIL", comment: "BIND Withdraw: CUIL")
        )
    }
}
