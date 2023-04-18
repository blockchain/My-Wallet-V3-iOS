// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable all

import Foundation

enum Localization {}

extension Localization {

    enum Error {

        static let title = NSLocalizedString(
            "Oops! Something went wrong",
            comment: "The title for an error explaining to the user that something went wrong."
        )

        static let subtitle = NSLocalizedString(
            "We are unable to continue. Please contact support.",
            comment: "The body message of an error explaining to the user that they must contact support."
        )

        static let network = NSLocalizedString(
            "It looks like there is a problem communicating with Blockchain.com. We are unable to continue, please try again later.",
            comment: "The body message of a network error"
        )
    }

    enum InstitutionList {

        static let title = NSLocalizedString(
            "Find your Bank",
            comment: "The title shown when the customer is selecting their bank from the list."
        )

        static let search = NSLocalizedString(
            "Search",
            comment: "The search placeholder shown when the customer has not typed any term in the search bar."
        )

        enum Error {

            static let invalidAccount = NSLocalizedString(
                "You’ve tried to link an invalid account. Please try another account or contact support.",
                comment: "An error describing that the bank account the customer is trying to link via Open Banking is not valid."
            )

            static let couldNotFindBank = NSLocalizedString(
                "We couldn’t find your bank. Send funds from your bank to your Blockchain Wallet with a Manual Transfer.",
                comment: "An error shown when the user searches for a bank and it's not available, this is the label shown in an empty state which also shows a button to allow the customer to setup a manual bank transfer."
            )

            static let showTransferDetails = NSLocalizedString(
                "Show Transfer Details",
                comment: "The title of a button shown when the user has failed to find their bank and a manual transfer is offered instead. This is a primary button."
            )
        }
    }

    enum Approve {

        enum Action {

            static let approve = NSLocalizedString(
                "Approve",
                comment: "A primary button moving the customer to the next step, this button confirms their acceptance to the terms and conditions/"
            )

            static let deny = NSLocalizedString(
                "Deny",
                comment: "A destructive button to push the customer back, they deny the terms and conditions outlined on the approval page."
            )
        }

        enum Payment {

            static let in90Days = NSLocalizedString(
                "90 Days",
                comment: "The default message shown if we cannot compute a date 90 days in the future. This date is used to explain that access to OpenBanking services will expire in 90 days."
            )

            static let approveYourPayment = NSLocalizedString(
                "Approve Your Payment",
                comment: "The title shown when a user is asked to approve an open banking transaction."
            )

            static let paymentTotal = NSLocalizedString(
                "Payment total",
                comment: "A title which is used to show the total amount the customer is wanting to transact."
            )

            static let paymentInformation = NSLocalizedString(
                "Payment Information",
                comment: "A title which is used to show the payment details that the customer has selected to use, this will be their bank information."
            )

            static let bankName = NSLocalizedString(
                "Bank name",
                comment: "Bank name"
            )

            static let sortCode = NSLocalizedString(
                "Sort Code",
                comment: "Sort Code"
            )

            static let accountNumber = NSLocalizedString(
                "Account Number",
                comment: "Account Number"
            )

            static let bank = NSLocalizedString(
                "Bank",
                comment: "A default value given if we do not know the customers bank name"
            )
        }

        enum TermsAndConditions {

            static let dataSharing = NSLocalizedString(
                "Data Sharing",
                comment: "Data Sharing terms and conditions title"
            )

            static let dataSharingBody = NSLocalizedString(
                "%@ will retrieve your bank data based on your request and provide this information to Blockchain.com",
                comment: "Data Sharing Terms and conditions"
            )

            static let secureConnection = NSLocalizedString(
                "Secure Connection",
                comment: "Secure Connection terms and conditions title"
            )

            static let secureConnectionBody = NSLocalizedString(
                "Data is securely retrieved in read-only format and only for the duration agreed with you. You have the right to withdraw your consent at any time.",
                comment: "Secure Connection terms and conditions"
            )

            static let FCAAuthorisation = NSLocalizedString(
                "FCA Authorisation",
                comment: "FCA Authorisation terms and conditions title"
            )

