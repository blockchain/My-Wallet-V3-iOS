// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {

    public enum Swap {
        public enum Trending {
            public enum Header {
                public static let title = NSLocalizedString(
                    "Swap Your Crypto",
                    comment: "Swap Your Crypto"
                )
                public static let description = NSLocalizedString(
                    "Instantly exchange your crypto into any currency we offer for your wallet.",
                    comment: "Instantly exchange your crypto into any currency we offer for your wallet."
                )
            }

            public static let trending = NSLocalizedString(
                "Trending", comment: "Trending"
            )
            public static let newSwap = NSLocalizedString(
                "New Swap", comment: "New Swap"
            )
        }

        public static let completed = NSLocalizedString(
            "Completed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let delayed = NSLocalizedString(
            "Delayed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let expired = NSLocalizedString(
            "Expired",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let failed = NSLocalizedString(
            "Failed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let inProgress = NSLocalizedString(
            "In Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let pending = NSLocalizedString(
            "Pending",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let refundInProgress = NSLocalizedString(
            "Refund in Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let refunded = NSLocalizedString(
            "Refunded",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let swap = NSLocalizedString(
            "Swap",
            comment: "Text shown for the crypto exchange service."
        )
        public static let receive = NSLocalizedString(
            "Receive",
            comment: "Text displayed when reviewing the amount to be received for an exchange order"
        )
        public static let maxString = NSLocalizedString(
            "Max: %@",
            comment: "Max: 25.000 $"
        )
        public static let previewSwap = NSLocalizedString(
            "Preview Swap",
            comment: "Preview Swap"
        )
        public static let swapFrom = NSLocalizedString(
            "Swap from",
            comment: "Swap from"
        )
        public static let swapTo = NSLocalizedString(
            "Swap to",
            comment: "Swap To"
        )

        public static let selectAccount = NSLocalizedString(
            "Select %@ account",
            comment: "Select crypto account acount"
        )

        public static let notEnoughCoin = NSLocalizedString(
            "Not Enough %@",
            comment: "Insufficient funds to perform swap"
        )

        public static let belowMinimumLimitCTA = NSLocalizedString(
            "%@ Minimum",
            comment: "Input below minimum amount valid for transaction"
        )
    }
}
