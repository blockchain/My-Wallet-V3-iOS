// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable line_length

import Localization

extension LocalizationConstants {
    enum Checkout {
        enum NavigationTitle {
            static let swap = NSLocalizedString(
                "Confirm Swap",
                comment: "Swap title"
            )
            static let sell = NSLocalizedString(
                "Confirm",
                comment: "Sell title"
            )
            static let send = NSLocalizedString(
                "Send %@",
                comment: "Payme Method: Send, placeholder will be replaced by crypto's name, eg Ethereum"
            )
        }

        enum Label {
            static let checkout = NSLocalizedString(
                "Checkout",
                comment: "Checkout title"
            )
            static let fetchingQuote = NSLocalizedString(
                "Fetching Quote",
                comment: "Checkout Fetching Quote"
            )
            static let from = NSLocalizedString(
                "From",
                comment: "From label for swap source"
            )
            static let to = NSLocalizedString(
                "To",
                comment: "To label for swap destination"
            )
            static let purchase = NSLocalizedString(
                "Purchase",
                comment: "Purchase label for buy destination"
            )
            static let total = NSLocalizedString(
                "Total",
                comment: "Total label for buy destination"
            )
            static let blockchainFee = NSLocalizedString(
                "Blockchain.com Fee",
                comment: "Blockchain.com Fee label"
            )
            static let exchangeRate = NSLocalizedString(
                "Rate",
                comment: "Exchange Rate label title"
            )
            static let exchangeRateDisclaimer = NSLocalizedString(
                "The exchange rate is the best price available for %@ in terms of 1 %@.",
                comment: "Exchange rate disclaimer"
            )
            static let networkFees = NSLocalizedString(
                "Network Fees",
                comment: "Network fees title label"
            )
            static let networkFee = NSLocalizedString(
                "Network Fee",
                comment: "Network fee title label"
            )
            static let fundsWillArrive = NSLocalizedString(
                "Funds will arrive",
                comment: "Funds will arrive title label"
            )
            static let availableToWithdraw = NSLocalizedString(
                "Available to withdraw",
                comment: "Available to withdraw title label"
            )

            static let depositDisclaimer = NSLocalizedString(
                "By placing this order, you authorize Blockchain.com, Inc. to debit %@ from your bank account.",
                comment: "By placing this order, you authorize Blockchain.com, Inc. to debit $100 from your bank account."
            )

            static func depositDisclaimerBakkt(date: String) -> String {
                NSLocalizedString(
                    "I authorize Bakkt Marketplace, LLC (“Bakkt”) to debit my bank account provided herein on %@, in the amount I entered via ACH, and, if necessary, to make adjustments for any debits made in error to my bank account on this transaction. If I am a customer residing in one of the following states (HI, PR, UT), I grant such authorization to Bakkt Crypto Solutions, LLC. I understand this authorization will remain in full force and effect until I notify Bakkt/Bakkt Crypto Solutions, LLC in writing that I wish to revoke this authorization. I understand that Bakkt/Bakkt Crypto Solutions, LLC requires at least 1 day prior notice in order to cancel this authorization. Terms of the User Agreement apply.",
                    comment: "Bakkt disclaimer"
                ).interpolating(date)
            }

            static let withdrawDisclaimer = NSLocalizedString(
                "By placing this order, you authorize Blockchain.com, Inc. to credit %@ to your bank account.",
                comment: "By placing this order, you authorize Blockchain.com, Inc. to credit $10.00 to your bank account."
            )

            static func withdrawDisclaimerBakkt(date: String) -> String {
                NSLocalizedString(
                    "I authorize Bakkt Marketplace, LLC (“Bakkt”) to credit my bank account provided herein on %@, in the amount I entered via ACH, and, if necessary, to make adjustments for any debits made in error to my bank account on this transaction. If I am a customer residing in one of the following states (HI, PR, UT), I grant such authorization to Bakkt Crypto Solutions, LLC. I understand this authorization will remain in full force and effect until I notify Bakkt/Bakkt Crypto Solutions, LLC in writing that I wish to revoke this authorization. I understand that Bakkt/Bakkt Crypto Solutions, LLC requires at least 1 day prior notice in order to cancel this authorization. Terms of the User Agreement apply.",
                    comment: "Bakkt disclaimer"
                ).interpolating(date)
            }