            static let FCAAuthorisationBody1 = NSLocalizedString(
                "Blockchain.com is an agent of %@. %@ is authorised and regulated by the Financial Conduct Authority under the Payment Service Regulations 2017 [827001] for the provision of Account Information and Payment Initiation services.",
                comment: "FCA Authorisation terms and conditions. Interpolations for entity. e.g. SafeConnect"
            )

            static let FCAAuthorisationBody2 = NSLocalizedString(
                "In order to share your %@ data with Blockchain.com, you will now be securely redirected to your bank to confirm your consent for %@ to read the following information:\n\n• Identification details\n• Account(s) details",
                comment: "FCA Authorisation terms and conditions. Interpolations for 1. bankName and 2. entity. e.g. Monzo and SafeConnect"
            )

            static let aboutTheAccess = NSLocalizedString(
                "About the access",
                comment: "About the access terms and conditions title"
            )

            static let aboutTheAccessBody = NSLocalizedString(
                "%@ will then use these details with Blockchain.com solely for the purposes of buying Cryptocurrency. This access is valid until %@, you can cancel consent at any time via the Blockchain.com settings or via your bank. This request is not a one-off, you will continue to receive consent requests as older versions expire.",
                comment: "About the access terms and conditions. Interpolations for 1. entity and 2. expiry. e.g. SafeConnect and September 17, 2021"
            )
        }
    }

    enum Bank {

        static let yourBank = NSLocalizedString(
            "Your Bank",
            comment: "A default value given if we could not determine the customers bank name."
        )

        enum Action {

            static let next = NSLocalizedString(
                "Next",
                comment: "A button to continue to the next step in Open Banking."
            )

            static let ok = NSLocalizedString(
                "Ok",
                comment: "A button shown at the end of the Open Banking journey to exit and go back to where they were before."
            )

            static let retry = NSLocalizedString(
                "Retry",
                comment: "A button to retry the last step in Open Banking."
            )

            static let tryADifferentBank = NSLocalizedString(
                "Try a Different Bank",
                comment: "A button to select a new banking institution in the event of an error."
            )

            static let tryAgain = NSLocalizedString(
                "Try again",
                comment: "A button to retry the last step in Open Banking."
            )

            static let tryAnotherMethod = NSLocalizedString(
                "Try another method",
                comment: "A button to retry the last step in Open Banking."
            )

            static let back = NSLocalizedString(
                "Go back",
                comment: "A button to reset the progress in Open Banking to start the entire process again."
            )

            static let cancel = NSLocalizedString(
                "Cancel & Go Back",
                comment: "A button to reset the progress in Open Banking to start the entire process again."
            )
        }

        enum Communicating {

            static let title = NSLocalizedString(
                "Taking you to %@",
                comment: "Taking you to {Bank}"
            )

            static let subtitle = NSLocalizedString(
                "This could take up to 30 seconds. Please do not go back or close the app.",
                comment: "This could take up to 30 seconds. Please do not go back or close the app."
            )
        }

        enum Waiting {

            static let title = NSLocalizedString(
                "Waiting to hear from %@",
                comment: "Waiting to hear from {Bank}"
            )

            static let subtitle = NSLocalizedString(
                "This could take up to 30 seconds. Please do not go back or close the app.",
                comment: "This could take up to 30 seconds. Please do not go back or close the app."
            )
        }

        enum Updating {

            static let title = NSLocalizedString(
                "Updating your wallet...",
                comment: "Updating your wallet..."
            )

            static let subtitle = NSLocalizedString(
                "This could take up to 30 seconds. Please do not go back or close the app.",
                comment: "This could take up to 30 seconds. Please do not go back or close the app."
            )
        }

        enum Pending {

            static let title = NSLocalizedString(
                "Order is being processed, we will let you know when its done.",
                comment: "Order is being processed, we will let you know when its done."
            )

            static let subtitle = NSLocalizedString(
                "You can safely close this sheet while we update the order in the background.",
                comment: "You can safely close this sheet while we update the order in the background."
            )
        }

