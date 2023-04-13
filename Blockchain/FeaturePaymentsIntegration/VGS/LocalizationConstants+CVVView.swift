// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum CVVView {
        static let title = NSLocalizedString(
            "Security",
            comment: "CVV/CVC confirmation screen: top navigation title"
        )

        static let contentTitle = NSLocalizedString(
            "Security Code",
            comment: "CVV/CVC confirmation screen: main title"
        )

        static let contentDescription = NSLocalizedString(
            "Please re-enter the 3 digit CVV code associated with the card below",
            comment: "CVV/CVC confirmation screen: main description"
        )

        static let cvvCode = NSLocalizedString(
            "CVV Code",
            comment: "CVV/CVC confirmation screen: main title"
        )

        static let incorrectCVVCode = NSLocalizedString(
            "Incorrect CVV",
            comment: "CVV/CVC confirmation screen: when a incorrect cvv entered"
        )

        static let cardEndingTitle = NSLocalizedString(
            "Card Ending in %@",
            comment: "CVV/CVC confirmation screen: card details, placholder is replaced by card last four numbers"
        )

        static let next = NSLocalizedString(
            "Next",
            comment: ""
        )

        enum Error {
            static let unknownErrorTitle = NSLocalizedString(
                "Unknown Error",
                comment: "CVV/CVC confirmation screen: An unknown error occured title"
            )

            static let errorMessage = NSLocalizedString(
                "Could not retrieve card details",
                comment: "CVV/CVC confirmation screen: An unknown error occured message"
            )
        }
    }
}