            static let networkFeeDescription = NSLocalizedString(
                "A fee paid to process your transaction. This must be paid in %@.",
                comment: "Network fee description label"
            )
            static let assetNetworkFees = NSLocalizedString(
                "%@ Network Fees",
                comment: "Asset network fees label"
            )
            static let processingFees = NSLocalizedString(
                "Processing fee",
                comment: "Blockchain.com & network fees label"
            )
            static let free = NSLocalizedString(
                "Free",
                comment: "No fee label"
            )
            static let noNetworkFee = NSLocalizedString(
                "Free",
                comment: "No network fee label"
            )
            static let and = NSLocalizedString(
                "and",
                comment: "And"
            )
            static let feesDisclaimer = NSLocalizedString(
                "Network fees are set by the %@ and %@ network. [Learn more about fees]()",
                comment: ""
            )
            static let custodialFeeDisclaimer = NSLocalizedString(
                "Blockchain.com requires a fee for this payment method",
                comment: ""
            )
            static let refundDisclaimer = NSLocalizedString(
                "Final amount may change due to market activity. By approving this Swap you agree to Blockchain.com’s [Refund Policy]().",
                comment: "Refund disclaimer"
            )
            static let sellDisclaimer = NSLocalizedString(
                "Final amount may change due to market activity. By approving this Sell you agree to Blockchain.com’s [Refund Policy]().",
                comment: "Refund disclaimer"
            )

            static func buyDisclaimerBakkt(fiatAmount: String, amount: String, asset: String) -> String {
                NSLocalizedString(
                    "You [authorize]() Bakkt Marketplace, LLC to transfer %@ from your account held at Bakkt Marketplace, LLC to Bakkt Crypto Solutions, LLC to pay for your purchase of %@. The actual quantity of coins purchased may change due to volatility in the price of %@, but your order will be executed based on the best price available to Bakkt Crypto Solutions, LLC.  Cryptocurrency transactions are not FDIC or SIPC insured and cryptocurrencies are not securities.",
                    comment: "Bakkt disclaimer"
                ).interpolating(fiatAmount, amount, asset)
            }

            static func sellDisclaimerBakkt(amount: String, asset: String) -> String {
                NSLocalizedString(
                    "You [authorize]() Bakkt Marketplace, LLC to accept the transfer of funds from Bakkt Crypto Solutions, LLC to your account held at Bakkt Marketplace, LLC to complete your sale of %@.  The actual value sold may change due to volatility in the price of %@, but your order will be executed based on the best price available to Bakkt Crypto Solutions, LLC.  Cryptocurrency transactions are not FDIC or SIPC insured and cryptocurrencies are not securities.",
                    comment: "Bakkt disclaimer"
                ).interpolating(amount, asset, asset)
            }

            static let authorizeTitle = NSLocalizedString(
                "AUTHORIZATION AND LIMITED POWER OF ATTORNEY",
                comment: "Title: AUTHORIZATION AND LIMITED POWER OF ATTORNEY"
            )

            static let authorizeBody = NSLocalizedString(
                "Customer hereby authorizes and instructs Bakkt Marketplace, LLC to accept instructions from Customer to transfer funds from Customer’s account in the specified amount to pay for Customer’s cryptocurrency purchase(s) to an account in the name of Bakkt Crypto Solutions, LLC. These funds will be wired to a Bakkt Crypto Solutions, LLC bank account outside of Blockchain.com and Bakkt Marketplace, LLC’s possession and control, which Customer hereby authorizes. Customer acknowledges that Blockchain.com and Bakkt Marketplace, LLC do not have the ability to monitor or recall the funds after the funds have been wired to the Bakkt Crypto Solutions, LLC bank account. Customer hereby authorizes and instructs Bakkt Marketplace, LLC to accept all instructions to deposit funds into Customer’s account from the Bakkt Crypto Solutions, LLC account at the instruction of Bakkt Crypto Solutions, LLC. Customer agrees to hold Blockchain.com and Bakkt Marketplace, LLC harmless in accepting and following instructions from Customer for the transfer of funds from Customer’s account to the Bakkt Crypto Solutions, LLC account and instructions from Bakkt Crypto Solutions, LLC for the transfer of funds into Customer’s account from the Bakkt Crypto Solutions, LLC account. This authorization and limited power of attorney will remain in force for a period of ten year(s) and shall be deemed renewed with each request to transfer money out of or into Customer’s account at Blockchain.com.  Customer may revoke this power of attorney prospectively at any time.",
                comment: "Body: Customer hereby authorizes and instructs Bakkt Marketplace, LLC to accept instructions from Customer to transfer funds from Customer’s account in the specified amount to pay for Customer’s cryptocurrency purchase(s) to an account in the name of Bakkt Crypto Solutions, LLC. These funds will be wired to a Bakkt Crypto Solutions, LLC bank account outside of Blockchain.com and Bakkt Marketplace, LLC’s possession and control, which Customer hereby authorizes. Customer acknowledges that Blockchain.com and Bakkt Marketplace, LLC do not have the ability to monitor or recall the funds after the funds have been wired to the Bakkt Crypto Solutions, LLC bank account. Customer hereby authorizes and instructs Bakkt Marketplace, LLC to accept all instructions to deposit funds into Customer’s account from the Bakkt Crypto Solutions, LLC account at the instruction of Bakkt Crypto Solutions, LLC. Customer agrees to hold Blockchain.com and Bakkt Marketplace, LLC harmless in accepting and following instructions from Customer for the transfer of funds from Customer’s account to the Bakkt Crypto Solutions, LLC account and instructions from Bakkt Crypto Solutions, LLC for the transfer of funds into Customer’s account from the Bakkt Crypto Solutions, LLC account. This authorization and limited power of attorney will remain in force for a period of ten year(s) and shall be deemed renewed with each request to transfer money out of or into Customer’s account at Blockchain.com.  Customer may revoke this power of attorney prospectively at any time."
            )