        enum Linked {

            static let title = NSLocalizedString(
                "Bank Linked!",
                comment: "Bank Linked!"
            )

            static let subtitle = NSLocalizedString(
                "Your %@ account is now linked to your Blockchain.com Wallet.",
                comment: "Your {Bank} account is now linked to your Blockchain.com Wallet."
            )
        }

        enum Payment {

            static let title = NSLocalizedString(
                "%@ added!",
                comment: "{Amount} added! e.g. £100 added!"
            )

            static let subtitle = NSLocalizedString(
                "While we wait for your bank to send the cash, here’s early access to %@ in your %@ Cash Account so you can buy crypto right away. Your funds will be available to withdraw once the bank transfer is complete%@.",
                comment: "While we wait for your bank to send the cash, here’s early access to %@ in your %@ Cash Account so you can buy crypto right away. Your funds will be available to withdraw once the bank transfer is complete on %@."
            )

            static let error = NSLocalizedString(
                "%@ is not a supported currency!",
                comment: "{Currency} is not a supported currency! e.g. Martian Dollars is not a supported currency!"
            )
        }

        enum Buying {

            static let title = NSLocalizedString(
                "Buying %@",
                comment: "e.g. Buying 0.0052568 BTC"
            )

            static let subtitle = NSLocalizedString(
                "Order is being processed, we will let you know when its done. You can safely close this sheet while we update the order in the background.",
                comment: "Order is being processed, we will let you know when its done. You can safely close this sheet while we update the order in the background."
            )
        }

        enum Buy {

            static let title = NSLocalizedString(
                "%@ Purchased",
                comment: "e.g. 0.0052568 BTC Purchased"
            )

            static let subtitle = NSLocalizedString(
                "These funds are available now to Sell & Swap. Note: You will not be able to Send or Withdraw these funds from your Wallet.",
                comment: "These funds are available now to Sell & Swap. Note: You will not be able to Send or Withdraw these funds from your Wallet."
            )
        }

        enum Error {

            static let timeout = NSLocalizedString(
                "The request timed out, please try again.",
                comment: "The request timed out, please try again."
            )

            static let bankTransferAccountNameMismatch = (
                title: NSLocalizedString(
                    "Is this your bank?",
                    comment: "Is this your bank?"
                ),
                subtitle: NSLocalizedString(
                    "We noticed the names don’t match. The bank you link must have a matching legal first & last name as your Blockchain.com Account.",
                    comment: "We noticed the names don’t match. The bank you link must have a matching legal first & last name as your Blockchain.com Account."
                ),
                action: Bank.Action.tryADifferentBank
            )

