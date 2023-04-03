// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum RecurringBuy {
        public enum Header {
            public static let recurringBuys = NSLocalizedString("Recurring Buys", comment: "Recurring Buys")
            public static let manageButton = NSLocalizedString("Manage", comment: "Manage: button title that opens a list of recurring buys")
        }

        public enum LearnMore {
            public static let title = NSLocalizedString("Automate your buys", comment: "Coin view: Learn more card title")
            public static let description = NSLocalizedString("Buy crypto daily, weekly, or monthly", comment: "Coin view: Learn more card description")
            public static let action = NSLocalizedString("GO", comment: "Coin view: button")
        }

        public enum Row {
            public static let frequency = NSLocalizedString("Next Buy: ", comment: "Coin view: describing when the next buy will occur")
        }

        public enum Manage {
            public static let title = NSLocalizedString("Recurring Buys", comment: "Recurring Buy")
            public static let buttonTitle = NSLocalizedString("Add Recurring Buy", comment: "Add Recurring Buy")
            public static let nextBuy = NSLocalizedString("Next Buy", comment: "Next Buy")
        }

        public enum Summary {
            public static let title = NSLocalizedString("Recurring Buy", comment: "Recurring Buy")
            public static let amount = NSLocalizedString("Amount", comment: "Amount")
            public static let crypto = NSLocalizedString("Crypto", comment: "Crypto")
            public static let paymentMethod = NSLocalizedString("Payment Method", comment: "Payment Method")
            public static let frequency = NSLocalizedString("Frequency", comment: "Frequency")
            public static let nextBuy = NSLocalizedString("Next Buy", comment: "Next Buy")
            public static let remove = NSLocalizedString("Remove", comment: "Remove")

            public enum Removal {
                public static let title = NSLocalizedString("Are you sure you want to remove this recurring buy?", comment: "Removal modal: title")
                public static let remove = NSLocalizedString("Remove", comment: "Remove")
                public static let keep = NSLocalizedString("Keep", comment: "Keep")

                public enum Failure {
                    public static let title = NSLocalizedString("Unable to remove", comment: "Removal failure alert: title")
                    public static let message = NSLocalizedString(
                        "There was a network failure, please try again later.\nError code: %@",
                        comment: "Removal failure alert: message"
                    )
                    public static let ok = NSLocalizedString("OK", comment: "OK")
                }
            }
        }

        public enum Onboarding {
            public static let title = NSLocalizedString("Recurring Buys", comment: "Recurring Buys")
            public static let subtitle = NSLocalizedString(
                "Set an easy, Automatic Recurring Buy starting at just $1 a day, week, or month. Tap into the power of Dollar Cost Averaging.",
                comment: "Set an easy, Automatic Recurring Buy starting at just $1 a day, week, or month. Tap into the power of Dollar Cost Averaging."
            )

            public static let buttonTitle = NSLocalizedString("Get started", comment: "Get started")

            public enum Pages {
                public static let first = NSLocalizedString(
                    "Instead of timing the market, many smart investors use\n",
                    comment: "placeholder is replaced by the phrase: Dollar Cost Averaging"
                )
                public static let firstHighlight = NSLocalizedString(
                    "Dollar Cost Averaging.",
                    comment: "Dollar Cost Averaging"
                )

                public static let second = NSLocalizedString(
                    "The strategy is pretty simple:\n",
                    comment: "The strategy is pretty simple:"
                )
                public static let secondHighlight = NSLocalizedString(
                    "Invest the same amount every week.",
                    comment: "Invest the same amount every week."
                )

                public static let third = NSLocalizedString(
                    "When the price goes down,\n",
                    comment: "When the price goes down, - note the comma is needed, don't remove as part of translation"
                )
                public static let thirdHighlight = NSLocalizedString(
                    "You’ll buy more crypto.",
                    comment: "You’ll buy more crypto."
                )

                public static let fourth = NSLocalizedString(
                    "When the price goes up,\n",
                    comment: "When the price goes up, - note the comma is needed, don't remove as part of translation"
                )
                public static let fourthHighlight = NSLocalizedString(
                    "You’ll buy less crypto.",
                    comment: "You’ll buy more crypto."
                )

                public static let fifth = NSLocalizedString(
                    "But does it work?\n\nOver the past 5 years, buying Bitcoin every week performed better than timing the market ",
                    comment: "But does it work?\nOver the past 5 years, buying Bitcoin every week performed better than timing the market 86% of the time."
                )
                public static let fifthHighlight = NSLocalizedString(
                    "86% of the time.",
                    comment: "But does it work?\nOver the past 5 years, buying Bitcoin every week performed better than timing the market 86% of the time."
                )

                public static let fifthFootnote = NSLocalizedString(
                    "Calculation is based on one $30 purchase a week on a random day. \"Timing the market\" is defined as buying Bitcoin on every 6% dip.",
                    comment: "Calculation is based on one $30 purchase a week on a random day. \"Timing the market\" is defined as buying Bitcoin on every 6% dip."
                )

                public static let learnMore = NSLocalizedString(
                    "Learn more ->",
                    comment: "Learn more ->"
                )
            }
        }
    }
}