            static let indicativeDisclaimer = NSLocalizedString(
                "Final amount may change due to market activity.",
                comment: "Final amount may change due to market activity."
            )
            static let termsOfService = NSLocalizedString(
                "By approving this transaction you agree to Blockchain’s [Terms of Service](http://blockchain.com) and its return, refund and cancellation policy.",
                comment: "Refund disclaimer"
            )
            static let countdown = NSLocalizedString(
                "New quote in",
                comment: "Quote time to live coundown label."
            )
            static let soon = NSLocalizedString(
                "soon",
                comment: "Quote time soon."
            )
            static let paymentMethod = NSLocalizedString(
                "Payment Method",
                comment: "From label for swap source"
            )
            static func price(_ code: String) -> String {
                NSLocalizedString("%@ Price", comment: "").interpolating(code)
            }

            static func deposit(_ code: String) -> String {
                NSLocalizedString("Deposit %@", comment: "").interpolating(code)
            }

            static let withdraw = NSLocalizedString(
                "Withdraw",
                comment: "Withdraw title label"
            )
            static let priceDisclaimer = NSLocalizedString(
                "Blockchain.com provides the best market price we receive and applies a spread.",
                comment: ""
            )

            static let memo = NSLocalizedString(
                "Memo",
                comment: "Stellar transaction might require a memo id"
            )
            static let memoPlaceholder = NSLocalizedString(
                "Enter a memo",
                comment: "A placeholder for memo text input when the input is empty"
            )
            static let memoRequiredCaption = NSLocalizedString(
                "%@ requires a memo for all on-chain transactions.",
                comment: "A caption that appears underneath a text input, placeholder is replaced by a crypto asset name, eg Stellar"
            )
            static let investWeeklyTitle = NSLocalizedString(
                "Invest weekly?",
                comment: "Invest weekly?"
            )
            static let investWeeklySubtitle = NSLocalizedString(
                "Buy %@ weekly.\nCancel anytime.",
                comment: "Buy %@ weekly. Cancel anytime. - placeholder is replaced by an amount value"
            )
            static let amountToBeReceivedTitle = NSLocalizedString(
                "Amount to be received",
                comment: "Amount to be received"
            )
            static let subtotalTitle = NSLocalizedString(
                "Subtotal",
                comment: "Subtotal"
            )
            static let networkFeesTitle = NSLocalizedString(
                "Why are there two network fees?",
                comment: "Why are there two network fees?"
            )
            static let networkFeesSubtitle = NSLocalizedString(
                "Network fees are set by the two networks. In order to swap between them, you need to pay fees on each network.",
                comment: "Network fees are set by the two networks. In order to swap between them, you need to pay fees on each network."
            )

            static let bakktAlertTitle = NSLocalizedString(
                "Important information",
                comment: "Important information"
            )

            static let bakktAlertSubTitle = NSLocalizedString(
                "Withdrawals for crypto are currently unavailable, but you can still sell your assets for fiat.",
                comment: "Withdrawals for crypto are currently unavailable, but you can still sell your assets for fiat."
            )
        }

        enum Button {
            static func buy(_ code: String) -> String {
                NSLocalizedString("Buy %@", comment: "").interpolating(code)
            }

            static let confirmSwap = NSLocalizedString(
                "Swap",
                comment: "Swap confirmation button title"
            )

