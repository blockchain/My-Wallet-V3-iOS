// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants.CardDetailsScreen {
    public enum Errors {
        public static let networkErrorTitle = NSLocalizedString(
            "Network Error",
            comment: "Add a Card screen: network error title"
        )

        public static let networkErrorMessageWithCode = NSLocalizedString(
            "Check your card data and try again, error code %@",
            comment: "Add a card screen: network error message with code"
        )

        public static let networkErrorMessageWithError = NSLocalizedString(
            "Check your card data and try again, error code:\n %@",
            comment: "Add a card screen: network error message with error description"
        )
    }
}