            static let bankTransferAccountExpired = (
                title: NSLocalizedString(
                    "Access Request Expired",
                    comment: "Access Request Expired"
                ),
                subtitle: NSLocalizedString(
                    "The request to pair your account has timed out. Try pairing your account again. If this keeps happening, please contact support.",
                    comment: "The request to pair your account has timed out. Try pairing your account again. If this keeps happening, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferAccountFailed = (
                title: NSLocalizedString(
                    "Failed Connection Request",
                    comment: "Failed Connection Request"
                ),
                subtitle: NSLocalizedString(
                    "There's an issue connecting your bank. Please try again or use another payment method. If this keeps happening, please contact support.",
                    comment: "There's an issue connecting your bank. Please try again or use another payment method. If this keeps happening, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferAccountRejected = (
                title: NSLocalizedString(
                    "Connection Rejected",
                    comment: "Connection Rejected"
                ),
                subtitle: NSLocalizedString(
                    "We believe you have declined linking your account. If this isn't correct, please contact support.",
                    comment: "We believe you have declined linking your account. If this isn't correct, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferAccountInvalid = (
                title: NSLocalizedString(
                    "Invalid Account",
                    comment: "Invalid Account"
                ),
                subtitle: NSLocalizedString(
                    "You’ve tried to link an invalid account. Please try another account or contact support.",
                    comment: "You’ve tried to link an invalid account. Please try another account or contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferAccountAlreadyLinked = (
                title: NSLocalizedString(
                    "Account Already Linked",
                    comment: "Account Already Linked"
                ),
                subtitle: NSLocalizedString(
                    "We noticed this account is already active on another Wallet. If you believe this is incorrect, contact support.",
                    comment: "We noticed this account is already active on another Wallet. If you believe this is incorrect, contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferAccountNotSupported = (
                title: NSLocalizedString(
                    "Please link a Current Account.",
                    comment: "Please link a Current Account."
                ),
                subtitle: NSLocalizedString(
                    "Your bank may charge you extra fees if you buy crypto without a current account.",
                    comment: "Your bank may charge you extra fees if you buy crypto without a current account."
                ),
                action: Bank.Action.back
            )

            static let bankTransferAccountFailedInternal = (
                title: NSLocalizedString(
                    "There was a problem linking your account. Please try again.",
                    comment: "There was a problem linking your account. Please try again."
                ),
                subtitle: NSLocalizedString(
                    "Please try again or select a different payment method.",
                    comment: "Please try again or select a different payment method."
                ),
                action: Bank.Action.tryAnotherMethod
            )

            static let bankTransferAccountRejectedFraud = (
                title: NSLocalizedString(
                    "There was a problem linking your account. Please try again.",
                    comment: "There was a problem linking your account. Please try again."
                ),
                subtitle: NSLocalizedString(
                    "Please try again or select a different payment method.",
                    comment: "Please try again or select a different payment method."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferAccountInfoNotFound = (
                title: NSLocalizedString(
                    "Invalid Account",
                    comment: "Invalid Account"
                ),
                subtitle: NSLocalizedString(
                    "The account you selected isn't active. Please try another account or payment method. If this isn't correct, please contact support.",
                    comment: "The account you selected isn't active. Please try another account or payment method. If this isn't correct, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentInvalid = (
                title: NSLocalizedString(
                    "There was a problem with your order",
                    comment: "There was a problem with your order"
                ),
                subtitle: NSLocalizedString(
                    "Payments can be declined by your bank or card issuer. Please try again with a different bank or card.",
                    comment: "Payments can be declined by your bank or card issuer. Please try again with a different bank or card."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentFailed = (
                title: NSLocalizedString(
                    "Payment Failed",
                    comment: "Title shown when a bank transfer payment failed"
                ),
                subtitle: NSLocalizedString(
                    "There was an issue with your bank. Please try again or use a different payment method. If this keeps happening, please contact support.",
                    comment: "There was an issue with your bank. Please try again or use a different payment method. If this keeps happening, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentDeclined = (
                title: NSLocalizedString(
                    "Payment Declined",
                    comment: "Payment Declined"
                ),
                subtitle: NSLocalizedString(
                    "We believe your bank has declined this payment. Please contact your bank for support",
                    comment: "We believe your bank has declined this payment. Please contact your bank for support"
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentRejected = (
                title: NSLocalizedString(
                    "Payment Rejected",
                    comment: "Payment Rejected"
                ),
                subtitle: NSLocalizedString(
                    "We believe you have declined the payment from your bank account. If this isn't correct, please contact support.",
                    comment: "We believe you have declined the payment from your bank account. If this isn't correct, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentExpired = (
                title: NSLocalizedString(
                    "Payment Request Expired",
                    comment: "Payment Request Expired"
                ),
                subtitle: NSLocalizedString(
                    "We haven't heard from your bank. The payment request has expired. Please try to submit the order again. If this keeps happening, please contact support.",
                    comment: "We haven't heard from your bank. The payment request has expired. Please try to submit the order again. If this keeps happening, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentLimitExceeded = (
                title: NSLocalizedString(
                    "Incomplete Charges",
                    comment: "Incomplete Charges"
                ),
                subtitle: NSLocalizedString(
                    "This payment method has incomplete charges against it. To use this payment method again, place contact support.",
                    comment: "This payment method has incomplete charges against it. To use this payment method again, place contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentUserAccountInvalid = (
                title: NSLocalizedString(
                    "Invalid Account",
                    comment: "Invalid Account"
                ),
                subtitle: NSLocalizedString(
                    "The account you selected isn't active. Please try another account or payment method. If this isn't correct, please contact support.",
                    comment: "The account you selected isn't active. Please try another account or payment method. If this isn't correct, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentFailedInternal = (
                title: NSLocalizedString(
                    "There was a problem with your order",
                    comment: "There was a problem with your order"
                ),
                subtitle: NSLocalizedString(
                    "Payments can be declined by your bank or card issuer. Please try again with a different bank or card.",
                    comment: "Payments can be declined by your bank or card issuer. Please try again with a different bank or card."
                ),
                action: Bank.Action.tryAgain
            )

            static let bankTransferPaymentInsufficientFunds = (
                title: NSLocalizedString(
                    "Insufficient Funds",
                    comment: "Insufficient Funds"
                ),
                subtitle: NSLocalizedString(
                    "Payment failed due to insufficient funds in your account. Try another payment method. If this keep happening, please contact support.",
                    comment: "Payment failed due to insufficient funds in your account. Try another payment method. If this keep happening, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let cardCreateAbandoned = (
                title: NSLocalizedString(
                    "Did you authorize your card payment?",
                    comment: "Did you authorize your card payment?"
                ),
                subtitle: NSLocalizedString(
                    "Authorizing your card payments is a great way to increase the security of your transactions. If you see this message repeatedly, consider choosing a different payment method.",
                    comment: "Authorizing your card payments is a great way to increase the security of your transactions. If you see this message repeatedly, consider choosing a different payment method."
                ),
                action: Bank.Action.tryAgain
            )

            static let cardCreateBankDeclined = (
                title: NSLocalizedString(
                    "Failed to Add Card",
                    comment: "Failed to Add Card"
                ),
                subtitle: NSLocalizedString(
                    "Blockchain.com only allows debit payments for this card. Please choose a different payment method.",
                    comment: "Blockchain.com only allows debit payments for this card. Please choose a different payment method."
                ),
                action: Bank.Action.tryAnotherMethod
            )

            static let cardCreateDebitOnly = (
                title: NSLocalizedString(
                    "Invalid Card",
                    comment: "Invalid Card"
                ),
                subtitle: NSLocalizedString(
                    "Blockchain.com only allows debit payments for this card. Please choose a different payment method.",
                    comment: "Blockchain.com only allows debit payments for this card. Please choose a different payment method."
                ),
                action: Bank.Action.tryAnotherMethod
            )

            static let cardCreateDuplicate = (
                title: NSLocalizedString(
                    "Duplicate Card",
                    comment: "Duplicate Card"
                ),
                subtitle: NSLocalizedString(
                    "You have already added this card to your Blockchain.com account. Please try adding a different card.",
                    comment: "You have already added this card to your Blockchain.com account. Please try adding a different card."
                ),
                action: Bank.Action.cancel
            )

            static let cardCreateExpired = (
                title: NSLocalizedString(
                    "Did you forget to authorize your card payment?",
                    comment: "Did you forget to authorize your card payment?"
                ),
                subtitle: NSLocalizedString(
                    "Authorizing your card payments is a great way to increase the security of your transactions. If you see this message repeatedly, consider choosing a different payment method.",
                    comment: "Authorizing your card payments is a great way to increase the security of your transactions. If you see this message repeatedly, consider choosing a different payment method."
                ),
                action: Bank.Action.tryAgain
            )

            static let cardCreateFailed = (
                title: NSLocalizedString(
                    "Unable to add card",
                    comment: "Unable to add card"
                ),
                subtitle: NSLocalizedString(
                    "Blockchain.com was unable to add your card. Please try again or choose a different payment method.",
                    comment: "Blockchain.com was unable to add your card. Please try again or choose a different payment method."
                ),
                action: Bank.Action.tryAnotherMethod
            )

            static let cardCreateNoToken = (
                title: NSLocalizedString(
                    "Card Not Supported",
                    comment: "Card Not Supported"
                ),
                subtitle: NSLocalizedString(
                    "We were unable to add your card. Please try again or choose a different payment method.",
                    comment: "We were unable to add your card. Please try again or choose a different payment method."
                ),
                action: Bank.Action.tryAnotherMethod
            )

            static let cardPaymentFailed = (
                title: NSLocalizedString(
                    "Payment Failed",
                    comment: "Payment Failed"
                ),
                subtitle: NSLocalizedString(
                    "This payment was unsuccessful. Please try again or choose a different payment method.",
                    comment: "This payment was unsuccessful. Please try again or choose a different payment method."
                ),
                action: Bank.Action.tryAgain
            )

            static let cardPaymentAbandoned = (
                title: NSLocalizedString(
                    "Did you authorize your card payment?",
                    comment: "Did you authorize your card payment?"
                ),
                subtitle: NSLocalizedString(
                    "Authorizing your card payments is a great way to increase the security of your transactions. If you see this message repeatedly, consider choosing a different payment method.",
                    comment: "Authorizing your card payments is a great way to increase the security of your transactions. If you see this message repeatedly, consider choosing a different payment method."
                ),
                action: Bank.Action.tryAgain
            )

            static let cardPaymentDebitOnly = (
                title: NSLocalizedString(
                    "Payment Failed",
                    comment: "Payment Failed"
                ),
                subtitle: NSLocalizedString(
                    "This payment method was unsuccessful. Please try another payment method.",
                    comment: "This payment method was unsuccessful. Please try another payment method."
                ),
                action: Bank.Action.tryAgain
            )

            static let cardPaymentExpired = (
                title: NSLocalizedString(
                    "Did you forget to authorize your card payment?",
                    comment: "Did you forget to authorize your card payment?"
                ),
                subtitle: NSLocalizedString(
                    "Authorizing your card payments is a great way to increase the security of your transactions. If you see this message repeatedly, consider choosing a different payment method.",
                    comment: "Authorizing your card payments is a great way to increase the security of your transactions. If you see this message repeatedly, consider choosing a different payment method."
                ),
                action: Bank.Action.tryAgain
            )

            static let cardPaymentInsufficientFunds = (
                title: NSLocalizedString(
                    "Insufficient Funds",
                    comment: "Insufficient Funds"
                ),
                subtitle: NSLocalizedString(
                    "This payment method lacks sufficient funds. You can add funds or choose a different method.",
                    comment: "This payment method lacks sufficient funds. You can add funds or choose a different method."
                ),
                action: Bank.Action.tryAnotherMethod
            )

            static let cardPaymentBankDeclined = (
                title: NSLocalizedString(
                    "The Bank has declined this card",
                    comment: "The Bank has declined this card"
                ),
                "The card you tried to use has been declined by your bank, please try again or another payment method.",
                subtitle: NSLocalizedString(
                    "Your bank declined this card. Please try again or choose another payment method.",
                    comment: "Your bank declined this card. Please try again or choose another payment method."
                ),
                action: Bank.Action.tryAnotherMethod
            )

            static let cardPaymentNotSupported = (
                title: NSLocalizedString(
                    "Card Not Supported",
                    comment: "Card Not Supported"
                ),
                subtitle: NSLocalizedString(
                    "Your bank declined this card. Please try again or choose another payment method.",
                    comment: "Your bank declined this card. Please try again or choose another payment method."
                ),
                action: Bank.Action.tryAnotherMethod
            )

            static let `default` = (
                title: Localization.Error.title,
                subtitle: NSLocalizedString(
                    "Please try linking your bank again. If this keeps happening, please contact support.",
                    comment: "Please try linking your bank again. If this keeps happening, please contact support."
                ),
                action: Bank.Action.tryAgain
            )

            static let message = (
                title: Localization.Error.title,
                action: Bank.Action.tryAgain
            )

            static let failedToGetPaymentDetails = NSLocalizedString(
                "Failed to get payment details",
                comment: "Failed to get payment details"
            )
        }
    }
}