            static let confirmSell = NSLocalizedString(
                "Sell",
                comment: "Sell confirmation button title"
            )

            static let confirm = NSLocalizedString(
                "Confirm",
                comment: "Send confirmation button title"
            )

            static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")

            static let gotIt = NSLocalizedString("Got it", comment: "Got it")

            static let viewDisclosures = NSLocalizedString(
                "Risk Disclosures",
                comment: "Risk Disclosures"
            )
        }

        enum Tooltip {
            static let rateTitle = NSLocalizedString(
                "Rate",
                comment: "Rate Tooltip Title"
            )

            static func rateMessage(code1: String, code2: String) -> String {
                NSLocalizedString("The exchange rate is the best price available for %@ in terms of 1 %@", comment: "")
                    .interpolating(code1, code2)
            }

            static let gotItCTA = NSLocalizedString(
                "Got it",
                comment: "Got it CTA"
            )

            static let feeTitle = NSLocalizedString(
                "Network Fees",
                comment: "Network Fees Tooltip Title"
            )

            static let feeMessage = NSLocalizedString(
                "Network fees are paid as a reward for miners or network validators who validate these on-chain transactions.",
                comment: "Network Fees Message"
            )
        }
    }
}

extension LocalizationConstants.Checkout {
    enum AvailableToTradeInfo {
        static let title = NSLocalizedString(
            "Available to withdraw or send",
            comment: "Available To Trade Info title"
        )

        static let description = NSLocalizedString(
            "Withdrawal holds protect you from fraud and theft if your Blockchain.com account is compromised. The hold period starts once funds are received in your account.",
            comment: "Available To Trade Info description"
        )

        static let learnMoreButton = NSLocalizedString(
            "Learn More",
            comment: "Available To Trade Info learn more button"
        )
    }

    enum ACHTermsInfo {
        static let title = NSLocalizedString(
            "Terms & Conditions",
            comment: "ACH Terms & Conditions title"
        )

        static let simpleBuyDescription = NSLocalizedString(
            "You authorize Blockchain.com, Inc. to debit your %@ account for up to %@ via Bank Transfer (ACH) and, if necessary, to initiate credit entries/adjustments for any debits made in error to your account at the financial institution where you hold your account. You acknowledge that the origination of ACH transactions to your account complies with the provisions of U.S. law. You agree that this authorization cannot be revoked.\n\nYour deposit will be credited to your Blockchain.com account within 0-4 business days at the rate shown at the time of your purchase. You can withdraw these funds from your Blockchain.com account %@ after Blockchain.com receives funds from your financial institution.",
            comment: "ACH Terms & Conditions description"
        )

        static let recurringBuyDescription = NSLocalizedString(
            "You authorize Blockchain.com, Inc. to debit your %@ account for up to %@ (the recurring purchase amount) via Bank Transfer (ACH) and, if necessary, to initiate credit entries/adjustments for any debits made in error to your account at the above Financial Institution. You acknowledge that the origination of ACH transactions to your account comply with the provisions of U.S. law. You agree that this authorization cannot be revoked.\n\nYour deposit will be credited to your Blockchain.com account within 0-4 business days at the rate shown at the time of your purchase. You can withdraw these funds from your Blockchain.com account %@ after Blockchain.com receives funds from your Financial Institution.",
            comment: "ACH Terms & Conditions description"
        )

        static let doneButton = NSLocalizedString(
            "OK",
            comment: "ACH Terms & Conditions done button"
        )
    }

    enum AchTransferDisclaimer {
        static let simpleBuyDescription = NSLocalizedString(
            "By placing this order, you authorize Blockchain.com, Inc. to debit %@ from your bank account for a %@ purchase at a quoted price of %@.",
            comment: "Terms & Conditions description"
        )

        static let recurringBuyDescription = NSLocalizedString(
            "By placing this order, you authorize Blockchain.com, Inc. to debit your %@ account for up to %@ (the recurring purchase amount) via Bank Transfer (ACH).",
            comment: "Terms & Conditions description"
        )

        static let readMoreButton = NSLocalizedString(
            "Read More",
            comment: "Terms & Conditions done button"
        )
    }
}

extension LocalizationConstants.Checkout {
    enum AddressInfoModal {
        static let title = NSLocalizedString(
            "Sending to",
            comment: "Sending to title"
        )

        static let description = NSLocalizedString(
            "To avoid scams, check the full address before sending.",
            comment: "Sending to: Description"
        )

        static let buttonTitle = NSLocalizedString(
            "Got It",
            comment: "Sending to: button title"
        )
    }
}
