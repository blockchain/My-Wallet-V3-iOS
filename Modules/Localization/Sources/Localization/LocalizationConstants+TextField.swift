// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum TextField {
        public enum CardType {
            public static let visa = NSLocalizedString(
                "Visa",
                comment: "Card type: VISA"
            )
            public static let mastercard = NSLocalizedString(
                "Mastercard",
                comment: "Card type: Mastercard"
            )
            public static let amex = NSLocalizedString(
                "American Express",
                comment: "Card type: American Express"
            )
            public static let diners = NSLocalizedString(
                "Diners Club",
                comment: "Card type: Diners"
            )
            public static let discover = NSLocalizedString(
                "Discover",
                comment: "Card type: Discover"
            )
            public static let jcb = NSLocalizedString(
                "JCB",
                comment: "Card type: JCB"
            )
            public static let unknown = NSLocalizedString(
                "Card",
                comment: "Card type: Unknown"
            )
        }

        public enum Placeholder {
            public static let noDescription = NSLocalizedString(
                "No description",
                comment: "Description placeholder"
            )
            public static let noMemo = NSLocalizedString(
                "No memo",
                comment: "Memo placeholder"
            )
            public static let cvv = NSLocalizedString(
                "123",
                comment: "CVV placeholder"
            )
            public static let expirationDate = NSLocalizedString(
                "MM/YY",
                comment: "Expiration date placeholder"
            )
            public static let oneTimeCode = NSLocalizedString(
                "XXXX",
                comment: "Placeholder for a one time code."
            )
            public static let addressOrDomain = NSLocalizedString(
                "Enter address or domain",
                comment: "Placeholder text for crypto address"
            )
        }

        public enum Title {
            public enum Card {
                public static let name = NSLocalizedString(
                    "Name on Card",
                    comment: "Title for card owner name text field"
                )
                public static let number = NSLocalizedString(
                    "Card Number",
                    comment: "Title for card number text field"
                )
                public static let expirationDate = NSLocalizedString(
                    "Expiry Date",
                    comment: "Title for card expiry date text field"
                )
                public static let cvv = NSLocalizedString(
                    "CVV",
                    comment: "Title for card cvv text field"
                )
                public static let cvc = NSLocalizedString(
                    "CVC",
                    comment: "Title for card cvc text field"
                )
            }

            public static let description = NSLocalizedString(
                "Description",
                comment: "Title for Description text field"
            )
            public static let memo = NSLocalizedString(
                "Memo",
                comment: "Title for Memo text field"
            )
            public static let email = NSLocalizedString(
                "Your Email",
                comment: "Title for email text field"
            )
            public static let currentPassword = NSLocalizedString(
                "Current Password",
                comment: "Title for current password text field"
            )
            public static let newPassword = NSLocalizedString(
                "New Password",
                comment: "Title for new password text field"
            )
            public static let confirmNewPassword = NSLocalizedString(
                "Confirm New Password",
                comment: "Title for confirm new password text field"
            )
            public static let password = NSLocalizedString(
                "Password",
                comment: "Title for password text field"
            )
            public static let confirmPassword = NSLocalizedString(
                "Confirm Password",
                comment: "Title for confirm password text field"
            )
            public static let recoveryPhrase = NSLocalizedString(
                "Recovery passphrase",
                comment: "Title for recovery passphrase text field"
            )
            public static let walletIdentifier = NSLocalizedString(
                "Wallet Identifier",
                comment: "Title for wallet identifier text field"
            )
            public static let mobile = NSLocalizedString(
                "Mobile Number",
                comment: "Title for mobile number entry"
            )
            public static let word = NSLocalizedString(
                "word",
                comment: "Partial Title for mnemonic word entry. e.g. \"1st word\" "
            )
            public static let oneTimeCode = NSLocalizedString(
                "Code",
                comment: "Title for a one time code."
            )
            public static let addressLine = NSLocalizedString(
                "Address Line",
                comment: "Title for address line # text field"
            )
            public static let fullName = NSLocalizedString(
                "Full Name",
                comment: "Title for person's full name text field"
            )
            public static let city = NSLocalizedString(
                "City",
                comment: "Title for city text field"
            )
            public static let state = NSLocalizedString(
                "State",
                comment: "Title for state text field"
            )
            public static let postCode = NSLocalizedString(
                "Post Code",
                comment: "Title for post code text field"
            )
            public static let zip = NSLocalizedString(
                "Zip",
                comment: "Title for zip text field"
            )

            public static func sendToCryptoWallet(displayCode: String, networkName: String) -> String {
                let format = NSLocalizedString(
                    "Only send %@ to wallets on the %@ network.",
                    comment: "Title for crypto address: 'Only send BTC to wallets on the Bitcoin network'"
                )
                return String(format: format, displayCode, networkName)
            }
        }

        public enum PasswordScore {
            public static let weak = NSLocalizedString(
                "Weak",
                comment: "Label for a Weak password score in password text field"
            )
            public static let normal = NSLocalizedString(
                "Regular",
                comment: "Label for a Normal password score in password text field"
            )
            public static let strong = NSLocalizedString(
                "Strong",
                comment: "Label for a Strong password score in password text field"
            )
        }

        public enum Gesture {
            public static let passwordMismatch = NSLocalizedString(
                "Passwords Do Not Match",
                comment: "Error label when two passwords do not match"
            )
            public static let invalidEmail = NSLocalizedString(
                "Invalid Email Address",
                comment: "Error label when email address is not valid"
            )
            public static let invalidMobile = NSLocalizedString(
                "Invalid Mobile Number",
                comment: "Error label when the mobile number is incorrect"
            )
            public static let invalidCardNumber = NSLocalizedString(
                "Invalid Card Number",
                comment: "Error label when the card number is invalid"
            )
            public static let buyingCryptoNotSupported = NSLocalizedString(
                "Buying crypto not supported.",
                comment: "Buying crypto not supported."
            )
            public static let thisCardOftenDeclines = NSLocalizedString(
                "This card often declines crypto transactions.",
                comment: "This card often declines crypto transactions."
            )
            public static let unsupportedCardType = NSLocalizedString(
                "Card Not Supported",
                comment: "Error label when the card type is not supported"
            )
            public static let invalidExpirationDate = NSLocalizedString(
                "Invalid Expiry Date",
                comment: "Error label when the expiry date is invalid"
            )
            public static let invalidCVV = NSLocalizedString(
                "Invalid CVV",
                comment: "Error label when the CVV is invalid"
            )
            public static let invalidMemo = NSLocalizedString(
                "It can have a maximum of 28 characters",
                comment: "Error label when the memo is invalid"
            )
            public static let invalidCardholderName = NSLocalizedString(
                "Invalid Cardholder Name",
                comment: "Error label when the name is invalid"
            )
            public static let walletId = NSLocalizedString(
                "Invalid Wallet Identifier",
                comment: "Error label when wallet id is not valid"
            )
            public static let invalidCode = NSLocalizedString(
                "Invalid Code",
                comment: "The four digit code is invalid"
            )
            public static let recoveryMismatch = NSLocalizedString(
                "The word does not match your Recovery Phrase",
                comment: "Error label when the word does not match the word in the mnemonic."
            )
            public static let invalidRecoveryPhrase = NSLocalizedString(
                "Invalid recovery phrase. Please try again,",
                comment: "Error label when the recovery phrase is incorrect"
            )
        }
    }
}
