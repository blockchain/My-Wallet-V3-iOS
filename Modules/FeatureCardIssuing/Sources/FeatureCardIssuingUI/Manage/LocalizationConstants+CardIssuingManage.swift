// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants.CardIssuing {

    public enum Manage {

        static let title = NSLocalizedString(
            "My Card",
            comment: "Card Issuing: title My Card"
        )

        static let disclaimer = NSLocalizedString(
            """
            This Blockchain.com Visa® Card is issued by Pathward, \
            N.A., Member FDIC, pursuant to a license from Visa U.S.A. Inc.
            """,
            comment: "Card Issuing: Bottom Page Disclaimer"
        )

        enum Activity {

            enum Button {

                static let help = NSLocalizedString(
                    "Need Help? Contact Support",
                    comment: "Card Issuing: Help Button"
                )
            }

            static let transactionDetails = NSLocalizedString(
                "Transaction Details",
                comment: "Card Issuing: Transaction Details"
            )

            static let status = NSLocalizedString(
                "Status",
                comment: "Card Issuing: Transaction Status"
            )

            static let transactionListTitle = NSLocalizedString(
                "Transactions",
                comment: "Card Issuing: Transaction List Title"
            )

            enum Navigation {

                static let title = NSLocalizedString(
                    "Card Transaction",
                    comment: "Card Issuing: Transaction Details title"
                )
            }

            enum DetailSections {

                static let merchant = NSLocalizedString(
                    "Merchant",
                    comment: "Card Issuing: Merchant"
                )

                static let type = NSLocalizedString(
                    "Type",
                    comment: "Card Issuing: Type"
                )

                static let dateTime = NSLocalizedString(
                    "Date & Time",
                    comment: "Card Issuing: Date & Time"
                )

                static let paymentMethod = NSLocalizedString(
                    "Payment Method",
                    comment: "Card Issuing: Payment Method"
                )

                static let feesTitle = NSLocalizedString(
                    "Blockchain.com Fee",
                    comment: "Card Issuing: Fees Title"
                )

                static let feesDescription = NSLocalizedString(
                    """
                    This Fee price is based on trade size, payment method \
                    and asset being purchased on Blockchain.com.
                    """,
                    comment: "Card Issuing: Fees Description"
                )

                static let adjustedPaymentTitle = NSLocalizedString(
                    "Adjusted Payment",
                    comment: "Card Issuing: Adjusted Payment Description"
                )

                static let adjustedPaymentDescription = NSLocalizedString(
                    """
                    This is the difference back to you in USD from \
                    the moment of purchase and the actual settled amount.
                    """,
                    comment: "Card Issuing: Adjusted Payment Description"
                )

                static let initialAmount = NSLocalizedString(
                    "Initial Amount",
                    comment: "Card Issuing: Initial Amount"
                )

                static let returnedAmount = NSLocalizedString(
                    "Returned Amount",
                    comment: "Card Issuing: Returned Amount"
                )

                static let settledAmount = NSLocalizedString(
                    "Settled Amount",
                    comment: "Card Issuing: Settled Amount"
                )
            }
        }

        enum Transaction {

            enum Status {

                static let pending = NSLocalizedString(
                    "Pending",
                    comment: "Card Issuing: Transaction Status Pending"
                )

                static let cancelled = NSLocalizedString(
                    "Cancelled",
                    comment: "Card Issuing: Transaction Status Cancelled"
                )

                static let declined = NSLocalizedString(
                    "Declined",
                    comment: "Card Issuing: Transaction Status Declined"
                )

                static let completed = NSLocalizedString(
                    "Completed",
                    comment: "Card Issuing: Transaction Status Completed"
                )
            }

            enum TransactionType {

                static let payment = NSLocalizedString(
                    "Payment",
                    comment: "Card Issuing: Transaction Type Payment"
                )

                static let atmWithdrawal = NSLocalizedString(
                    "ATM Withdrawal",
                    comment: "Card Issuing: Transaction Type ATM Withdrawal"
                )

                static let refund = NSLocalizedString(
                    "Refund",
                    comment: "Card Issuing: Transaction Type Refund"
                )

                static let chargeback = NSLocalizedString(
                    "Chargeback",
                    comment: "Card Issuing: Transaction Type Chargeback"
                )

                static let cashback = NSLocalizedString(
                    "Cashback",
                    comment: "Card Issuing: Transaction Type Cashback"
                )
            }
        }

        enum Selector {
            static let myCards = NSLocalizedString(
                "My Cards",
                comment: "Card Issuing: My Cards"
            )

            static let title = NSLocalizedString(
                "Blockchain.com Visa® Card",
                comment: "Card Issuing: Blockchain.com Visa® Card"
            )

            static let shortTitle = NSLocalizedString(
                "Blockchain.com Card",
                comment: "Card Issuing: Blockchain.com Visa® Card"
            )

            enum Button {
                static let manage = NSLocalizedString(
                    "Manage",
                    comment: "Card Issuing: Manage Card"
                )

                static let view = NSLocalizedString(
                    "View",
                    comment: "Card Issuing: View Card"
                )

                static let refresh = NSLocalizedString(
                    "Refresh",
                    comment: "Card Issuing: Refresh Card"
                )
            }

            enum MaxCardNumber {
                static let title = NSLocalizedString(
                    "How many cards can I have?",
                    comment: "Card Issuing: How many cards can I have?"
                )

                static let message = NSLocalizedString(
                    "Only one physical and one virtual card can be active at any given time.",
                    comment: "Card Issuing: Max number of card for type of product"
                )
            }
        }

        enum Button {
            static let manage = NSLocalizedString(
                "Manage Card",
                comment: "Card Issuing: Manage"
            )

            static let addCard = NSLocalizedString(
                "＋ Add Card",
                comment: "Card Issuing: ＋ Add Card"
            )

            static let addFunds = NSLocalizedString(
                "Add Funds",
                comment: "Card Issuing: Add Funds"
            )

            static let changeSource = NSLocalizedString(
                "Change Source",
                comment: "Card Issuing: Change Source"
            )

            static let seeAll = NSLocalizedString(
                "See All",
                comment: "Card Issuing: See All transactions button"
            )

            enum ChoosePaymentMethod {
                static let title = NSLocalizedString(
                    "Choose Payment Method",
                    comment: "Card Issuing: Choose payment method"
                )
                static let caption = NSLocalizedString(
                    "Fund your card purchases",
                    comment: "Card Issuing: Choose payment method caption"
                )
            }
        }

        enum RecentTransactions {

            static let title = NSLocalizedString(
                "Recent Transactions",
                comment: "Card Issuing: Recent Transactions"
            )

            enum Placeholder {

                static let title = NSLocalizedString(
                    "Your Transactions Go Here",
                    comment: "Card Issuing: placeholder title when no transaction"
                )

                static let message = NSLocalizedString(
                    "Once you make a purchase with your card, those details will show up here.",
                    comment: "Card Issuing: placeholder message when no transaction"
                )
            }
        }

        enum Card {
            static let validThru = NSLocalizedString(
                "Valid Thru",
                comment: "Card Issuing: Credit Card Placeholder Valid Thru"
            )
            static let cvv = NSLocalizedString(
                "CVV",
                comment: "Card Issuing: Credit Card Placeholder CVV"
            )
        }

        public enum SourceAccount {
            public static let title = NSLocalizedString(
                "Spend from",
                comment: "Card Issuing: Linked Account Spend From"
            )

            public static let cashBalance = NSLocalizedString(
                "Cash Balance",
                comment: "Card Issuing: Linked Account Cash Balance"
            )
        }

        enum TopUp {
            enum AddFunds {
                static let title = NSLocalizedString(
                    "Add Funds",
                    comment: "Card Issuing: Add Funds"
                )
                static let caption = NSLocalizedString(
                    "Fund your current account",
                    comment: "Card Issuing: Add funds caption"
                )
            }

            enum Swap {
                static let title = NSLocalizedString(
                    "Swap",
                    comment: "Card Issuing: Swap"
                )
                static let caption = NSLocalizedString(
                    "Exchange for another crypto",
                    comment: "Card Issuing: Swap caption"
                )
            }
        }

        enum Details {
            static let title = NSLocalizedString(
                "Manage Your Card",
                comment: "Card Issuing: Manage your card title"
            )
            static let virtualCard = NSLocalizedString(
                "Virtual Card",
                comment: "Card Issuing: Virtual Card"
            )
            static let physicalCard = NSLocalizedString(
                "Physical Card",
                comment: "Card Issuing: Physical Card"
            )
            static let addToAppleWallet = NSLocalizedString(
                "Add to Apple Wallet",
                comment: "Card Issuing: Add To Apple Wallet"
            )
            static let delete = NSLocalizedString(
                "Close Card",
                comment: "Card Issuing: Close Card"
            )

            enum Lock {
                static let title = NSLocalizedString(
                    "Lock Card",
                    comment: "Card Issuing: Lock Card Title"
                )
                static let subtitle = NSLocalizedString(
                    "Temporarily lock your card",
                    comment: "Card Issuing: Lock Card Description"
                )
            }

            enum Support {
                static let title = NSLocalizedString(
                    "Support",
                    comment: "Card Issuing: Support Button Title"
                )
                static let subtitle = NSLocalizedString(
                    "Get help with card related issues",
                    comment: "Card Issuing: Support Button Description"
                )
            }

            enum Personal {
                static let title = NSLocalizedString(
                    "Personal Details",
                    comment: "Card Issuing: Personal Details Title"
                )
                static let subtitle = NSLocalizedString(
                    "View account information",
                    comment: "Card Issuing: Personal Details Description"
                )
            }

            enum PIN {
                static let title = NSLocalizedString(
                    "Manage PIN",
                    comment: "Card Issuing: Manage PIN"
                )
                static let subtitle = NSLocalizedString(
                    "Choose a new PIN for your card activity",
                    comment: "Card Issuing: Choose a new PIN for your card activity"
                )
            }

            enum Statements {
                static let title = NSLocalizedString(
                    "Statements",
                    comment: "Card Issuing: Statements Title"
                )
                static let subtitle = NSLocalizedString(
                    "View monthly card statements",
                    comment: "Card Issuing: View Monthly Card Statements"
                )
            }

            enum Close {
                static let title = NSLocalizedString(
                    "Close ***%@?",
                    comment: "Card Issuing: Close {{Card Name}}"
                )

                static let message = NSLocalizedString(
                    """
                    Are you sure? Once confirmed this action cannot be undone. \
                    If you do want to permanently close this card, click the big red button.
                    """,
                    comment: "Card Issuing: Close Card Warning Message"
                )

                static let confirmation = NSLocalizedString(
                    "Yes Delete Card",
                    comment: "Card Issuing: Confirm Delete Button"
                )
            }
        }
    }
}

extension LocalizationConstants.CardIssuing.Manage {

    enum LegalDocuments {

        static let title = NSLocalizedString(
            "Documents",
            comment: "CIP: Legal Documents navigation title"
        )

        static let statements = NSLocalizedString(
            "Statements",
            comment: "CIP: Statements"
        )

        static let legalDocuments = NSLocalizedString(
            "Legal Documents",
            comment: "CIP: Legal Documents"
        )
    }
}
