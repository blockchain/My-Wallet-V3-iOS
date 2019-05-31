//
//  LocalizationConstants.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name
// swiftlint:disable type_body_length

import Foundation

//: Onboarding
struct LocalizationConstants {
    struct ObjCStrings {
        static let  BC_STRING_ALL_WALLETS = NSLocalizedString("All Wallets", comment: "")
        static let  BC_STRING_WALLETS = NSLocalizedString("Wallets", comment: "")
        static let  BC_STRING_ANY_ADDRESS = NSLocalizedString("Any address", comment: "")
        static let  BC_STRING_ARGUMENT_ADDRESSES = NSLocalizedString("%d addresses", comment: "")
        static let  BC_STRING_ARGUMENT_ADDRESS = NSLocalizedString("%d address", comment: "")
        static let  BC_STRING_NO_ADDRESSES_WITH_SPENDABLE_BALANCE_ABOVE_OR_EQUAL_TO_DUST = NSLocalizedString("You have no addresses with a spendable balance greater than or equal to the required dust threshold.", comment: "")
        static let  BC_STRING_SOME_FUNDS_CANNOT_BE_TRANSFERRED_AUTOMATICALLY = NSLocalizedString("Some funds cannot be transferred automatically.", comment: "")
        static let  BC_STRING_ENTER_BITCOIN_ADDRESS_OR_SELECT = NSLocalizedString("Enter Bitcoin address or select", comment: "")
        static let  BC_STRING_ENTER_ETHER_ADDRESS = NSLocalizedString("Enter Ether address", comment: "")
        static let  BC_STRING_YOU_MUST_ENTER_DESTINATION_ADDRESS = NSLocalizedString("You must enter a destination address", comment: "")
        static let  BC_STRING_INVALID_TO_BITCOIN_ADDRESS = NSLocalizedString("Invalid to bitcoin address", comment: "")
        static let  BC_STRING_FROM_TO_DIFFERENT = NSLocalizedString("From and destination have to be different", comment: "")
        static let  BC_STRING_FROM_TO_ADDRESS_DIFFERENT = NSLocalizedString("From and destination address have to be different", comment: "")
        static let  BC_STRING_INVALID_SEND_VALUE = NSLocalizedString("Invalid Send Value", comment: "")
        static let  BC_STRING_SIGNING_INPUTS = NSLocalizedString("Signing Inputs", comment: "")
        static let  BC_STRING_SIGNING_INPUT = NSLocalizedString("Signing Input %d", comment: "")
        static let  BC_STRING_FINISHED_SIGNING_INPUTS = NSLocalizedString("Finished Signing Inputs", comment: "")
        static let  BC_STRING_TRANSFER_ALL_FROM_ADDRESS_ARGUMENT_ARGUMENT = NSLocalizedString("Transferring all funds: Address %i of %i", comment: "")
        static let  BC_STRING_TRANSFER_ALL_CALCULATING_AMOUNTS_AND_FEES_ARGUMENT_OF_ARGUMENT = NSLocalizedString("Calculating: Address %@ of %@", comment: "")
        static let  BC_STRING_TRANSFER_ALL_PREPARING_TRANSFER = NSLocalizedString("Preparing transfer", comment: "")
        static let  BC_STRING_ADD_TO_ADDRESS_BOOK = NSLocalizedString("Add to Address book?", comment: "")
        static let  BC_STRING_NO = NSLocalizedString("No", comment: "")
        static let  BC_STRING_YES = NSLocalizedString("Yes", comment: "")
        static let  BC_STRING_SEND = NSLocalizedString("Send", comment: "")
        static let  BC_STRING_NO_AVAILABLE_FUNDS = NSLocalizedString("You have no available funds to send from this address", comment: "")
        static let  BC_STRING_MUST_BE_ABOVE_OR_EQUAL_TO_DUST_THRESHOLD = NSLocalizedString("Amount must be greater than or equal to the dust threshold (%lld Satoshi)", comment: "")
        static let  BC_STRING_RECEIVE = NSLocalizedString("Receive", comment: "")
        static let  BC_STRING_TRANSACTIONS = NSLocalizedString("Transactions", comment: "")
        static let  BC_STRING_LOAD_MORE_TRANSACTIONS = NSLocalizedString("Load More Transactions", comment: "")
        static let  BC_STRING_SENDING_TRANSACTION = NSLocalizedString("Sending Transaction", comment: "")
        static let  BC_STRING_USE_TOTAL_AVAILABLE_MINUS_FEE_ARGUMENT = NSLocalizedString("Use total available minus fee: %@", comment: "")
        static let  BC_STRING_PAYMENT_SENT = NSLocalizedString("Payment Sent!", comment: "")
        static let  BC_STRING_PAYMENT_SENT_ETHER = NSLocalizedString("Payment Sent! Your balance and transactions will update soon.", comment: "")
        static let  BC_STRING_WAITING_FOR_ETHER_PAYMENT_TO_FINISH_TITLE = NSLocalizedString("Waiting for payment", comment: "")
        static let  BC_STRING_WAITING_FOR_ETHER_PAYMENT_TO_FINISH_MESSAGE = NSLocalizedString("Please wait until your last ether transaction confirms.", comment: "")
        static let  BC_STRING_PAYMENTS_SENT = NSLocalizedString("Payments Sent", comment: "")
        static let  BC_STRING_PAYMENT_TRANSFERRED_FROM_ARGUMENT_ARGUMENT = NSLocalizedString("Transferred funds from %d %@", comment: "")
        static let  BC_STRING_PAYMENT_TRANSFERRED_FROM_ARGUMENT_ARGUMENT_OUTPUTS_ARGUMENT_ARGUMENT_TOO_SMALL = NSLocalizedString("Transferred funds from %d %@. Outputs for %d %@ were too small.", comment: "")
        static let  BC_STRING_PAYMENT_ASK_TO_ARCHIVE_TRANSFERRED_ADDRESSES = NSLocalizedString("Would you like to archive the addresses used?", comment: "")
        static let  BC_STRING_PAYMENT_RECEIVED = NSLocalizedString("Payment Received", comment: "")
        static let  BC_STRING_ERROR_COPYING_TO_CLIPBOARD = NSLocalizedString("An error occurred while copying your address to the clipboard. Please re-select the destination address or restart the app and try again.", comment: "")
        static let  BC_STRING_TRADE_COMPLETED = NSLocalizedString("Trade Completed", comment: "")
        static let  BC_STRING_THE_TRADE_YOU_CREATED_ON_DATE_ARGUMENT_HAS_BEEN_COMPLETED = NSLocalizedString("The trade you created on %@ has been completed!", comment: "")
        static let  BC_STRING_VIEW_DETAILS = NSLocalizedString("View details", comment: "")
        static let  BC_STRING_BUY_WEBVIEW_ERROR_MESSAGE = NSLocalizedString("Something went wrong, please try reopening Buy & Sell Bitcoin again.", comment: "")
        static let  BC_STRING_CONFIRM_PAYMENT = NSLocalizedString("Confirm Payment", comment: "")
        static let  BC_STRING_ADJUST_FEE = NSLocalizedString("Adjust Fee", comment: "")
        static let  BC_STRING_ASK_TO_ADD_TO_ADDRESS_BOOK = NSLocalizedString("Would you like to add the bitcoin address %@ to your address book?", comment: "")
        static let  BC_STRING_ARGUMENT_COPIED_TO_CLIPBOARD = NSLocalizedString("%@ copied to clipboard", comment: "")
        static let  BC_STRING_SEND_FROM = NSLocalizedString("Send from...", comment: "")
        static let  BC_STRING_SEND_TO = NSLocalizedString("Send to...", comment: "")
        static let  BC_STRING_RECEIVE_TO = NSLocalizedString("Receive to...", comment: "")
        static let  BC_STRING_WHERE = NSLocalizedString("Where", comment: "")
        static let  BC_STRING_SEND_TO_ADDRESS = NSLocalizedString("Send to address", comment: "")
        static let  BC_STRING_YOU_MUST_ENTER_A_LABEL = NSLocalizedString("You must enter a label", comment: "")
        static let  BC_STRING_LABEL_MUST_HAVE_LESS_THAN_18_CHAR = NSLocalizedString("Label must have less than 18 characters", comment: "")
        static let  BC_STRING_LABEL_MUST_BE_ALPHANUMERIC = NSLocalizedString("Label must contain letters and numbers only", comment: "")
        static let  BC_STRING_UNARCHIVE = NSLocalizedString("Unarchive", comment: "")
        static let  BC_STRING_ARCHIVE = NSLocalizedString("Archive", comment: "")
        static let  BC_STRING_ARCHIVING_ADDRESSES = NSLocalizedString("Archiving addresses", comment: "")
        static let  BC_STRING_ARCHIVED = NSLocalizedString("Archived", comment: "")
        static let  BC_STRING_NO_LABEL = NSLocalizedString("No Label", comment: "")
        static let  BC_STRING_TRANSACTIONS_COUNT = NSLocalizedString("%d Transactions", comment: "")
        static let  BC_STRING_LOADING_EXTERNAL_PAGE = NSLocalizedString("Loading External Page", comment: "")
        static let  BC_STRING_PASSWORD_NOT_STRONG_ENOUGH = NSLocalizedString("Your password is not strong enough. Please choose a different password.", comment: "")
        static let  BC_STRING_PASSWORD_MUST_BE_LESS_THAN_OR_EQUAL_TO_255_CHARACTERS = NSLocalizedString("Password must be less than or equal to 255 characters", comment: "")
        static let  BC_STRING_PASSWORDS_DO_NOT_MATCH = NSLocalizedString("Passwords do not match", comment: "")
        static let  BC_STRING_PASSWORD_MUST_BE_DIFFERENT_FROM_YOUR_EMAIL = NSLocalizedString("Password must be different from your email", comment: "")
        static let  BC_STRING_NEW_PASSWORD_MUST_BE_DIFFERENT = NSLocalizedString("New password must be different", comment: "")
        static let  BC_STRING_PLEASE_PROVIDE_AN_EMAIL_ADDRESS = NSLocalizedString("Please provide an email address.", comment: "")
        static let  BC_STRING_PLEASE_VERIFY_EMAIL_ADDRESS_FIRST = NSLocalizedString("Please verify your email address first.", comment: "")
        static let  BC_STRING_PLEASE_VERIFY_MOBILE_NUMBER_FIRST = NSLocalizedString("Please verify your mobile number first.", comment: "")
        static let  BC_STRING_INVALID_EMAIL_ADDRESS = NSLocalizedString("Invalid email address.", comment: "")
        static let  BC_STRING_MY_BITCOIN_WALLET = NSLocalizedString("My Bitcoin Wallet", comment: "")
        static let  BC_STRING_PASSWORD_STRENGTH_WEAK = NSLocalizedString("Weak", comment: "")
        static let  BC_STRING_PASSWORD_STRENGTH_REGULAR = NSLocalizedString("Regular", comment: "")
        static let  BC_STRING_PASSWORD_STRENGTH_NORMAL = NSLocalizedString("Normal", comment: "")
        static let  BC_STRING_PASSWORD_STRENGTH_STRONG = NSLocalizedString("Strong", comment: "")
        static let  BC_STRING_UNCONFIRMED = NSLocalizedString("Unconfirmed", comment: "")
        static let  BC_STRING_COUNT_CONFIRMATIONS = NSLocalizedString("%d Confirmations", comment: "")
        static let  BC_STRING_ARGUMENT_CONFIRMATIONS = NSLocalizedString("%@ Confirmations", comment: "")
        static let  BC_STRING_TRANSFERRED = NSLocalizedString("Transferred", comment: "")
        static let  BC_STRING_RECEIVED = NSLocalizedString("Received", comment: "")
        static let  BC_STRING_SENT = NSLocalizedString("Sent", comment: "")
        static let  BC_STRING_ERROR = NSLocalizedString("Error", comment: "")
        static let  BC_STRING_LEARN_MORE = NSLocalizedString("Learn More", comment: "")
        static let  BC_STRING_IMPORT_PRIVATE_KEY = NSLocalizedString("Import Private Key", comment: "")
        static let  BC_STRING_DECRYPTING_PRIVATE_KEY = NSLocalizedString("Decrypting Private Key", comment: "")
        static let  BC_STRING_EXTENDED_PUBLIC_KEY = NSLocalizedString("Extended Public Key", comment: "")
        static let  BC_STRING_SCAN_PAIRING_CODE = NSLocalizedString("Scan Pairing Code", comment: "")
        static let  BC_STRING_PARSING_PAIRING_CODE = NSLocalizedString("Parsing Pairing Code", comment: "")
        static let  BC_STRING_INVALID_PAIRING_CODE = NSLocalizedString("Invalid Pairing Code", comment: "")
        static let  BC_STRING_INSUFFICIENT_FUNDS = NSLocalizedString("Insufficient Funds", comment: "")
        static let  BC_STRING_PLEASE_SELECT_DIFFERENT_ADDRESS = NSLocalizedString("Please select a different address to send from.", comment: "")
        static let  BC_STRING_OK = NSLocalizedString("OK", comment: "")
        static let  BC_STRING_OPEN_MAIL_APP = NSLocalizedString("Open Mail App", comment: "")
        static let  BC_STRING_CANNOT_OPEN_MAIL_APP = NSLocalizedString("Cannot open Mail App", comment: "")
        //static let  BC_STRING_REQUEST_FAILED_PLEASE_CHECK_INTERNET_CONNECTION = NSLocalizedString("Request failed. Please check your internet connection.", comment: "")
        static let  BC_STRING_SOMETHING_WENT_WRONG_CHECK_INTERNET_CONNECTION = NSLocalizedString("An error occurred while updating your spendable balance. Please check your internet connection and try again.", comment: "")
        static let  BC_STRING_EMPTY_RESPONSE = NSLocalizedString("Empty response from server.", comment: "")
        static let  BC_STRING_FORGET_WALLET = NSLocalizedString("Forget Wallet", comment: "")
        static let  BC_STRING_CLOSE_APP = NSLocalizedString("Close App", comment: "")
        static let  BC_STRING_INVALID_GUID = NSLocalizedString("Invalid Wallet ID", comment: "")
        static let  BC_STRING_ENTER_YOUR_CHARACTER_WALLET_IDENTIFIER = NSLocalizedString("Please enter your 36 character wallet identifier correctly. It can be found in the welcome email on startup.", comment: "")
        static let  BC_STRING_INVALID_IDENTIFIER = NSLocalizedString("Invalid Identifier", comment: "")
        static let  BC_STRING_DISABLE_TWO_FACTOR = NSLocalizedString("You must have two-factor authentication disabled to pair manually.", comment: "")
        static let  BC_STRING_WATCH_ONLY = NSLocalizedString("Watch Only", comment: "")
        static let  BC_STRING_WATCH_ONLY_RECEIVE_WARNING = NSLocalizedString("You are about to receive bitcoin to a watch-only address. You can only spend these funds if you have access to the private key. Continue?", comment: "")
        static let  BC_STRING_USER_DECLINED = NSLocalizedString("User Declined", comment: "")
        static let  BC_STRING_CHANGE_PIN = NSLocalizedString("Change PIN", comment: "")
        static let  BC_STRING_ADDRESS = NSLocalizedString("Address", comment: "")
        static let  BC_STRING_BITCOIN_ADDRESSES = NSLocalizedString("Bitcoin Addresses", comment: "")
        static let  BC_STRING_ADDRESSES = NSLocalizedString("Addresses", comment: "")
        static let  BC_STRING_SETTINGS = NSLocalizedString("Settings", comment: "")
        static let  BC_STRING_BACKUP = NSLocalizedString("Backup", comment: "")
        static let  BC_STRING_START_BACKUP = NSLocalizedString("START BACKUP", comment: "")
        static let  BC_STRING_BACKUP_NEEDED = NSLocalizedString("Backup Needed", comment: "")
        static let  BC_STRING_ADD_EMAIL = NSLocalizedString("Add Email", comment: "")
        static let  BC_STRING_BUY_AND_SELL_BITCOIN = NSLocalizedString("Buy & Sell Bitcoin", comment: "")
        static let  BC_STRING_WARNING = NSLocalizedString("Warning!!!", comment: "")
        static let  BC_STRING_NEXT = NSLocalizedString("Next", comment: "")
        static let  BC_STRING_CANCEL = NSLocalizedString("Cancel", comment: "")
        static let  BC_STRING_DISMISS = NSLocalizedString("Dismiss", comment: "")
        static let  BC_STRING_DELETE = NSLocalizedString("Delete", comment: "")
        static let  BC_STRING_CONFIRM = NSLocalizedString("Confirm", comment: "")
        static let  BC_STRING_CANCELLING = NSLocalizedString("Cancelling", comment: "")
        static let  BC_STRING_HOW_WOULD_YOU_LIKE_TO_PAIR = NSLocalizedString("How would you like to pair?", comment: "")
        static let  BC_STRING_MANUALLY = NSLocalizedString("Manually", comment: "")
        static let  BC_STRING_AUTOMATICALLY = NSLocalizedString("Automatically", comment: "")
        static let  BC_STRING_ENTER_PIN = NSLocalizedString("Enter PIN", comment: "")
        static let  BC_STRING_PLEASE_ENTER_PIN = NSLocalizedString("Please enter your PIN", comment: "")
        static let  BC_STRING_PLEASE_ENTER_NEW_PIN = NSLocalizedString("Please enter a new PIN", comment: "")
        static let  BC_STRING_CONFIRM_PIN = NSLocalizedString("Confirm your PIN", comment: "")
        static let  BC_STRING_WARNING_TITLE = NSLocalizedString("Warning", comment: "")
        static let  BC_STRING_PAYMENT_REQUEST_BITCOIN_ARGUMENT_ARGUMENT = NSLocalizedString("Please send %@ to bitcoin address.\n%@", comment: "")
        static let  BC_STRING_PAYMENT_REQUEST_BITCOIN_CASH_ARGUMENT = NSLocalizedString("Please send BCH to the Bitcoin Cash address\n%@", comment: "")
        static let  BC_STRING_AMOUNT = NSLocalizedString("Amount", comment: "")
        static let  BC_STRING_PAYMENT_REQUEST_HTML = NSLocalizedString("Please send payment to bitcoin address (<a href=\"https://blockchain.info/wallet/bitcoin-faq\">help?</a>): %@", comment: "")
        static let  BC_STRING_CLOSE = NSLocalizedString("Close", comment: "")
        static let  BC_STRING_TRANSACTION_DETAILS = NSLocalizedString("Transaction details", comment: "")
        static let  BC_STRING_CREATE = NSLocalizedString("Create", comment: "")
        static let  BC_STRING_NAME = NSLocalizedString("Name", comment: "")
        static let  BC_STRING_EDIT = NSLocalizedString("Edit", comment: "")
        static let  BC_STRING_LABEL = NSLocalizedString("Label", comment: "")
        static let  BC_STRING_DONE = NSLocalizedString("Done", comment: "")
        static let  BC_STRING_SAVE = NSLocalizedString("Save", comment: "")
        static let  BC_STRING_CREATE_WALLET = NSLocalizedString("Create Wallet", comment: "")
        static let  BC_STRING_ACCOUNTS = NSLocalizedString("Accounts", comment: "")
        static let  BC_STRING_TOTAL_BALANCE = NSLocalizedString("Total Balance", comment: "")
        static let  BC_STRING_IMPORTED_ADDRESSES = NSLocalizedString("Imported Addresses", comment: "")
        static let  BC_STRING_IMPORTED_ADDRESSES_ARCHIVED = NSLocalizedString("Imported Addresses (Archived)", comment: "")
        static let  BC_STRING_UPGRADE_TO_V3 = NSLocalizedString("Upgrade to V3", comment: "")
        static let  BC_STRING_ADDRESS_BOOK = NSLocalizedString("Address book", comment: "")
        static let  BC_STRING_LOADING_VERIFYING = NSLocalizedString ("Verifying", comment: "")
        static let  BC_STRING_LOADING_DECRYPTING_WALLET = NSLocalizedString("Decrypting Wallet", comment: "")
        static let  BC_STRING_LOADING_LOADING_TRANSACTIONS = NSLocalizedString("Loading transactions", comment: "")
        static let  BC_STRING_LOADING_LOADING_BUILD_HD_WALLET = NSLocalizedString("Initializing Wallet", comment: "")
        static let  BC_STRING_LOADING_CHECKING_WALLET_UPDATES = NSLocalizedString("Checking for Wallet updates", comment: "")
        static let  BC_STRING_LOADING_CREATING_V3_WALLET = NSLocalizedString("Creating V3 Wallet", comment: "")
        static let  BC_STRING_LOADING_CREATING = NSLocalizedString("Creating", comment: "")
        static let  BC_STRING_LOADING_CREATING_WALLET = NSLocalizedString("Creating new Wallet", comment: "")
        static let  BC_STRING_LOADING_CREATING_NEW_ADDRESS = NSLocalizedString("Creating new address", comment: "")
        static let  BC_STRING_LOADING_CREATING_REQUEST = NSLocalizedString("Creating request", comment: "")
        static let  BC_STRING_LOADING_CREATING_INVITATION = NSLocalizedString("Creating invitation", comment: "")
        static let  BC_STRING_IDENTIFIER = NSLocalizedString("Identifier", comment: "")
        static let  BC_STRING_OPEN_ARGUMENT = NSLocalizedString("Open %@?", comment: "")
        static let  BC_STRING_LEAVE_APP = NSLocalizedString("You will be leaving the app.", comment: "")
        static let  BC_STRING_TERMS_OF_SERVICE = NSLocalizedString("Terms of Service", comment: "")
        static let  BC_STRING_TRANSACTION = NSLocalizedString("Transaction", comment: "")
        static let  BC_STRING_AUTOMATIC_PAIRING = NSLocalizedString("Automatic Pairing", comment: "")
        static let  BC_STRING_INCORRECT_PASSWORD = NSLocalizedString("Incorrect password", comment: "")
        static let  BC_STRING_CREATE_A_WALLET = NSLocalizedString("Create a Wallet", comment: "")
        static let  BC_STRING_REQUEST_AMOUNT = NSLocalizedString("Request Amount", comment: "")
        static let  BC_STRING_REQUEST = NSLocalizedString("Request", comment: "")
        static let  BC_STRING_LABEL_ADDRESS = NSLocalizedString("Label Address", comment: "")
        static let  BC_STRING_SCAN_PRIVATE_KEY = NSLocalizedString("Scan Private Key", comment: "")
        static let  BC_STRING_IMPORT_ADDRESS = NSLocalizedString("Import address", comment: "")
        static let  BC_STRING_CONTINUE = NSLocalizedString("Continue", comment: "")
        static let  BC_STRING_LOG_IN = NSLocalizedString("Log In", comment: "")
        static let  BC_STRING_PASSWORD_MODAL_INSTRUCTIONS = NSLocalizedString("Please enter your password to log into your Blockchain wallet.", comment: "")
        static let  BC_STRING_OR_START_OVER_AND = NSLocalizedString("Or start over and ", comment: "")
        static let  BC_STRING_COPY_ADDRESS = NSLocalizedString("Copy Address", comment: "")
        static let  BC_STRING_ARCHIVE_ADDRESS = NSLocalizedString("Archive Address", comment: "")
        static let  BC_STRING_UNARCHIVE_ADDRESS = NSLocalizedString("Unarchive Address", comment: "")
        static let  BC_STRING_AT_LEAST_ONE_ACTIVE_ADDRESS = NSLocalizedString("You must leave at least one active address", comment: "")
        static let  BC_STRING_LOGOUT_AND_FORGET_WALLET = NSLocalizedString("Logout and forget wallet", comment: "")
        static let  BC_STRING_SURVEY_ALERT_TITLE = NSLocalizedString("Would you like to tell us about your experience with Blockchain?", comment: "")
        static let  BC_STRING_SURVEY_ALERT_MESSAGE = NSLocalizedString("You will be leaving the app.", comment: "")
        static let  BC_STRING_INVALID_BITCOIN_ADDRESS_ARGUMENT = NSLocalizedString("Invalid Bitcoin address: %@", comment: "")
        static let  BC_STRING_INVALID_ETHER_ADDRESS_ARGUMENT = NSLocalizedString("Invalid Ether address: %@", comment: "")
        static let  BC_STRING_UPDATE = NSLocalizedString("Update", comment: "")
        static let  BC_STRING_DISABLED = NSLocalizedString("Disabled", comment: "")
        static let  BC_STRING_REMINDER_CHECK_EMAIL_TITLE = NSLocalizedString("Check Your Inbox", comment: "")
        static let  BC_STRING_CONTINUE_TO_MAIL = NSLocalizedString("Continue To Mail", comment: "")
        static let  BC_STRING_REMINDER_CHECK_EMAIL_MESSAGE = NSLocalizedString("Look for an email from Blockchain and click the verification link to complete your wallet setup.", comment: "")
        static let  BC_STRING_REMINDER_BACKUP_TITLE = NSLocalizedString("Backup Your Funds", comment: "")
        static let  BC_STRING_REMINDER_BACKUP_NOW = NSLocalizedString("Backup Now", comment: "")
        static let  BC_STRING_REMINDER_TWO_FACTOR_TITLE = NSLocalizedString("2-Step Verification", comment: "")
        static let  BC_STRING_REMINDER_TWO_FACTOR_MESSAGE = NSLocalizedString("Prevent unauthorized access to your wallet. Enable 2-step verification to increase wallet security.", comment: "")
        static let  BC_STRING_SETTINGS_ACCOUNT_DETAILS = NSLocalizedString("Account Details", comment: "")
        static let  BC_STRING_SETTINGS_NOTIFICATIONS = NSLocalizedString("Notifications", comment: "")
        static let  BC_STRING_SETTINGS_EMAIL = NSLocalizedString("Email", comment: "")
        static let  BC_STRING_SETTINGS_UPDATE_EMAIL = NSLocalizedString("Update Email", comment: "")
        static let  BC_STRING_SETTINGS_ENTER_EMAIL_ADDRESS = NSLocalizedString("Enter Email Address", comment: "")
        static let  BC_STRING_SETTINGS_VERIFIED = NSLocalizedString("Verified", comment: "")
        static let  BC_STRING_SETTINGS_UNVERIFIED = NSLocalizedString("Unverified", comment: "")
        static let  BC_STRING_SETTINGS_UNCONFIRMED = NSLocalizedString("Unconfirmed", comment: "")
        static let  BC_STRING_SETTINGS_STORED = NSLocalizedString("Stored", comment: "")
        static let  BC_STRING_SETTINGS_NOT_STORED = NSLocalizedString("Not Stored", comment: "")
        static let  BC_STRING_SETTINGS_PLEASE_ADD_EMAIL = NSLocalizedString("Please add an email address", comment: "")
        static let  BC_STRING_SETTINGS_NEW_EMAIL_MUST_BE_DIFFERENT = NSLocalizedString("New email must be different", comment: "")
        static let  BC_STRING_SETTINGS_MOBILE_NUMBER = NSLocalizedString("Mobile Number", comment: "")
        static let  BC_STRING_SETTINGS_UPDATE_MOBILE = NSLocalizedString("Update Mobile", comment: "")
        static let  BC_STRING_SETTINGS_ENTER_MOBILE_NUMBER = NSLocalizedString("Enter Mobile Number", comment: "")
        static let  BC_STRING_SETTINGS_PREFERENCES = NSLocalizedString("Preferences", comment: "")
        static let  BC_STRING_SETTINGS_DISPLAY_PREFERENCES = NSLocalizedString("Display", comment: "")
        static let  BC_STRING_SETTINGS_FEES = NSLocalizedString("Fees", comment: "")
        static let  BC_STRING_SETTINGS_FEE_PER_KB = NSLocalizedString("Fee per KB", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY = NSLocalizedString("Security", comment: "")
        static let  BC_STRING_SETTINGS_PIN_SWIPE_TO_RECEIVE = NSLocalizedString("Swipe to Receive", comment: "")
        static let  BC_STRING_SWIPE_TO_RECEIVE_NO_INTERNET_CONNECTION_WARNING = NSLocalizedString("We can't check whether this address has been used. Show anyway?", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION = NSLocalizedString("2-step Verification", comment: "")
        static let  BC_STRING_ENABLE = NSLocalizedString("Enable", comment: "")
        static let  BC_STRING_DISABLE = NSLocalizedString("Disable", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_MUST_DISABLE_TWO_FACTOR_SMS_ARGUMENT = NSLocalizedString("You must disable SMS 2-Step Verification before changing your mobile number (%@).", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED_ARGUMENT = NSLocalizedString("2-step Verification is currently enabled for %@.", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED = NSLocalizedString("2-step Verification is currently enabled.", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_DISABLED = NSLocalizedString("2-step Verification is currently disabled.", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_MESSAGE_SMS_ONLY = NSLocalizedString("You can enable 2-step Verification via SMS on your mobile phone. In order to use other authentication methods instead, please login to our web wallet.", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_GOOGLE = NSLocalizedString("Google Authenticator", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_YUBI_KEY = NSLocalizedString("Yubi Key", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_SMS = NSLocalizedString("SMS", comment: "")
        static let  BC_STRING_UNKNOWN = NSLocalizedString("Unknown", comment: "")
        static let  BC_STRING_ENTER_ARGUMENT_TWO_FACTOR_CODE = NSLocalizedString("Please enter your %@ 2FA code", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_CHANGE_PASSWORD = NSLocalizedString("Change Password", comment: "")
        static let  BC_STRING_SETTINGS_SECURITY_PASSWORD_CHANGED = NSLocalizedString("Password changed. Please login to continue.", comment: "")
        static let  BC_STRING_SETTINGS_LOCAL_CURRENCY = NSLocalizedString("Local Currency", comment: "")
        static let  BC_STRING_SETTINGS_BTC = NSLocalizedString("Bitcoin Unit", comment: "")
        static let  BC_STRING_SETTINGS_EMAIL_NOTIFICATIONS = NSLocalizedString("Email Notifications", comment: "")
        static let  BC_STRING_SETTINGS_SMS_NOTIFICATIONS = NSLocalizedString("SMS Notifications", comment: "")
        static let  BC_STRING_SETTINGS_PUSH_NOTIFICATIONS = NSLocalizedString("Push Notifications", comment: "")
        static let  BC_STRING_SETTINGS_NOTIFICATIONS_SMS = NSLocalizedString("SMS", comment: "")
        static let  BC_STRING_SETTINGS_EMAIL_PROMPT = NSLocalizedString("Your verified email address is used to send payment alerts, ID reminders, and login codes.", comment: "")
        static let  BC_STRING_SETTINGS_SMS_PROMPT = NSLocalizedString("Your mobile phone can be used to enable two-factor authentication or to receive alerts.", comment: "")
        static let  BC_STRING_SETTINGS_NOTIFICATIONS_FOOTER = NSLocalizedString("Enable notifications to receive an email or SMS message whenever you receive bitcoin.", comment: "")
        static let  BC_STRING_SETTINGS_SWIPE_TO_RECEIVE_IN_FIVES_FOOTER = NSLocalizedString("Enable this option to reveal a receive address when you swipe left on the PIN screen, making receiving bitcoin even faster. Five addresses will be loaded consecutively, after which logging in is required to show new addresses.", comment: "")
        static let  BC_STRING_SETTINGS_SWIPE_TO_RECEVE_IN_SINGLES_FOOTER = NSLocalizedString("Enable this option to reveal a receive address when you swipe left on the PIN screen, making receiving bitcoin even faster. Only one address will be loaded, logging in is required to show a new address.", comment: "")
        static let  BC_STRING_SETTINGS_ABOUT = NSLocalizedString("About", comment: "")
        static let  BC_STRING_SETTINGS_ABOUT_US = NSLocalizedString("About Us", comment: "")
        static let  BC_STRING_SETTINGS_PRIVACY_POLICY = NSLocalizedString("Privacy Policy", comment: "")
        static let  BC_STRING_SETTINGS_TERMS_OF_SERVICE = NSLocalizedString("Terms of Service", comment: "")
        static let  BC_STRING_SETTINGS_COOKIE_POLICY = NSLocalizedString("Cookies Policy", comment: "")
        static let  BC_STRING_SETTINGS_VERIFY = NSLocalizedString("Verify", comment: "")
        static let  BC_STRING_SETTINGS_SENT_TO_ARGUMENT = NSLocalizedString("Sent to %@", comment: "")
        static let  BC_STRING_SETTINGS_VERIFY_MOBILE_SEND = NSLocalizedString("Send verification SMS", comment: "")
        static let  BC_STRING_SETTINGS_VERIFY_MOBILE_RESEND = NSLocalizedString("Resend verification SMS", comment: "")
        static let  BC_STRING_SETTINGS_VERIFY_ENTER_CODE = NSLocalizedString("Enter your verification code", comment: "")
        static let  BC_STRING_ENTER_VERIFICATION_CODE = NSLocalizedString("Enter Verification Code", comment: "")
        static let  BC_STRING_SETTINGS_VERIFY_EMAIL_RESEND = NSLocalizedString("Resend verification email", comment: "")
        static let  BC_STRING_SETTINGS_VERIFY_INVALID_CODE = NSLocalizedString("Invalid verification code. Please try again.", comment: "")
        static let  BC_STRING_SETTINGS_CHANGE_EMAIL = NSLocalizedString("Change Email", comment: "")
        static let  BC_STRING_SETTINGS_NEW_EMAIL_ADDRESS = NSLocalizedString("New Email Address", comment: "")
        static let  BC_STRING_SETTINGS_NEW_EMAIL_ADDRESS_WARNING_DISABLE_NOTIFICATIONS = NSLocalizedString("You currently have email notifications enabled. Changing your email will disable email notifications.", comment: "")
        static let  BC_STRING_SETTINGS_EMAIL_VERIFIED = NSLocalizedString("Your email has been verified.", comment: "")
        static let  BC_STRING_SETTINGS_WALLET_ID = NSLocalizedString("Wallet ID", comment: "")
        static let  BC_STRING_SETTINGS_PROFILE = NSLocalizedString("Profile", comment: "")
        static let  BC_STRING_SETTINGS_CHANGE_MOBILE_NUMBER = NSLocalizedString("Change Mobile Number", comment: "")
        static let  BC_STRING_SETTINGS_NEW_MOBILE_NUMBER = NSLocalizedString("New Mobile Number", comment: "")
        static let  BC_STRING_SETTINGS_NEW_MOBILE_NUMBER_WARNING_DISABLE_NOTIFICATIONS = NSLocalizedString("You currently have SMS notifications enabled. Changing your email will disable SMS notifications.", comment: "")
        static let  BC_STRING_SETTINGS_ERROR_INVALID_MOBILE_NUMBER = NSLocalizedString("Invalid mobile number.", comment: "")
        static let  BC_STRING_SETTINGS_MOBILE_NUMBER_VERIFIED = NSLocalizedString("Your mobile number has been verified.", comment: "")
        static let  BC_STRING_SETTINGS_ERROR_LOADING_TITLE = NSLocalizedString("Error loading settings", comment: "")
        static let  BC_STRING_SETTINGS_ERROR_LOADING_MESSAGE = NSLocalizedString("Please check your internet connection.", comment: "")
        static let  BC_STRING_SETTINGS_ERROR_UPDATING_TITLE = NSLocalizedString("Error updating settings", comment: "")
        static let  BC_STRING_SETTINGS_CHANGE_FEE_TITLE = NSLocalizedString("Change fee per kilobyte", comment: "")
        static let  BC_STRING_SETTINGS_CHANGE_FEE_MESSAGE_ARGUMENT = NSLocalizedString("Current rate: %@ BTC", comment: "")
        static let  BC_STRING_SETTINGS_FEE_ARGUMENT_BTC = NSLocalizedString("%@ BTC", comment: "")
        static let  BC_STRING_SETTINGS_FEE_TOO_HIGH = NSLocalizedString("Fee is too high (0.01 BTC limit)", comment: "")
        static let  BC_STRING_SETTINGS_COPY_GUID = NSLocalizedString("Copy Wallet ID", comment: "")
        static let  BC_STRING_SETTINGS_COPY_GUID_WARNING = NSLocalizedString("Warning: Your wallet identifier is sensitive information. Copying it may compromise the security of your wallet.", comment: "")
        static let  BC_STRING_COPY_TO_CLIPBOARD = NSLocalizedString("Copy to clipboard", comment: "")
        static let  BC_STRING_WARNING_FOR_ZERO_FEE = NSLocalizedString("Transactions with no fees may take a long time to confirm or may not be confirmed at all. Would you like to continue?", comment: "")
        static let  BC_STRING_SETTINGS_ERROR_FEE_OUT_OF_RANGE = NSLocalizedString("Please enter a fee greater than 0 BTC and at most 0.01 BTC", comment: "")
        static let  BC_STRING_VERIFY_EMAIL = NSLocalizedString("Verify Email", comment: "")
        static let  BC_STRING_EMAIL_VERIFIED = NSLocalizedString("Email Verified", comment: "")
        static let  BC_STRING_BACKUP_PHRASE = NSLocalizedString("Backup Phrase", comment: "")
        static let  BC_STRING_WALLET_RECOVERY_PHRASE = NSLocalizedString("Recovery Phrase", comment: "")
        static let  BC_STRING_PHRASE_BACKED = NSLocalizedString("Phrase Backed", comment: "")
        static let  BC_STRING_LINK_MOBILE = NSLocalizedString("Link Mobile", comment: "")
        static let  BC_STRING_MOBILE_LINKED = NSLocalizedString("Mobile Linked", comment: "")
        static let  BC_STRING_TWO_STEP_ENABLED_SUCCESS = NSLocalizedString("2-Step has been enabled for SMS.", comment: "")
        static let  BC_STRING_TWO_STEP_DISABLED_SUCCESS = NSLocalizedString("2-Step has been disabled.", comment: "")
        static let  BC_STRING_TWO_STEP_ERROR = NSLocalizedString("An error occurred while changing 2-Step verification.", comment: "")
        static let  BC_STRING_TWO_STEP_ENABLED = NSLocalizedString("2-Step Enabled", comment: "")
        static let  BC_STRING_ENABLE_TWO_STEP = NSLocalizedString("Enable 2-Step", comment: "")
        static let  BC_STRING_ENABLE_TWO_STEP_SMS = NSLocalizedString("Enable 2-Step for SMS", comment: "")
        static let  BC_STRING_NEW_ADDRESS = NSLocalizedString("New Address", comment: "")
        static let  BC_STRING_NEW_ADDRESS_SCAN_QR_CODE = NSLocalizedString("Scan QR code", comment: "")
        static let  BC_STRING_NEW_ADDRESS_CREATE_NEW = NSLocalizedString("Create new address", comment: "")
        static let  BC_STRING_SEARCH = NSLocalizedString("Search", comment: "")
        static let  BC_STRING_TOTAL = NSLocalizedString("Total", comment: "")
        static let  BC_STRING_SENDING = NSLocalizedString("Sending", comment: "")
        static let  BC_STRING_RECOVERY_PHRASE_ERROR_INSTRUCTIONS = NSLocalizedString("Please enter your recovery phrase with words separated by spaces", comment: "")
        static let  BC_STRING_LOADING_RECOVERING_WALLET = NSLocalizedString("Recovering Funds", comment: "")
        static let  BC_STRING_LOADING_RECOVERING_WALLET_CHECKING_ARGUMENT_OF_ARGUMENT = NSLocalizedString("Checking for more: Step %d of %d", comment: "")
        static let  BC_STRING_LOADING_RECOVERING_WALLET_ARGUMENT_FUNDS_ARGUMENT = NSLocalizedString("Found %d, with %@", comment: "")
        static let  BC_STRING_LOADING_RECOVERY_CREATING_WALLET = NSLocalizedString("Creating Wallet", comment: "")
        static let  BC_STRING_INVALID_RECOVERY_PHRASE = NSLocalizedString("Invalid recovery phrase. Please try again", comment: "")
        static let  BC_STRING_SEND_ERROR_NO_INTERNET_CONNECTION = NSLocalizedString("No internet connection available. Please check your network settings.", comment: "")
        static let  BC_STRING_SEND_ERROR_FEE_TOO_LOW = NSLocalizedString("The fee you have specified is too low.", comment: "")
        static let  BC_STRING_HIGH_FEE_WARNING_TITLE = NSLocalizedString("Large Transaction", comment: "")
        static let  BC_STRING_HIGH_FEE_WARNING_MESSAGE = NSLocalizedString("This is an oversized bitcoin transaction. Your wallet needs to consolidate many smaller payments you've received in the past. This requires a relatively high fee in order to be confirmed quickly. If it’s fine for the transaction to take longer to confirm, you can reduce the fee manually by tapping \"Customize Fee.\"", comment: "")
        static let  BC_STRING_NO_EMAIL_CONFIGURED = NSLocalizedString("You do not have an account set up for Mail. Please contact %@", comment: "")
        static let  BC_STRING_PIN = NSLocalizedString("PIN", comment: "")
        static let  BC_STRING_MAKE_DEFAULT = NSLocalizedString("Make Default", comment: "")
        static let  BC_STRING_DEFAULT = NSLocalizedString("Default", comment: "")
        static let  BC_STRING_TRANSFER_FUNDS = NSLocalizedString("Transfer Funds", comment: "")
        static let  BC_STRING_TRANSFER_AMOUNT = NSLocalizedString("Transfer Amount", comment: "")
        static let  BC_STRING_FEE = NSLocalizedString("Fee", comment: "")
        static let  BC_STRING_TRANSFER_FUNDS_DESCRIPTION_ONE = NSLocalizedString("For your safety, we recommend you to transfer any balances in your imported addresses into your Blockchain wallet.", comment: "")
        static let  BC_STRING_TRANSFER_FUNDS_DESCRIPTION_TWO = NSLocalizedString("Your transferred funds will be safe and secure, and you'll benefit from increased privacy and convenient backup and recovery features.", comment: "")
        static let  BC_STRING_ARCHIVE_FOOTER_TITLE = NSLocalizedString("Archive this if you do NOT want to use it anymore. Your funds will remain safe, and you can unarchive it at any time.", comment: "")
        static let  BC_STRING_ARCHIVED_FOOTER_TITLE = NSLocalizedString("This is archived. Though you cannot send funds from here, any and all funds will remain safe. Simply unarchive to start using it again.", comment: "")
        static let  BC_STRING_TRANSFER_FOOTER_TITLE = NSLocalizedString("For your safety, we recommend you to transfer any balances in your imported addresses into your Blockchain wallet.", comment: "")
        static let  BC_STRING_EXTENDED_PUBLIC_KEY_FOOTER_TITLE = NSLocalizedString("Keep your xPub private. Someone with access to your xPub will be able to see all of your funds and transactions.", comment: "")
        static let  BC_STRING_EXTENDED_PUBLIC_KEY_WARNING = NSLocalizedString("Sharing your xPub authorizes others to track your transaction history. As authorized persons may be able to disrupt you from accessing your wallet, only share your xPub with people you trust.", comment: "")
        static let  BC_STRING_WATCH_ONLY_FOOTER_TITLE = NSLocalizedString("This is a watch-only address. To spend your funds from this wallet, please scan your private key.", comment: "")
        static let  BC_STRING_SET_DEFAULT_ACCOUNT = NSLocalizedString("Set as Default?", comment: "")
        static let  BC_STRING_AT_LEAST_ONE_ADDRESS_REQUIRED = NSLocalizedString("You must have at least one active address", comment: "")
        static let  BC_STRING_EXTENDED_PUBLIC_KEY_DETAIL_HEADER_TITLE = NSLocalizedString("Your xPub is an advanced feature that contains all of your public addresses.", comment: "")
        static let  BC_STRING_COPY_XPUB = NSLocalizedString("Copy xPub", comment: "")
        static let  BC_STRING_IMPORTED_PRIVATE_KEY_TO_OTHER_ADDRESS_ARGUMENT = NSLocalizedString("You've successfully imported the private key for ​the address %@, and you can now spend from it. If you want to spend from this address, make sure you scan the correct private key.", comment: "")
        static let  BC_STRING_VERIFICATION_EMAIL_SENT_TO_ARGUMENT = NSLocalizedString("Verification email has been sent to %@.", comment: "")
        static let  BC_STRING_PLEASE_CHECK_AND_CLICK_EMAIL_VERIFICATION_LINK = NSLocalizedString("Please check your email and click on the verification link.", comment: "")
        static let  BC_STRING_ERROR_PLEASE_REFRESH_PAIRING_CODE = NSLocalizedString("Please refresh the pairing code and try again.", comment: "")
        
        static let  BC_STRING_NOT_NOW = NSLocalizedString("Not Now", comment: "")
        static let  BC_STRING_ILL_DO_THIS_LATER = NSLocalizedString("I'll do this later", comment: "")
        static let  BC_STRING_PRIVATE_KEY_NEEDED_MESSAGE_ARGUMENT = NSLocalizedString("This action requires the private key for the Bitcoin address %@. Please scan the QR code.", comment: "")
        static let  BC_STRING_ENTER_ARGUMENT_AMOUNT = NSLocalizedString("Enter %@ amount", comment: "")
        static let  BC_STRING_RETRIEVING_RECOMMENDED_FEE = NSLocalizedString("Retrieving recommended fee", comment: "")
        static let  BC_STRING_FEE_HIGHER_THAN_RECOMMENDED_ARGUMENT_SUGGESTED_ARGUMENT = NSLocalizedString("You specified an unusually high transaction fee of %@. Even if you lower the fee to %@, you can expect the transaction to confirm within the next 10 minutes (one block).", comment: "")
        static let  BC_STRING_FEE_LOWER_THAN_RECOMMENDED_ARGUMENT_SUGGESTED_ARGUMENT = NSLocalizedString("You specified an exceptionally small transaction fee of %@. Your transaction may be stuck and possibly never be confirmed. To increase the likelihood for your transaction to confirm within approximately one hour (six blocks), we strongly recommend a fee of no less than %@.", comment: "")
        static let  BC_STRING_FEE_LOWER_THAN_RECOMMENDED_ARGUMENT_MUST_LOWER_AMOUNT_SUGGESTED_FEE_ARGUMENT_SUGGESTED_AMOUNT_ARGUMENT = NSLocalizedString("You specified an exceptionally small transaction fee of %@. Your transaction may become stuck and possibly never confirm. To increase the likelihood for your transaction to confirm within approximately one hour (six blocks), we strongly recommend a fee of no less than %@. Since you don’t have sufficient funds, that means the Send amount will also have to be lowered to %@.", comment: "")
        static let  BC_STRING_INCREASE_FEE = NSLocalizedString("Increase fee", comment: "")
        static let  BC_STRING_LOWER_FEE = NSLocalizedString("Lower fee", comment: "")
        static let  BC_STRING_KEEP_HIGHER_FEE = NSLocalizedString("Keep higher fee", comment: "")
        static let  BC_STRING_KEEP_LOWER_FEE = NSLocalizedString("Keep lower fee", comment: "")
        static let  BC_STRING_USE_RECOMMENDED_VALUES = NSLocalizedString("Use recommended values", comment: "")
        static let  BC_STRING_PLEASE_LOWER_CUSTOM_FEE = NSLocalizedString("Please lower the fee to an amount that is less than your balance", comment: "")
        static let  BC_STRING_SURGE_OCCURRING_TITLE = NSLocalizedString("Surge Occurring", comment: "")
        static let  BC_STRING_SURGE_OCCURRING_MESSAGE = NSLocalizedString("The Bitcoin mining network is currently experiencing a high volume of activity, resulting in recommended fees that are higher than usual.", comment: "")
        static let  BC_STRING_FEE_INFORMATION_TITLE = NSLocalizedString("Transaction Fees", comment: "")
        static let  BC_STRING_FEE_INFORMATION_MESSAGE = NSLocalizedString("Transaction fees impact how quickly the mining network will confirm your transactions, and depend on the current network conditions.", comment: "")
        static let  BC_STRING_FEE_INFORMATION_MESSAGE_APPEND_REGULAR_SEND = NSLocalizedString(" We recommend the fee shown for the transaction at this time.", comment: "")
        static let  BC_STRING_FEE_INFORMATION_DUST = NSLocalizedString("This transaction requires a higher fee for dust consumption due to the small amount of change to be returned.", comment: "")
        static let  BC_STRING_FEE_INFORMATION_MESSAGE_ETHER = NSLocalizedString("Miners receive this fee to process this transaction.", comment: "")
        static let  BC_STRING_TRANSACTION_DESCRIPTION_PLACEHOLDER = NSLocalizedString("What's this for?", comment: "")
        static let  BC_STRING_NO_DESCRIPTION = NSLocalizedString("No description", comment: "")
        static let  BC_STRING_WHATS_THIS = NSLocalizedString("What's this?", comment: "")
        static let  BC_STRING_BLOCKCHAIN_ALL_RIGHTS_RESERVED = NSLocalizedString("All rights reserved.", comment: "")
        static let  BC_STRING_RATE_US = NSLocalizedString("Rate us", comment: "")
        static let  BC_STRING_ERROR_SAVING_WALLET_CHECK_FOR_OTHER_DEVICES = NSLocalizedString("An error occurred while saving your changes. Please make sure you are not logged into your wallet on another device.", comment: "")
        static let  BC_STRING_ADDRESS_ALREADY_USED_PLEASE_LOGIN = NSLocalizedString("This address has already been used. Please login.", comment: "")
        static let  BC_STRING_PLEASE_LOGIN_TO_LOAD_MORE_ADDRESSES = NSLocalizedString("Please login to load more addresses.", comment: "")
        static let  BC_STRING_ERROR_TICKER = NSLocalizedString("An error occurred while retrieving currency conversion rates. Please try again later.", comment: "")
        static let  BC_STRING_DESCRIPTION = NSLocalizedString("Description", comment: "")
        static let  BC_STRING_DETAILS = NSLocalizedString("Details", comment: "")
        static let  BC_STRING_VALUE_WHEN_SENT_ARGUMENT = NSLocalizedString("Value when sent: %@", comment: "")
        static let  BC_STRING_VALUE_WHEN_RECEIVED_ARGUMENT = NSLocalizedString("Value when received: %@", comment: "")
        static let  BC_STRING_STATUS = NSLocalizedString("Status", comment: "")
        static let  BC_STRING_CONFIRMED = NSLocalizedString("Confirmed", comment: "")
        static let  BC_STRING_PENDING_ARGUMENT_CONFIRMATIONS = NSLocalizedString("Pending (%@ Confirmations)", comment: "")
        static let  BC_STRING_TRANSACTION_FEE_ARGUMENT = NSLocalizedString("Transaction fee: %@", comment: "")
        static let  BC_STRING_PENDING = NSLocalizedString("Pending", comment: "")
        static let  BC_STRING_DOUBLE_SPEND_WARNING = NSLocalizedString("May be at risk for a double spend.", comment: "")
        static let  BC_STRING_ARGUMENT_RECIPIENTS = NSLocalizedString("%lu Recipients", comment: "")
        static let  BC_STRING_TO = NSLocalizedString("To", comment: "")
        static let  BC_STRING_DATE = NSLocalizedString("Date", comment: "")
        static let  BC_STRING_FROM = NSLocalizedString("From", comment: "")
        static let  BC_STRING_ERROR_GETTING_FIAT_AT_TIME = NSLocalizedString("Could not get value when sent - please check your internet connection and try again.", comment: "")
        static let  BC_STRING_COULD_NOT_FIND_TRANSACTION_ARGUMENT = NSLocalizedString("Could not find transaction with hash %@ when reloading data", comment: "")
        static let  BC_STRING_RECIPIENTS = NSLocalizedString("Recipients", comment: "")
        static let  BC_STRING_US_DOLLAR = NSLocalizedString("U.S. Dollar", comment: "")
        static let  BC_STRING_EURO = NSLocalizedString("Euro", comment: "")
        static let  BC_STRING_ICELANDIC_KRONA = NSLocalizedString("lcelandic Króna", comment: "")
        static let  BC_STRING_HONG_KONG_DOLLAR = NSLocalizedString("Hong Kong Dollar", comment: "")
        static let  BC_STRING_NEW_TAIWAN_DOLLAR = NSLocalizedString("New Taiwan Dollar", comment: "")
        static let  BC_STRING_SWISS_FRANC = NSLocalizedString("Swiss Franc", comment: "")
        static let  BC_STRING_DANISH_KRONE = NSLocalizedString("Danish Krone", comment: "")
        static let  BC_STRING_CHILEAN_PESO = NSLocalizedString("Chilean Peso", comment: "")
        static let  BC_STRING_CANADIAN_DOLLAR = NSLocalizedString("Canadian Dollar", comment: "")
        static let  BC_STRING_INDIAN_RUPEE = NSLocalizedString("Indian Rupee", comment: "")
        static let  BC_STRING_CHINESE_YUAN = NSLocalizedString("Chinese Yuan", comment: "")
        static let  BC_STRING_THAI_BAHT = NSLocalizedString("Thai Baht",  comment: "")
        static let  BC_STRING_AUSTRALIAN_DOLLAR = NSLocalizedString("Australian Dollar", comment: "")
        static let  BC_STRING_SINGAPORE_DOLLAR = NSLocalizedString("Singapore Dollar", comment: "")
        static let  BC_STRING_SOUTH_KOREAN_WON = NSLocalizedString("South Korean Won", comment: "")
        static let  BC_STRING_JAPANESE_YEN = NSLocalizedString("Japanese Yen", comment: "")
        static let  BC_STRING_POLISH_ZLOTY = NSLocalizedString("Polish Zloty", comment: "")
        static let  BC_STRING_GREAT_BRITISH_POUND = NSLocalizedString("Great British Pound", comment: "")
        static let  BC_STRING_SWEDISH_KRONA = NSLocalizedString("Swedish Krona", comment: "")
        static let  BC_STRING_NEW_ZEALAND_DOLLAR = NSLocalizedString("New Zealand Dollar", comment: "")
        static let  BC_STRING_BRAZIL_REAL = NSLocalizedString("Brazil Real", comment: "")
        static let  BC_STRING_RUSSIAN_RUBLE = NSLocalizedString("Russian Ruble", comment: "")
        static let  BC_STRING_NO_TRANSACTIONS_TITLE = NSLocalizedString("No Transactions", comment: "")
        static let  BC_STRING_NO_TRANSACTIONS_TEXT_BITCOIN = NSLocalizedString("Transactions occur when you send and request bitcoin.", comment: "")
        static let  BC_STRING_NO_TRANSACTIONS_TEXT_ETHER = NSLocalizedString("Transactions occur when you send and request ether.", comment: "")
        static let  BC_STRING_NO_TRANSACTIONS_TEXT_BITCOIN_CASH = NSLocalizedString("Transactions occur when you send and request bitcoin cash.", comment: "")
        static let  BC_STRING_YOUR_TRANSACTIONS = NSLocalizedString("Your Transactions", comment: "")
        static let  BC_STRING_VIEW_ON_URL_ARGUMENT = NSLocalizedString("View on", comment: "")
        static let  BC_STRING_BACKUP_COMPLETE = NSLocalizedString("Backup Complete", comment: "")
        static let  BC_STRING_BACKUP_COMPLETED_EXPLANATION = NSLocalizedString("Use your Recovery Phrase to restore your funds in case of a lost password.  Anyone with access to your Recovery Phrase can access your funds, so keep it offline somewhere safe and secure.", comment: "")
        static let  BC_STRING_BACKUP_NEEDED_BODY_TEXT_ONE = NSLocalizedString("The following 12 word Recovery Phrase will give you access to your funds in case you lose your password.", comment: "")
        static let  BC_STRING_BACKUP_NEEDED_BODY_TEXT_TWO = NSLocalizedString("Be sure to write down your phrase on a piece of paper and keep it somewhere safe and secure.", comment: "")
        static let  BC_STRING_BACKUP_WORDS_INSTRUCTIONS = NSLocalizedString("Write down the following 12 word Recovery Phrase exactly as they appear and in this order:", comment: "")
        static let  BC_STRING_BACKUP_PREVIOUS = NSLocalizedString("PREVIOUS", comment: "")
        static let  BC_STRING_BACKUP_NEXT = NSLocalizedString("NEXT", comment: "")
        static let  BC_STRING_BACKUP_AGAIN = NSLocalizedString("BACKUP AGAIN", comment: "")
        static let  BC_STRING_TRANSFER_ALL = NSLocalizedString("Transfer all", comment: "")
        static let  BC_STRING_TRANSFER_IMPORTED_ADDRESSES = NSLocalizedString("Transfer imported addresses?", comment: "")
        static let  BC_STRING_TRANSFER_ALL_BACKUP = NSLocalizedString("Imported addresses are not backed up by your Recovery Phrase. To secure these funds, we recommend transferring these balances to include in your backup.", comment: "")
        static let  BC_STRING_BE_YOUR_OWN_BANK = NSLocalizedString("Be your own bank", comment: "")
        static let  BC_STRING_WELCOME_MESSAGE_ONE = NSLocalizedString ("Welcome to Blockchain", comment: "")
        static let  BC_STRING_WELCOME_MESSAGE_TWO = NSLocalizedString ("Securely store bitcoin", comment: "")
        static let  BC_STRING_WELCOME_MESSAGE_THREE = NSLocalizedString ("Seamlessly transact with others around the world", comment: "")
        static let  BC_STRING_OVERVIEW_MARKET_PRICE_TITLE = NSLocalizedString("Current Price", comment: "")
        static let  BC_STRING_OVERVIEW_MARKET_PRICE_DESCRIPTION = NSLocalizedString ("We work with exchange partners all over the world, so you can buy and sell bitcoin directly from your wallet.", comment: "")
        static let  BC_STRING_OVERVIEW_REQUEST_FUNDS_TITLE = NSLocalizedString("Request Funds", comment: "")
        static let  BC_STRING_OVERVIEW_REQUEST_FUNDS_DESCRIPTION = NSLocalizedString ("Send your wallet address to a friend to request funds. An address is a string of random letters and numbers that change for each transaction.", comment: "")
        static let  BC_STRING_OVERVIEW_QR_CODES_TITLE = NSLocalizedString("QR Codes", comment: "")
        static let  BC_STRING_OVERVIEW_QR_CODES_DESCRIPTION = NSLocalizedString("An address can also be shown as a QR code. Scan a friend's QR code to quickly capture their wallet address.", comment: "")
        static let  BC_STRING_OVERVIEW_COMPLETE_TITLE = NSLocalizedString("That's it for now!", comment: "")
        static let  BC_STRING_OVERVIEW_COMPLETE_DESCRIPTION = NSLocalizedString("We'll keep you up-to-date here with recommendations and new features.", comment: "")
        static let  BC_STRING_START_OVER = NSLocalizedString("Start Over", comment: "")
        static let  BC_STRING_OPEN_MAIL = NSLocalizedString("Open Mail", comment: "")
        static let  BC_STRING_SCAN_ADDRESS = NSLocalizedString("Scan Address", comment: "")
        static let  BC_STRING_SKIP_ALL = NSLocalizedString("Skip All", comment: "")
        static let  BC_STRING_GET_BITCOIN = NSLocalizedString("Get Bitcoin", comment: "")
        static let  BC_STRING_GET_ETHER = NSLocalizedString("Get Ether", comment: "")
        static let  BC_STRING_REQUEST_ETHER = NSLocalizedString("Request Ether", comment: "")
        static let  BC_STRING_GET_BITCOIN_CASH = NSLocalizedString("Get Bitcoin Cash", comment: "")
        static let  BC_STRING_REQUEST_BITCOIN_CASH = NSLocalizedString("Request Bitcoin Cash", comment: "")
        static let  BC_STRING_OVERVIEW = NSLocalizedString("Overview", comment: "")
        static let  BC_STRING_DASHBOARD = NSLocalizedString("Dashboard", comment: "")
        static let  BC_STRING_ENABLED_EXCLAMATION = NSLocalizedString("Enabled!", comment: "")
        static let  BC_STRING_CUSTOM = NSLocalizedString("Custom", comment: "")
        static let  BC_STRING_ADVANCED_USERS_ONLY = NSLocalizedString("Advanced users only", comment: "")
        static let  BC_STRING_GREATER_THAN_ONE_HOUR = NSLocalizedString("1+ hour", comment: "")
        static let  BC_STRING_PRIORITY = NSLocalizedString("Priority", comment: "")
        static let  BC_STRING_LESS_THAN_ONE_HOUR = NSLocalizedString("~0-60 min", comment: "")
        static let  BC_STRING_SATOSHI_PER_BYTE = NSLocalizedString("Satoshi per byte", comment: "")
        static let  BC_STRING_SATOSHI_PER_BYTE_ABBREVIATED = NSLocalizedString("sat/b", comment: "")
        static let  BC_STRING_HIGH_FEE_NOT_NECESSARY = NSLocalizedString("High fee not necessary", comment: "")
        static let  BC_STRING_LOW_FEE_NOT_RECOMMENDED = NSLocalizedString("Low fee not recommended", comment: "")
        static let  BC_STRING_NOT_ENOUGH_FUNDS_TO_USE_FEE = NSLocalizedString("You do not have enough funds to use this fee.", comment: "")
        static let  BC_STRING_CUSTOM_FEE_WARNING = NSLocalizedString("This feature is recommended for advanced users only. By choosing a custom fee, you risk overpaying or your transaction may get stuck.", comment: "")
        static let  BC_STRING_AVAILABLE_NOW_TITLE = NSLocalizedString("Available now", comment: "")
        static let  BC_STRING_BUY_SELL_NOT_SUPPORTED_IOS_8_WEB_LOGIN = NSLocalizedString("Mobile Buy & Sell is supported for iOS 9 and up. Please run a software update or login at login.blockchain.com on your computer.", comment: "")
        static let  BC_STRING_LOG_IN_TO_WEB_WALLET = NSLocalizedString("Log in to Web Wallet", comment: "")
        static let  BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_ONE = NSLocalizedString("Go to login.blockchain.com on your computer.", comment: "")
        static let  BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_TWO = NSLocalizedString("Select Log in via mobile.", comment: "")
        static let  BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_THREE = NSLocalizedString("Using your computer's camera, scan the QR code below.", comment: "")
        static let  BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_HIDDEN = NSLocalizedString("Keep this QR code hidden until you're ready.", comment: "")
        static let  BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_SHOWN_ONE = NSLocalizedString("Keep this QR code safe!", comment: "")
        static let  BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_SHOWN_TWO = NSLocalizedString("Do not share it with others.", comment: "")
        static let  BC_STRING_SHOW_QR_CODE = NSLocalizedString("Show QR Code", comment: "")
        static let  BC_STRING_HIDE_QR_CODE = NSLocalizedString("Hide QR Code", comment: "")
        static let  BC_STRING_DAY = NSLocalizedString("Day", comment: "")
        static let  BC_STRING_WEEK = NSLocalizedString("Week", comment: "")
        static let  BC_STRING_MONTH = NSLocalizedString("Month", comment: "")
        static let  BC_STRING_YEAR = NSLocalizedString("Year", comment: "")
        static let  BC_STRING_ALL = NSLocalizedString("All", comment: "")
        static let  BC_STRING_AT = NSLocalizedString("at", comment: "")
        static let  BC_STRING_CONTRACT_ADDRESSES_NOT_SUPPORTED_TITLE = NSLocalizedString("Contract addresses are not supported.", comment: "")
        static let  BC_STRING_CONTRACT_ADDRESSES_NOT_SUPPORTED_MESSAGE = NSLocalizedString("At the moment we only support ETH. You cannot receive REP, ICN, GNT, GNO, DGD, BCP.", comment: "")
        
        static let  BC_STRING_NOW_SUPPORTING_ETHER_TITLE = NSLocalizedString("Now supporting Ether", comment: "")
        static let  BC_STRING_NOW_SUPPORTING_ETHER_DESCRIPTION = NSLocalizedString("You asked, we listened. We’re excited to announce that your Blockchain wallet will now allow you to seamlessly send and receive ether!", comment: "")
        static let  BC_STRING_GET_STARTED_WITH_ETHER = NSLocalizedString("Get Started with Ether", comment: "")
        static let  BC_STRING_EXCHANGE = NSLocalizedString("Exchange", comment: "")
        static let  BC_STRING_NEW_EXCHANGE = NSLocalizedString("New Exchange", comment: "")
        static let  BC_STRING_USE_MINIMUM = NSLocalizedString("Use minimum", comment: "")
        static let  BC_STRING_USE_MAXIMUM = NSLocalizedString("Use maximum", comment: "")
        static let  BC_STRING_EXCHANGE_TITLE_SENDING_FUNDS = NSLocalizedString("Sending Funds", comment: "")
        static let  BC_STRING_EXCHANGE_DESCRIPTION_SENDING_FUNDS = NSLocalizedString("Thanks for placing your trade!  Exchange trades can take up to two hours, and you can keep track of your trade’s progress in the Order History section.", comment: "")
        static let  BC_STRING_IN_PROGRESS = NSLocalizedString("In Progress", comment: "")
        static let  BC_STRING_EXCHANGE_DESCRIPTION_IN_PROGRESS = NSLocalizedString("Exchanges can take up to two hours, you can keep track of your exchange progress in the Order History. Once the trade is complete, your ether will arrive in your wallet.", comment: "")
        static let  BC_STRING_EXCHANGE_DESCRIPTION_CANCELED = NSLocalizedString("Your trade has been canceled. Please return to the exchange tab to start your trade again.", comment: "")
        static let  BC_STRING_FAILED = NSLocalizedString("Failed", comment: "")
        static let  BC_STRING_EXCHANGE_TITLE_REFUNDED = NSLocalizedString("Trade Refunded", comment: "")
        static let  BC_STRING_EXCHANGE_DESCRIPTION_FAILED = NSLocalizedString("This trade has failed. Any funds sent from your wallet will be returned minus the transaction fee. Please return to the exchange tab to start a new trade.", comment: "")
        static let  BC_STRING_EXCHANGE_DESCRIPTION_EXPIRED = NSLocalizedString("Your trade has expired. Please return to the exchange tab to start a new trade.", comment: "")
        static let  BC_STRING_EXCHANGE_CARD_DESCRIPTION = NSLocalizedString("You can now exchange your bitcoin for ether and vice versa directly from your Blockchain wallet!", comment: "")
        static let  BC_STRING_ARGUMENT_TO_DEPOSIT = NSLocalizedString("%@ to Deposit", comment: "")
        static let  BC_STRING_ARGUMENT_TO_BE_RECEIVED = NSLocalizedString("%@ to be Received", comment: "")
        static let  BC_STRING_EXCHANGE_RATE = NSLocalizedString("Exchange Rate", comment: "")
        static let  BC_STRING_TRANSACTION_FEE = NSLocalizedString("Transaction Fee", comment: "")
        static let  BC_STRING_NETWORK_TRANSACTION_FEE = NSLocalizedString("Network Transaction Fee", comment: "")
        static let  BC_STRING_SHAPESHIFT_WITHDRAWAL_FEE = NSLocalizedString("ShapeShift Withdrawal Fee", comment: "")
        static let  BC_STRING_AGREE_TO_SHAPESHIFT = NSLocalizedString("Agree to ShapeShift", comment: "")
        static let  BC_STRING_TERMS_AND_CONDITIONS = NSLocalizedString("terms and conditions", comment: "")
        static let  BC_STRING_EXCHANGE_IN_PROGRESS = NSLocalizedString("Exchange In Progress", comment: "")
        static let  BC_STRING_EXCHANGE_COMPLETED = NSLocalizedString("Exchange Completed", comment: "")
        static let  BC_STRING_GET_STARTED = NSLocalizedString("Get started", comment: "")
        static let  BC_STRING_BELOW_MINIMUM_LIMIT = NSLocalizedString("Below minimum limit", comment: "")
        static let  BC_STRING_ABOVE_MAXIMUM_LIMIT = NSLocalizedString("Above maximum limit", comment: "")
        static let  BC_STRING_NOT_ENOUGH_TO_EXCHANGE = NSLocalizedString("Not enough to exchange", comment: "")
        static let  BC_STRING_EXCHANGE_ORDER_ID = NSLocalizedString("Order ID", comment: "")
        static let  BC_STRING_TOTAL_ARGUMENT_SPENT = NSLocalizedString("Total %@ spent", comment: "")
        static let  BC_STRING_GETTING_QUOTE = NSLocalizedString("Getting quote", comment: "")
        static let  BC_STRING_CONFIRMING = NSLocalizedString("Confirming", comment: "")
        static let  BC_STRING_COMPLETE = NSLocalizedString("Complete", comment: "")
        static let  BC_STRING_QUOTE_EXIRES_IN_ARGUMENT = NSLocalizedString("Quote expires in %@", comment: "")
        static let  BC_STRING_STEP_ARGUMENT_OF_ARGUMENT = NSLocalizedString("Step %d of %d", comment: "")
        static let  BC_STRING_SELECT_YOUR_STATE = NSLocalizedString("Select your State:", comment: "")
        static let  BC_STRING_SELECT_STATE = NSLocalizedString("Select State", comment: "")
        static let  BC_STRING_EXCHANGE_NOT_AVAILABLE_TITLE = NSLocalizedString("Not Available", comment: "")
        static let  BC_STRING_EXCHANGE_NOT_AVAILABLE_MESSAGE = NSLocalizedString("Exchanging coins is not yet available in your state. We’ll be rolling out more states soon.", comment: "")
        static let  BC_STRING_ERROR_GETTING_BALANCE_ARGUMENT_ASSET_ARGUMENT_MESSAGE = NSLocalizedString("An error occurred when getting your %@ balance. Please try again later. Details: %@", comment: "")
        static let  BC_STRING_ERROR_GETTING_APPROXIMATE_QUOTE_ARGUMENT_MESSAGE = NSLocalizedString("An error occurred when getting an approximate quote. Please try again later. Details: %@", comment: "")
        static let  BC_STRING_DEPOSITED_TO_SHAPESHIFT = NSLocalizedString("Deposited to ShapeShift", comment: "")
        static let  BC_STRING_RECEIVED_FROM_SHAPESHIFT = NSLocalizedString("Received from ShapeShift", comment: "")
        static let  BC_STRING_ORDER_HISTORY = NSLocalizedString("Order History", comment: "")
        static let  BC_STRING_INCOMING = NSLocalizedString("Incoming", comment: "")
        static let  BC_STRING_TRADE_EXPIRED_TITLE = NSLocalizedString("Trade Expired", comment: "")
        static let  BC_STRING_TRADE_EXPIRED_MESSAGE = NSLocalizedString("Your trade has expired. Please return to the Exchange page to start your trade again.", comment: "")
        static let  BC_STRING_NO_FUNDS_TO_EXCHANGE_TITLE = NSLocalizedString("No Funds to Exchange", comment: "")
        static let  BC_STRING_NO_FUNDS_TO_EXCHANGE_MESSAGE = NSLocalizedString("You have no funds to exchange. Why not get started by receiving some funds?", comment: "")
        static let  BC_STRING_SELECT_ARGUMENT_WALLET = NSLocalizedString("Select other %@ Wallet", comment: "")
        static let  BC_STRING_ARGUMENT_NEEDED_TO_EXCHANGE = NSLocalizedString("%@ needed to exchange", comment: "")
        static let  BC_STRING_FAILED_TO_LOAD_EXCHANGE_DATA = NSLocalizedString("Failed to load exchange data", comment: "")
        static let  BC_STRING_PRICE = NSLocalizedString("Price", comment: "")
        static let  BC_STRING_SEE_CHARTS = NSLocalizedString("See charts", comment: "")
        static let  BC_STRING_ENTER_BITCOIN_CASH_ADDRESS_OR_SELECT = NSLocalizedString("Enter Bitcoin Cash address or select", comment: "")
        static let  BC_STRING_BITCOIN_CASH_WARNING_CONFIRM_VALID_ADDRESS_ONE = NSLocalizedString("Are you sure this is a bitcoin cash address?", comment: "")
        static let  BC_STRING_BITCOIN_CASH_WARNING_CONFIRM_VALID_ADDRESS_TWO = NSLocalizedString("Sending funds to a bitcoin address by accident will result in loss of funds.", comment: "")
        static let  BC_STRING_COPY_WARNING_TEXT = NSLocalizedString("Copy this receive address to the clipboard? If so, be advised that other applications may be able to look at this information.", comment: "")
    }
    
    static let verified = NSLocalizedString("Verified", comment: "")
    static let unverified = NSLocalizedString("Unverified", comment: "")
    static let verify = NSLocalizedString ("Verify", comment: "")
    static let beginNow = NSLocalizedString("Begin Now", comment: "")
    static let enterCode = NSLocalizedString ("Enter Verification Code", comment: "")
    static let tos = NSLocalizedString ("Terms of Service", comment: "")
    static let touchId = NSLocalizedString ("Touch ID", comment: "")
    static let faceId = NSLocalizedString ("Face ID", comment: "")
    static let disable = NSLocalizedString ("Disable", comment: "")
    static let disabled = NSLocalizedString ("Disabled", comment: "")
    static let unknown = NSLocalizedString ("Unknown", comment: "")
    static let unconfirmed = NSLocalizedString("Unconfirmed", comment: "")
    static let enable = NSLocalizedString ("Enable", comment: "")
    static let changeEmail = NSLocalizedString ("Change Email", comment: "")
    static let addEmail = NSLocalizedString ("Add Email", comment: "")
    static let newEmail = NSLocalizedString ("New Email Address", comment: "")
    static let settings = NSLocalizedString ("Settings", comment: "")
    static let balances = NSLocalizedString(
        "Balances",
        comment: "Generic translation, may be used in multiple places."
    )

    static let more = NSLocalizedString("More", comment: "")
    static let privacyPolicy = NSLocalizedString("Privacy Policy", comment: "")
    static let information = NSLocalizedString("Information", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    static let continueString = NSLocalizedString("Continue", comment: "")
    static let okString = NSLocalizedString("OK", comment: "")
    static let success = NSLocalizedString("Success", comment: "")
    static let syncingWallet = NSLocalizedString("Syncing Wallet", comment: "")
    static let tryAgain = NSLocalizedString("Try again", comment: "")
    static let verifying = NSLocalizedString ("Verifying", comment: "")
    static let openArg = NSLocalizedString("Open %@", comment: "")
    static let youWillBeLeavingTheApp = NSLocalizedString("You will be leaving the app.", comment: "")
    static let openMailApp = NSLocalizedString("Open Mail App", comment: "")
    static let goToSettings = NSLocalizedString("Go to Settings", comment: "")
    static let swipeReceive = NSLocalizedString("Swipe to Receive", comment: "")
    static let twostep = NSLocalizedString("Enable 2-Step", comment: "")
    static let localCurrency = NSLocalizedString("Local Currency", comment: "")
    static let scanQRCode = NSLocalizedString("Scan QR Code", comment: "")
    static let scanPairingCode = NSLocalizedString("Scan Pairing Code", comment: " ")
    static let parsingPairingCode = NSLocalizedString("Parsing Pairing Code", comment: " ")
    static let invalidPairingCode = NSLocalizedString("Invalid Pairing Code", comment: " ")
    
    static let dontShowAgain = NSLocalizedString(
        "Don’t show again",
        comment: "Text displayed to the user when an action has the option to not be asked again."
    )
    static let myEtherWallet = NSLocalizedString(
        "My Ether Wallet",
        comment: "The default name of the ether wallet."
    )
    static let loading = NSLocalizedString(
        "Loading",
        comment: "Text displayed when there is an asynchronous action that needs to complete before the user can take further action."
    )
    static let copiedToClipboard = NSLocalizedString(
        "Copied to clipboard",
        comment: "Text displayed when a user has tapped on an item to copy its text."
    )

    struct Errors {
        static let genericError = NSLocalizedString(
            "An error occured. Please try again.",
            comment: "Generic error message displayed when an error occurs."
        )
        static let error = NSLocalizedString("Error", comment: "")
        static let pleaseTryAgain = NSLocalizedString("Please try again", comment: "message shown when an error occurs and the user should attempt the last action again")
        static let loadingSettings = NSLocalizedString("loading Settings", comment: "")
        static let errorLoadingWallet = NSLocalizedString("Unable to load wallet due to no server response. You may be offline or Blockchain is experiencing difficulties. Please try again later.", comment: "")
        static let cannotOpenURLArg = NSLocalizedString("Cannot open URL %@", comment: "")
        static let unsafeDeviceWarningMessage = NSLocalizedString("Your device appears to be jailbroken. The security of your wallet may be compromised.", comment: "")
        static let twoStep = NSLocalizedString("An error occurred while changing 2-Step verification.", comment: "")
        static let noInternetConnection = NSLocalizedString("No internet connection.", comment: "")
        static let noInternetConnectionPleaseCheckNetwork = NSLocalizedString("No internet connection available. Please check your network settings.", comment: "")
        static let warning = NSLocalizedString("Warning", comment: "")
        static let checkConnection = NSLocalizedString("Please check your internet connection.", comment: "")
        static let timedOut = NSLocalizedString("Connection timed out. Please check your internet connection.", comment: "")
        static let siteMaintenanceError = NSLocalizedString("Blockchain’s servers are currently under maintenance. Please try again later", comment: "")
        static let invalidServerResponse = NSLocalizedString("Invalid server response. Please try again later.", comment: "")
        static let invalidStatusCodeReturned = NSLocalizedString("Invalid Status Code Returned %@", comment: "")
        static let requestFailedCheckConnection = NSLocalizedString("Request failed. Please check your internet connection.", comment: "")
        static let errorLoadingWalletIdentifierFromKeychain = NSLocalizedString("An error was encountered retrieving your wallet identifier from the keychain. Please close the application and try again.", comment: "")
        static let cameraAccessDenied = NSLocalizedString("Camera Access Denied", comment: "")
        static let cameraAccessDeniedMessage = NSLocalizedString("Blockchain does not have access to the camera. To enable access, go to your device Settings.", comment: "")
        static let nameAlreadyInUse = NSLocalizedString("This name is already in use. Please choose a different name.", comment: "")
        static let failedToRetrieveDevice = NSLocalizedString("Unable to retrieve the input device.", comment: "AVCaptureDeviceError: failedToRetrieveDevice")
        static let inputError = NSLocalizedString("There was an error with the device input.", comment: "AVCaptureDeviceError: inputError")
        static let noEmail = NSLocalizedString("Please provide an email address.", comment: "")
        static let differentEmail = NSLocalizedString("New email must be different", comment: "")
        static let failedToValidateCertificateTitle = NSLocalizedString("Failed to validate server certificate", comment: "Message shown when the app has detected a possible man-in-the-middle attack.")
        static let failedToValidateCertificateMessage = NSLocalizedString(
            """
            A connection cannot be established because the server certificate could not be validated. Please check your network settings and ensure that you are using a secure connection.
            """, comment: "Message shown when the app has detected a possible man-in-the-middle attack.")
        static let notEnoughXForFees = NSLocalizedString("Not enough %@ for fees", comment: "Message shown when the user has attempted to send more funds than the user can spend (input amount plus fees)")
        static let balancesGeneric = NSLocalizedString("We are experiencing a service issue that may affect displayed balances. Don't worry, your funds are safe.", comment: "Message shown when an error occurs while fetching balance or transaction history")
    }

    struct Authentication {
        static let recoveryPhrase = NSLocalizedString("Recovery Phrase", comment: "")
        static let twoStepSMS = NSLocalizedString("2-Step has been enabled for SMS", comment: "")
        static let twoStepOff = NSLocalizedString("2-Step has been disabled.", comment: "")
        static let checkLink = NSLocalizedString("Please check your email and click on the verification link.", comment: "")
        static let googleAuth = NSLocalizedString("Google Authenticator", comment: "")
        static let yubiKey = NSLocalizedString("Yubi Key", comment: "")
        static let enableTwoStep = NSLocalizedString(
            """
            You can enable 2-step Verification via SMS on your mobile phone. In order to use other authentication methods instead, please login to our web wallet.
            """, comment: "")
        static let verifyEmail = NSLocalizedString("Please verify your email address first.", comment: "")
        static let resendVerificationEmail = NSLocalizedString("Resend verification email", comment: "")

        static let resendVerification = NSLocalizedString("Resend verification SMS", comment: "")
        static let enterVerification = NSLocalizedString("Enter your verification code", comment: "")
        static let errorDecryptingWallet = NSLocalizedString("An error occurred due to interruptions during PIN verification. Please close the app and try again.", comment: "")
        static let hasVerified = NSLocalizedString("Your mobile number has been verified.", comment: "")
        static let invalidSharedKey = NSLocalizedString("Invalid Shared Key", comment: "")
        static let didCreateNewWalletTitle = NSLocalizedString("Your wallet was successfully created.", comment: "")
        static let didCreateNewWalletMessage = NSLocalizedString("Before accessing your wallet, please choose a pin number to use to unlock your wallet. It’s important you remember this pin as it cannot be reset or changed without first unlocking the app.", comment: "")
        static let walletPairedSuccessfullyTitle = NSLocalizedString("Wallet Paired Successfully.", comment: "")
        static let walletPairedSuccessfullyMessage = NSLocalizedString("Before accessing your wallet, please choose a pin number to use to unlock your wallet. It’s important you remember this pin as it cannot be reset or changed without first unlocking the app.", comment: "")
        static let forgotPassword = NSLocalizedString("Forgot Password?", comment: "")
        static let passwordRequired = NSLocalizedString("Password Required", comment: "")
        static let downloadingWallet = NSLocalizedString("Downloading Wallet", comment: "")
        static let noPasswordEntered = NSLocalizedString("No Password Entered", comment: "")
        static let failedToLoadWallet = NSLocalizedString("Failed To Load Wallet", comment: "")
        static let failedToLoadWalletDetail = NSLocalizedString("An error was encountered loading your wallet. You may be offline or Blockchain is experiencing difficulties. Please close the application and try again later or re-pair your device.", comment: "")
        static let forgetWallet = NSLocalizedString("Forget Wallet", comment: "")
        static let forgetWalletDetail = NSLocalizedString("This will erase all wallet data on this device. Please confirm you have your wallet information saved elsewhere otherwise any bitcoin in this wallet will be inaccessible!!", comment: "")
        static let enterPassword = NSLocalizedString("Enter Password", comment: "")
        static let retryValidation = NSLocalizedString("Retry Validation", comment: "")
        static let manualPairing = NSLocalizedString("Manual Pairing", comment: "")
        static let invalidTwoFactorAuthenticationType = NSLocalizedString("Invalid two-factor authentication type", comment: "")
        static let manualPairingAuthorizationRequiredTitle = NSLocalizedString("Authorization Required", comment: "")
        static let manualPairingAuthorizationRequiredMessage = NSLocalizedString("Please check your email and authorize this log-in attempt. After doing so, please return here and try logging in again", comment: "")
        static let secondPasswordRequired = NSLocalizedString("Second Password Required", comment: "")
        static let etherSecondPasswordPrompt = NSLocalizedString("To use this service, we require you to enter your second password. You should only need to enter this once to set up your Ether wallet.", comment: "Text shown when a user whose wallet requires a second password needs to create an ether account to proceed")
        static let secondPasswordIncorrect = NSLocalizedString("Second Password Incorrect", comment: "")
        static let secondPasswordDefaultDescription = NSLocalizedString("This action requires the second password for your wallet. Please enter it below and press continue.", comment: "")
        static let privateKeyNeeded = NSLocalizedString("Private Key Needed", comment: "")
        static let privateKeyPasswordDefaultDescription = NSLocalizedString("The private key you are attempting to import is encrypted. Please enter the password below.", comment: "")
        static let password = NSLocalizedString("Password", comment: "")
    }

    struct Pin {
        static let revealAddress = NSLocalizedString(
        """
        Enable this option to reveal a receive address when you swipe left on the PIN screen, making
        receiving bitcoin even faster. Five addresses will be loaded consecutively, after which logging in is
        required to show new addresses.
        """, comment: "")

        static let genericError = NSLocalizedString(
            "An error occured. Please try again.",
            comment: "Fallback error for all other errors that may occur during the pin validation/change flow."
        )
        static let pinCodeCommonMessage = NSLocalizedString(
            "The PIN you have selected is extremely common and may be easily guessed by someone with access to your phone within 3 tries. Would you like to use this PIN anyway?",
            comment: "Error message displayed to the user when they enter a common pin and is asked if they would like to continue using that common pin or try another one."
        )
        static let newPinMustBeDifferent = NSLocalizedString(
            "New PIN must be different",
            comment: "Error message displayed to the user that they must enter a pin code that is different from their previous pin."
        )
        static let chooseAnotherPin = NSLocalizedString(
            "Please choose another PIN",
            comment: "Error message displayed to the user when they must enter another pin code."
        )

        static let incorrect = NSLocalizedString(
            "Incorrect PIN. Please retry.",
            comment: "Error message displayed when the entered pin is incorrect and the user should try to enter the pin code again."
        )
        static let cannotSaveInvalidWalletState = NSLocalizedString(
            "Cannot save PIN Code while wallet is not initialized or password is null",
            comment: "Error message displayed when the wallet is in an invalid state and the user tried to enter a new pin code."
        )
        static let responseKeyOrValueLengthZero = NSLocalizedString(
            "PIN Response Object key or value length 0",
            comment: "Error message displayed to the user when the pin-store endpoint is returning an invalid response."
        )
        static let validationCannotBeCompleted = NSLocalizedString(
            "PIN Validation cannot be completed. Please enter your wallet password manually.",
            comment: "Error message displayed when the user’s pin cannot be validated and instead they are prompted to enter their password."
        )
        static let incorrectUnknownError = NSLocalizedString(
            "PIN Code Incorrect. Unknown Error Message.",
            comment: "Error message displayed when the pin cannot be validated and the error is unknown."
        )
        static let responseSuccessLengthZero = NSLocalizedString(
            "PIN Response Object success length 0",
            comment: "Error message displayed to the user when the pin-store endpoint is returning an invalid response."
        )
        static let decryptedPasswordLengthZero = NSLocalizedString(
            "Decrypted PIN Password length 0",
            comment: "Error message displayed when the user’s decrypted password length is 0."
        )
        static let validationError = NSLocalizedString(
            "PIN Validation Error",
            comment: "Title of the error message displayed to the user when their PIN cannot be validated if it is correct."
        )
        static let validationErrorMessage = NSLocalizedString(
        """
        An error occurred validating your PIN code with the remote server. You may be offline or Blockchain may be experiencing difficulties. Would you like retry validation or instead enter your password manually?
        """, comment: "Error message displayed to the user when their PIN cannot be validated if it is correct."
        )
        static let pinsDoNotMatch = NSLocalizedString(
            "PINs do not match",
            comment: "Message presented to user when they enter an incorrect pin when confirming a pin."
        )
    }

    struct Biometrics {
        static let touchIDEnableInstructions = NSLocalizedString(
            "Touch ID is not enabled on this device. To enable Touch ID, go to Settings -> Touch ID & Passcode and add a fingerprint.",
            comment: "The error description for when the user is not enrolled in biometric authentication."
        )
        //: Biometry Authentication Errors (only available on iOS 11, possibly including newer versions)
        static let biometricsLockout = NSLocalizedString(
            "Unable to authenticate due to failing authentication too many times.",
            comment: "The error description for when the user has made too many failed authentication attempts using biometrics."
        )
        static let biometricsNotSupported = NSLocalizedString(
            "Unable to authenticate because the device does not support biometric authentication.",
            comment: "The error description for when the device does not support biometric authentication."
        )
        static let unableToUseBiometrics = NSLocalizedString(
            "Unable to use biometrics.",
            comment: "The error message displayed to the user upon failure to authenticate using biometrics."
        )
        static let biometryWarning = NSLocalizedString(
            "Enabling this feature will allow all users with a registered %@ fingerprint on this device to access to your wallet.",
            comment: "The message displayed in the alert view when the biometry switch is toggled in the settings view."
        )
        static let enableX = NSLocalizedString(
            "Enable %@",
            comment: "The title of the biometric authentication button in the wallet setup view. The value depends on the type of biometry."
        )
        static let authenticationReason = NSLocalizedString(
            "Authenticate to unlock your wallet",
            comment: "The app-provided reason for requesting authentication, which displays in the authentication dialog presented to the user."
        )
        static let genericError = NSLocalizedString(
            "Authentication Failed. Please try again.",
            comment: "Fallback error for all other errors that may occur during biometric authentication."
        )
        static let usePasscode = NSLocalizedString(
            "Use Passcode",
            comment: "Fallback title for when biometric authentication fails."
        )
        static let authenticationFailed = NSLocalizedString(
            "Authentication was not successful because the user failed to provide valid credentials.",
            comment: "The internal error description if biometric authentication fails because the user failed to provide valid credentials."
        )
        static let passcodeNotSet = NSLocalizedString(
            "Failed to Authenticate because a passcode has not been set on the device.",
            comment: "The internal error description if biometric authentication fails because no passcode has been set."
        )
        //: Deprecated Authentication Errors (remove once we stop supporting iOS >= 8.0 and iOS <= 11)
        static let touchIDLockout = NSLocalizedString(
            "Unable to Authenticate because there were too many failed Touch ID attempts. Passcode is required to unlock Touch ID",
            comment: "The error description for when the user has made too many failed authentication attempts using Touch ID."
        )
    }

    struct Onboarding {
        static let createNewWallet = NSLocalizedString("Create New Wallet", comment: "")
        static let termsOfServiceAndPrivacyPolicyNoticePrefix = NSLocalizedString("By creating a wallet you agree to Blockchain’s", comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they create a wallet")
        static let automaticPairing = NSLocalizedString("Automatic Pairing", comment: "")
        static let recoverFunds = NSLocalizedString("Recover Funds", comment: "")
        static let recoverFundsOnlyIfForgotCredentials = NSLocalizedString("You should always pair or login if you have access to your Wallet ID and password. Recovering your funds will create a new Wallet ID. Would you like to continue?", comment: "")
        static let askToUserOldWalletTitle = NSLocalizedString("We’ve detected a previous installation of Blockchain Wallet on your phone.", comment: "")
        static let askToUserOldWalletMessage = NSLocalizedString("Please choose from the options below.", comment: "")
        static let loginExistingWallet = NSLocalizedString("Login existing Wallet", comment: "")
        static let biometricInstructions = NSLocalizedString("Use %@ instead of PIN to authenticate Blockchain and access your wallet.", comment: "")
    }

    struct DeepLink {
        static let deepLinkUpdateTitle = NSLocalizedString(
            "Link requires app update",
            comment: "Title of alert shown if the deep link requires a newer version of the app."
        )
        static let deepLinkUpdateMessage = NSLocalizedString(
            "The link you have used is not supported on this version of the app. Please update the app to access this link.",
            comment: "Message of alert shown if the deep link requires a newer version of the app."
        )
        static let updateNow = NSLocalizedString(
            "Update Now",
            comment: "Action of alert shown if the deep link requires a newer version of the app."
        )
    }

    struct Dashboard {
        static let priceCharts = NSLocalizedString(
            "Price charts",
            comment: "The title of the balances label in the price chart view."
        )
        static let chartsError = NSLocalizedString(
            "An error occurred while retrieving the latest chart data. Please try again later.",
            comment: "The error message for when the method fetchChartDataForAsset fails."
        )
        static let bitcoinPrice = NSLocalizedString(
            "Bitcoin Price",
            comment: "The title of the Bitcoin price chart on the dashboard."
        )
        static let etherPrice = NSLocalizedString(
            "Ether Price",
            comment: "The title of the Ethereum price chart on the dashboard."
        )
        static let bitcoinCashPrice = NSLocalizedString(
            "Bitcoin Cash Price",
            comment: "The title of the Bitcoin Cash price chart on the dashboard."
        )
        static let stellarPrice = NSLocalizedString(
            "Stellar Price",
            comment: "The title of the Stellar price chart on the dashboard."
        )
        static let seeCharts = NSLocalizedString(
            "See Charts",
            comment: "The title of the action button in the price preview views."
        )
        static let activity = NSLocalizedString("Activity", comment: "Activity tab item")
        static let send = NSLocalizedString("Send", comment: "Send tab item")
        static let request = NSLocalizedString("Request", comment: "request tab item")
    }

    struct AnnouncementCards {
        static let registerAirdropSuccessTitle = NSLocalizedString(
            "You're All Set!",
            comment: "Title of an alert that notifies the user that airdrop registration has succeded"
        )
        static let registerAirdropSuccessDescription = NSLocalizedString(
            "Once your profile is approved for Gold, we will airdrop your free crypto into your Wallet.",
            comment: "Description of an alert that notifies the user that airdrop registration has succeded"
        )
        static let bottomSheetCoinifyInfoTitle = NSLocalizedString("More Info Needed", comment: "Title of an alert informing a user that personal information needs to be updated.")
        static let bottomSheetCoinifyInfoDescription = NSLocalizedString("To use Buy & Sell, we'll need you to update your profile. We'll airdrop at least $25 of XLM as a thank you when you do!", comment: "Description of an alert informing a user that personal information needs to be updated.")
        static let bottomSheetCoinifyInfoAction = NSLocalizedString("Get Free XLM", comment: "Action button title of an alert informing a user that personal information needs to be updated.")
        static let updateNow = NSLocalizedString("Update Now", comment: "Title of a button that a user can tap on to update their information")
        static let learnMore = NSLocalizedString("Learn More", comment: "Title of a button that a user can tap on to learn more about an announcement")
        static let bottomSheetPromptForKycTitle = NSLocalizedString(
            "Get Free XLM",
            comment: "Title of a bottom sheet alert prompting the user to complete KYC"
        )
        static let bottomSheetPromptForKycDescription = NSLocalizedString(
            "Complete your profile today and we will airdrop free Stellar (XLM) in your Wallet.",
            comment: "Description of a bottom sheet alert prompting the user to complete KYC"
        )
        static let bottomSheetPromptForKycAction = NSLocalizedString(
            "Get Free XLM",
            comment: "Action button title of a bottom sheet alert prompting the user to complete KYC"
        )
        static let bottomSheetPromptForAirdropRegistrationTitle = NSLocalizedString(
            "Claim Your Free Crypto",
            comment: "Title of a bottom sheet alert prompting the user to complete KYC"
        )
        static let bottomSheetPromptForAirdropRegistrationDescription = NSLocalizedString(
            "Tap the button to automatically receive free Stellar (XLM) once Gold level is unlocked.",
            comment: "Description of a bottom sheet alert prompting the user to complete KYC"
        )
        static let bottomSheetPromptForAirdropRegistrationAction = NSLocalizedString(
            "Claim Your XLM",
            comment: "Action button title of a bottom sheet alert prompting the user to complete KYC"
        )
        static let bottomSheetPromptForAirdropRegistrationCancel = NSLocalizedString(
            "Maybe Later",
            comment: "Cancel button title of a bottom sheet alert prompting the user to complete KYC"
        )
        static let cardCompleteProfileTitle = NSLocalizedString(
            "Complete Your Profile",
            comment: "Title of a bottom sheet alert prompting the user to complete KYC"
        )
        static let cardCompleteProfileDescription = NSLocalizedString(
            "Complete your Blockchain profile today and we'll airdrop XLM directly into your Wallet!",
            comment: "Description of a bottom sheet alert prompting the user to complete KYC"
        )
        static let cardCompleteProfileAction = NSLocalizedString(
            "Continue to Claim Your XLM",
            comment: "Button title of a bottom sheet alert prompting the user to complete KYC"
        )
        static let buySellCardTitle = NSLocalizedString("The wait is over", comment: "The title of the card.")
        static let continueKYCCardTitle = NSLocalizedString("Verify Your Identity", comment: "The title of the card.")
        static let verifyAndGetCrypto = NSLocalizedString("Verify & Get Free Crypto", comment: "Alert that is shown when a user taps Buy/Sell")
        static let buySellCardDescription = NSLocalizedString(
            "Buy and sell bitcoin directly from your Blockchain wallet. Start by creating an account in the Buy & Sell tab.",
            comment: "The description displayed on the card."
        )
        static let continueKYCCardDescription = NSLocalizedString(
            "Looks like you’ve started verifying your identity but didn’t finish. Pick up where you left off?",
            comment: "The description displayed on the card."
        )
        static let continueKYCActionButtonTitle = NSLocalizedString(
            "Continue verification",
            comment: "The title of the action on the announcement card."
        )
        static let uploadDocumentsCardTitle = NSLocalizedString(
            "Documents needed",
            comment: "The title of the action on the announcement card for when a user needs to submit documents to verify their identity."
        )
        static let uploadDocumentsCardDescription = NSLocalizedString(
            "We had some issues with the documents you’ve supplied.\nPlease try uploading the documents again to continue with your verification.",
            comment: "The description on the announcement card for when a user needs to submit documents to verify their identity."
        )
        static let uploadDocumentsActionButtonTitle = NSLocalizedString(
            "Upload documents",
            comment: "The title of the action on the announcement card for when a user needs to submit documents to verify their identity."
        )
    }

    struct SideMenu {
        static let loginToWebWallet = NSLocalizedString("Pair Web Wallet", comment: "")
        static let logout = NSLocalizedString("Logout", comment: "")
        static let debug = NSLocalizedString("Debug", comment: "")
        static let logoutConfirm = NSLocalizedString("Do you really want to log out?", comment: "")
        static let buySellBitcoin = NSLocalizedString(
            "Buy & Sell Bitcoin",
            comment: "Item displayed on the side menu of the app for when the user wants to buy and sell Bitcoin."
        )
        static let addresses = NSLocalizedString(
            "Addresses",
            comment: "Item displayed on the side menu of the app for when the user wants to view their crypto addresses."
        )
        static let backupFunds = NSLocalizedString(
            "Backup Funds",
            comment: "Item displayed on the side menu of the app for when the user wants to back up their funds by saving their 12 word mneumonic phrase."
        )
        static let swap = NSLocalizedString(
            "Swap",
            comment: "Item displayed on the side menu of the app for when the user wants to exchange crypto-to-crypto."
        )
        static let settings = NSLocalizedString(
            "Settings",
            comment: "Item displayed on the side menu of the app for when the user wants to view their wallet settings."
        )
        static let support = NSLocalizedString(
            "Support",
            comment: "Item displayed on the side menu of the app for when the user wants to contact support."
        )
        static let new = NSLocalizedString(
            "New",
            comment: "New tag shown for menu items that are new."
        )
        static let lockbox = NSLocalizedString(
            "Lockbox",
            comment: "Lockbox menu item title."
        )
    }

    struct BuySell {
        static let tradeCompleted = NSLocalizedString("Trade Completed", comment: "")
        static let tradeCompletedDetailArg = NSLocalizedString("The trade you created on %@ has been completed!", comment: "")
        static let viewDetails = NSLocalizedString("View details", comment: "")
        static let errorTryAgain = NSLocalizedString("Something went wrong, please try reopening Buy & Sell Bitcoin again.", comment: "")
        static let buySellAgreement = NSLocalizedString(
            "By tapping Begin Now, you agree to Coinify's Terms of Service & Privacy Policy",
            comment: "Disclaimer shown when starting KYC from Buy-Sell"
        )
    }

    struct Exchange {
        static let navigationTitle = NSLocalizedString(
            "Exchange",
            comment: "Title text shown on navigation bar for exchanging a crypto asset for another"
        )
        static let complete = NSLocalizedString(
            "Complete",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        static let delayed = NSLocalizedString(
            "Delayed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        static let expired = NSLocalizedString(
            "Expired",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        static let failed = NSLocalizedString(
            "Failed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        static let inProgress = NSLocalizedString(
            "In Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        static let refundInProgress = NSLocalizedString(
            "Refund in Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        static let refunded = NSLocalizedString(
            "Refunded",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )

        static let orderHistory = NSLocalizedString(
            "Order History",
            comment: "Header for the exchange list"
        )

        static let loading = NSLocalizedString(
            "Loading Exchange",
            comment: "Text presented when the wallet is loading the exchange"
        )
        static let loadingTransactions = NSLocalizedString("Loading transactions", comment: "")
        static let gettingQuote = NSLocalizedString("Getting quote", comment: "")
        static let confirming = NSLocalizedString("Confirming", comment: "")
        static let useMin = NSLocalizedString(
            "Use min",
            comment: "Text displayed on button for user to tap to create a trade with the minimum amount of crypto allowed"
        )
        static let useMax = NSLocalizedString(
            "Use max",
            comment: "Text displayed on button for user to tap to create a trade with the maximum amount of crypto allowed"
        )
        static let to = NSLocalizedString("To", comment: "Label for exchanging to a specific type of crypto")
        static let from = NSLocalizedString("From", comment: "Label for exchanging from a specific type of crypto")
        static let homebrewInformationText = NSLocalizedString(
            "All amounts are correct at this time but might change depending on the market price and transaction rates at the time your order is processed",
            comment: "Text displayed on exchange screen to inform user of changing market rates"
        )
        static let orderID = NSLocalizedString("Order ID", comment: "Label in the exchange locked screen.")
        static let exchangeLocked = NSLocalizedString("Exchange Locked", comment: "Header title for the Exchange Locked screen.")
        static let done = NSLocalizedString("Done", comment: "Footer button title")
        static let confirm = NSLocalizedString("Confirm", comment: "Footer button title for Exchange Confirmation screen")
        static let creatingOrder = NSLocalizedString("Creating order", comment: "Loading text shown when a final exchange order is being created")
        static let sendingOrder = NSLocalizedString("Sending order", comment: "Loading text shown when a final exchange order is being sent")
        static let exchangeXForY = NSLocalizedString(
            "Exchange %@ for %@",
            comment: "Text displayed on the primary action button for the exchange screen when exchanging between 2 assets."
        )
        static let receive = NSLocalizedString(
            "Receive",
            comment: "Text displayed when reviewing the amount to be received for an exchange order")
        static let estimatedFees = NSLocalizedString(
            "Estimated fees",
            comment: "Text displayed when reviewing the estimated amount of fees to pay for an exchange order")
        static let value = NSLocalizedString(
            "Value",
            comment: "Text displayed when reviewing the fiat value of an exchange order")
        static let sendTo = NSLocalizedString(
            "Send to",
            comment: "Text displayed when reviewing where the result of an exchange order will be sent to")
        static let expiredDescription = NSLocalizedString(
            "Your order has expired. No funds left your account.",
            comment: "Helper text shown when a user is viewing an order that has expired."
        )
        static let delayedDescription = NSLocalizedString(
            "Your order has not completed yet due to network delays. It will be processed as soon as funds are received.",
            comment: "Helper text shown when a user is viewing an order that is delayed."
        )
        static let tradeProblemWindow = NSLocalizedString(
            "Unfortunately, there is a problem with your order. We are researching and will resolve very soon.",
            comment: "Helper text shown when a user is viewing an order that is stuck (e.g. pending withdrawal and older than 24 hours)."
        )
        static let failedDescription = NSLocalizedString(
            "There was a problem with your order.",
            comment: "Helper text shown when a user is viewing an order that has expired."
        )
        static let whatDoYouWantToExchange = NSLocalizedString(
            "What do you want to exchange?",
            comment: "Text displayed on the action sheet that is presented when the user is selecting an account to exchange from."
        )
        static let whatDoYouWantToReceive = NSLocalizedString(
            "What do you want to receive?",
            comment: "Text displayed on the action sheet that is presented when the user is selecting an account to exchange into."
        )

        static let fees = NSLocalizedString("Fees", comment: "Fees")
        static let confirmExchange = NSLocalizedString(
            "Confirm Exchange",
            comment: "Confirm Exchange"
        )
        static let amountVariation = NSLocalizedString(
            "The amounts you send and receive may change slightly due to market activity.",
            comment: "Disclaimer in exchange locked screen"
        )
        static let orderStartDisclaimer = NSLocalizedString(
            "Once an order starts, we are unable to stop it.",
            comment: "Second disclaimer in exchange locked screen"
        )
        static let status = NSLocalizedString(
            "Status",
            comment: "Status of a trade in the exchange overview screen"
        )
        static let exchange = NSLocalizedString(
            "Exchange",
            comment: "Exchange"
        )
        static let aboveTradingLimit = NSLocalizedString(
            "Above trading limit",
            comment: "Error message shown when a user is attempting to exchange an amount above their designated limit"
        )
        static let belowTradingLimit = NSLocalizedString(
            "Below trading limit",
            comment: "Error message shown when a user is attempting to exchange an amount below their designated limit"
        )
        static let insufficientFunds = NSLocalizedString(
            "Insufficient funds",
            comment: "Error message shown when a user is attempting to exchange an amount greater than their balance"
        )

        static let yourMin = NSLocalizedString(
            "Your Min is",
            comment: "Error that displays what the minimum amount of fiat is required for a trade"
        )
        static let yourMax = NSLocalizedString(
            "Your Max is",
            comment: "Error that displays what the maximum amount of fiat allowed for a trade"
        )
        static let notEnough = NSLocalizedString(
            "Not enough",
            comment: "Part of error message shown when the user doesn't have enough funds to make an exchange"
        )
        static let yourBalance = NSLocalizedString(
            "Your balance is",
            comment: "Part of error message shown when the user doesn't have enough funds to make an exchange"
        )
        static let tradeExecutionError = NSLocalizedString(
            "Sorry, an order cannot be placed at this time.",
            comment: "Error message shown to a user if something went wrong during the exchange process and the user cannot continue"
        )
        static let exchangeListError = NSLocalizedString(
            "Sorry, your orders cannot be fetched at this time.",
            comment: "Error message shown to a user if something went wrong while fetching the user's exchange orders"
        )
        static let yourSpendableBalance = NSLocalizedString(
            "Your spendable balance is",
            comment: "Error message shown to a user if they try to exchange more than what is permitted."
        )
        static let marketsMoving = NSLocalizedString(
            "Markets are Moving 🚀",
            comment: "Error title when markets are fluctuating on the order confirmation screen"
        )
        static let holdHorses = NSLocalizedString(
            "Whoa! Hold your horses. 🐴",
            comment: "Error title shown when users are exceeding their limits in the order confirmation screen."
        )
        static let marketMovementMinimum = NSLocalizedString(
            "Due to market movement, your order value is now below the minimum required threshold of",
            comment: "Error message shown to a user if they try to exchange too little."
        )
        static let marketMovementMaximum = NSLocalizedString(
            "Due to market movement, your order value is now above the maximum allowable threshold of",
            comment: "Error message shown to a user if they try to exchange too much."
        )
        static let dailyAnnualLimitExceeded = NSLocalizedString(
            "There is a limit to how much crypto you can exchange. The value of your order must be less than your limit of",
            comment: "Error message shown to a user if they try to exchange beyond their limits whether annual or daily."
        )
        static let oopsSomethingWentWrong = NSLocalizedString(
            "Ooops! Something went wrong.",
            comment: "Oops error title"
        )
        static let oopsSwapDescription = NSLocalizedString(
            "We're not sure what happened but we didn't receive your order details.  Unfortunately, you're going to have to enter your order again.",
            comment: "Message that coincides with the `Oops! Something went wrong.` error title."
        )
        static let somethingNotRight = NSLocalizedString(
            "Hmm, something's not right. 👀",
            comment: "Error title shown when a trade's status is `stuck`."
        )
        static let somethingNotRightDetails = NSLocalizedString(
            "Most exchanges on Swap are completed seamlessly in two hours.  Please contact us. Together, we can figure this out.",
            comment: "Error description that coincides with `something's not right`."
        )
        static let networkDelay = NSLocalizedString("Network Delays", comment: "Network Delays")
        static let dontWorry = NSLocalizedString(
            "Don't worry, your exchange is in process. Swap trades are competed on-chain. If transaction volumes are high, there are sometimes delays.",
            comment: "Network delay description."
        )
        static let moreInfo = NSLocalizedString("More Info", comment: "More Info")
        static let updateOrder = NSLocalizedString("Update Order", comment: "Update Order")
        static let tryAgain = NSLocalizedString("Try Again", comment: "try again")
        static let increaseMyLimits = NSLocalizedString("Increase My Limits", comment: "Increase My Limits")
        static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
    }

    struct AddressAndKeyImport {

        static let nonSpendable = NSLocalizedString("Non-Spendable", comment: "Text displayed to indicate that part of the funds in the user’s wallet is not spendable.")

        static let copyWalletId = NSLocalizedString("Copy Wallet ID", comment: "")

        static let copyCTA = NSLocalizedString("Copy to clipboard", comment: "")
        static let copyWarning = NSLocalizedString(
        """
        Warning: Your wallet identifier is sensitive information. Copying it may compromise the security of your wallet.
        """, comment: "")

        static let importedWatchOnlyAddressArgument = NSLocalizedString("Imported watch-only address %@", comment: "")
        static let importedPrivateKeyArgument = NSLocalizedString("Imported Private Key %@", comment: "")
        static let loadingImportKey = NSLocalizedString("Importing key", comment: "")
        static let loadingProcessingKey = NSLocalizedString("Processing key", comment: "")
        static let importedKeyButForIncorrectAddress = NSLocalizedString("You’ve successfully imported a private key.", comment: "")
        static let importedKeyDoesNotCorrespondToAddress = NSLocalizedString("NOTE: The scanned private key does not correspond to this watch-only address. If you want to spend from this address, make sure that you scan the correct private key.", comment: "")
        static let importedKeySuccess = NSLocalizedString("You can now spend from this address.", comment: "")
        static let incorrectPrivateKey = NSLocalizedString("Incorrect private key", comment: "Incorrect private key")
        static let keyAlreadyImported = NSLocalizedString("Key already imported", comment: "")
        static let keyNeedsBip38Password = NSLocalizedString("Needs BIP38 Password", comment: "")
        static let incorrectBip38Password = NSLocalizedString("Wrong BIP38 Password", comment: "")
        static let unknownErrorPrivateKey = NSLocalizedString("There was an error importing this private key.", comment: "")
        static let addressNotPresentInWallet = NSLocalizedString("Your wallet does not contain this address.", comment: "")
        static let addressNotWatchOnly = NSLocalizedString("This address is not watch-only.", comment: "")
        static let keyBelongsToOtherAddressNotWatchOnly = NSLocalizedString("This private key belongs to another address that is not watch only", comment: "")
        static let unknownKeyFormat = NSLocalizedString("Unknown key format", comment: "")
        static let unsupportedPrivateKey = NSLocalizedString("Unsupported Private Key Format", comment: "")
        static let addWatchOnlyAddressWarning = NSLocalizedString("You are about to import a watch-only address, an address (or public key script) stored in the wallet without the corresponding private key. This means that the funds can be spent ONLY if you have the private key stored elsewhere. If you do not have the private key stored, do NOT instruct anyone to send you bitcoin to the watch-only address.", comment: "")
        static let addWatchOnlyAddressWarningPrompt = NSLocalizedString("These options are recommended for advanced users only. Continue?", comment: "")
    }

    struct SendAsset {
        static let invalidXAddressY = NSLocalizedString(
            "Invalid %@ address: %@",
            comment: "String presented to the user when they try to scan a QR code with an invalid address."
        )
        static let send = NSLocalizedString(
            "Send",
            comment: "Text displayed on the button for when a user wishes to send crypto."
        )
        static let confirmPayment = NSLocalizedString(
            "Confirm Payment",
            comment: "Header displayed asking the user to confirm their payment."
        )
        static let paymentSent = NSLocalizedString(
            "Payment sent",
            comment: "Alert message shown when crypto is successfully sent to a recipient."
        )
        static let transferAllFunds = NSLocalizedString(
            "Transfer All Funds",
            comment: "Title shown to use when transferring funds from legacy addresses to their new wallet"
        )
        
        static let paxComingSoonTitle = NSLocalizedString("USD PAX Coming Soon!", comment: "")
        static let paxComingSoonMessage = NSLocalizedString("We’re bringing USD PAX to iOS. While you wait, Send, Receive & Exchange USD PAX on the web.", comment: "")
        static let paxComingSoonLinkText = NSLocalizedString("What is USD PAX?", comment: "")
        static let notEnoughEth = NSLocalizedString("Not Enough ETH", comment: "")
        static let notEnoughEthDescription = NSLocalizedString("You'll need ETH to send your ERC20 Token", comment: "")
        static let invalidDestinationAddress = NSLocalizedString("Invalid ETH Address", comment: "")
        static let invalidDestinationDescription = NSLocalizedString("You must enter a valid ETH address to send your ERC20 Token", comment: "")
        static let notEnough = NSLocalizedString("Not Enough", comment: "")
        static let myPaxWallet = NSLocalizedString("My PAX Wallet", comment: "")
    }

    struct SendEther {
        static let waitingForPaymentToFinishTitle = NSLocalizedString("Waiting for payment", comment: "")
        static let waitingForPaymentToFinishMessage = NSLocalizedString("Please wait until your last ether transaction confirms.", comment: "")
    }

    struct Settings {
        static let notificationsDisabled = NSLocalizedString(
        """
        You currently have email notifications enabled. Changing your email will disable email notifications.
        """, comment: "")
        static let cookiePolicy = NSLocalizedString("Cookie Policy", comment: "")
        static let allRightsReserved = NSLocalizedString("All rights reserved.", comment: "")
        static let useBiometricsAsPin = NSLocalizedString("Use %@ as PIN", comment: "")
    }

    struct SwipeToReceive {
        static let pleaseLoginToLoadMoreAddresses = NSLocalizedString("Please login to load more addresses.", comment: "")
    }

    struct Receive {
        static let tapToCopyThisAddress = NSLocalizedString(
            "Tap to copy this address. Share it with the sender via email or text.",
            comment: "Text displayed on the receive screen instructing the user to copy their crypto address."
        )
        static let requestPayment = NSLocalizedString(
            "Request Payment",
            comment: "Text displayed on the button when requesting for payment to a crypto address."
        )
        static let copiedToClipboard = NSLocalizedString(
            "Copied to clipboard",
            comment: "Text displayed when a crypto address has been copied to the users clipboard."
        )
        static let enterYourSecondPassword = NSLocalizedString(
            "Enter Your Second Password",
            comment: "Text on the button prompting the user to enter their second password to proceed with creating a crypto account."
        )

        static let secondPasswordPromptX = NSLocalizedString(
            "Your second password is required in order to create a %@ account.",
            comment: "Text shown when the second password is required to create an XLM account."
        )
        static let xPaymentRequest = NSLocalizedString(
            "%@ payment request.",
            comment: "Subject when requesting payment for a given asset."
        )
        static let pleaseSendXto = NSLocalizedString(
            "Please send %@ to",
            comment: "Message when requesting payment to a given asset."
        )
    }

    struct ReceiveAsset {
        static let xPaymentRequest = NSLocalizedString("%@ payment request", comment: "Subject of the email sent when requesting for payment from another user.")
    }

    struct Transactions {
        static let paxfee = NSLocalizedString("PAX Fee", comment: "String displayed to indicate that a transaction is due to a fee associated to sending PAX.")
        static let allWallets = NSLocalizedString("All Wallets", comment: "Label of selectable item that allows user to show all transactions of a certain asset")
        static let noTransactions = NSLocalizedString("No Transactions", comment: "Text displayed when no recent transactions are being shown")
        static let noTransactionsAssetArgument = NSLocalizedString("Transactions occur when you send and receive %@.", comment: "Helper text displayed when no recent transactions are being shown")
        static let requestArgument = NSLocalizedString("Request %@", comment: "Text shown when a user can request a certain asset")
        static let getArgument = NSLocalizedString("Get %@", comment: "Text shown when a user can purchase a certain asset")
        static let justNow = NSLocalizedString("Just now", comment: "text shown when a transaction has just completed")
        static let secondsAgo = NSLocalizedString("%lld seconds ago", comment: "text shown when a transaction has completed seconds ago")
        static let oneMinuteAgo = NSLocalizedString("1 minute ago", comment: "text shown when a transaction has completed one minute ago")
        static let minutesAgo = NSLocalizedString("%lld minutes ago", comment: "text shown when a transaction has completed minutes ago")
        static let oneHourAgo = NSLocalizedString("1 hour ago", comment: "text shown when a transaction has completed one hour ago")
        static let hoursAgo = NSLocalizedString("%lld hours ago", comment: "text shown when a transaction has completed hours ago")
        static let yesterday = NSLocalizedString("Yesterday", comment: "text shown when a transaction has completed yesterday")
    }

    struct Backup {
        static let wordNumberOfNumber = NSLocalizedString(
            "Word %@ of %@",
            comment: "text displayed when showing individual words of their recovery phrase"
        )
        static let firstWord = NSLocalizedString(
            "first word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let secondWord = NSLocalizedString(
            "second word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let thirdWord = NSLocalizedString(
            "third word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let fourthWord = NSLocalizedString(
            "fourth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let fifthWord = NSLocalizedString(
            "fifth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let sixthWord = NSLocalizedString(
            "sixth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let seventhWord = NSLocalizedString(
            "seventh word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let eighthWord = NSLocalizedString(
            "eighth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let ninthWord = NSLocalizedString(
            "ninth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let tenthWord = NSLocalizedString(
            "tenth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let eleventhWord = NSLocalizedString(
            "eleventh word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let twelfthWord = NSLocalizedString(
            "twelfth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let verifyBackup = NSLocalizedString(
            "Verify Backup",
            comment: "Title displayed in the app for prompting the user to verify that they have written down all words of their recovery phrase"
        )
        static let backupFunds = NSLocalizedString(
            "Backup Funds",
            comment: "Title displayed in the app for when the user wants to back up their funds by saving their 12 word mneumonic phrase."
        )
        static let reminderBackupMessageFirstBitcoin = NSLocalizedString(
            "Congrats, you have bitcoin! Now let’s backup your wallet to ensure you can access your funds if you forget your password.",
            comment: "Reminder message for when the user has just received funds prior to having completed the backup phrase."
        )
        static let reminderBackupMessageHasFunds = NSLocalizedString(
            "For your security, we do not keep any passwords on file. Backup your wallet to ensure your funds are safe in case you lose your password.",
            comment: "Reminder message for when the user already has funds prior to having completed the backup phrase."
        )
    }

    struct LegacyUpgrade {
        static let upgrade = NSLocalizedString(
            "Upgrade",
            comment: "The title of the side menu entry item."
        )
        static let upgradeFeatureOne = NSLocalizedString(
            "Always know the market price",
            comment: "The description in the first view of the legacy wallet upgrade flow."
        )
        static let upgradeFeatureTwo = NSLocalizedString(
            "Easy one time wallet backup keeps you in control of your funds.",
            comment: "The description in the second view of the legacy wallet upgrade flow."
        )
        static let upgradeFeatureThree = NSLocalizedString(
            "Everything you need to store, spend and receive BTC, ETH and BCH.",
            comment: "The description in the third view of the legacy wallet upgrade flow."
        )
        static let upgradeSuccess = NSLocalizedString(
            "You are now running our most secure wallet",
            comment: "The message displayed in the alert view after completing the legacy upgrade flow."
        )
        static let upgradeSuccessTitle = NSLocalizedString(
            "Success!",
            comment: "The title of the alert view after completing the legacy upgrade flow."
        )
    }

    struct AppReviewFallbackPrompt {
        static let title = NSLocalizedString(
            "Rate Blockchain Wallet",
            comment: "The title of the fallback app review prompt."
        )
        static let message = NSLocalizedString(
            "Enjoying the Blockchain Wallet? Please take a moment to leave a review in the App Store and let others know about it.",
            comment: "The message of the fallback app review prompt."
        )
        static let affirmativeActionTitle = NSLocalizedString(
            "Yes, rate Blockchain Wallet",
            comment: "The title for the affirmative prompt action."
        )
        static let secondaryActionTitle = NSLocalizedString(
            "Ask Me Later",
            comment: "The title for the secondary prompt action."
        )
    }

    struct KYC {
        static let welcome = NSLocalizedString("Welcome", comment: "Welcome")
        static let welcomeMainText = NSLocalizedString(
            "Introducing Blockchain's faster, smarter way to trade your crypto. Upgrade now to enjoy benefits such as better prices, higher trade limits and live rates.",
            comment: "Text displayed when user is starting KYC"
        )
        static let welcomeMainTextSunRiverCampaign = NSLocalizedString(
            "Verify your identity to claim your XLM. It only takes a few minutes. Once verified, you'll be able to use our next generation trading product.",
            comment: "Text displayed when user is starting KYC coming from the airdrop link"
        )
        static let invalidPhoneNumber = NSLocalizedString(
            "The mobile number you entered is invalid.",
            comment: "Error message displayed to the user when the phone number they entered during KYC is invalid.")
        static let failedToConfirmNumber = NSLocalizedString(
            "Failed to confirm mobile number. Please try again.",
            comment: "Error message displayed to the user when the mobile confirmation steps fails."
        )
        static let termsOfServiceAndPrivacyPolicyNotice = NSLocalizedString(
            "By hitting \"Begin Now\", you agree to Blockchain’s %@ & %@",
            comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they start the KYC process."
        )
        static let verificationInProgress = NSLocalizedString(
            "Verification in Progress",
            comment: "Text displayed when KYC verification is in progress."
        )
        static let verificationInProgressDescription = NSLocalizedString(
            "Your information is being reviewed. When all looks good, you’re clear to exchange. You should receive a notification within 5 minutes.",
            comment: "Description for when KYC verification is in progress."
        )
        static let verificationInProgressDescriptionAirdrop = NSLocalizedString(
            "Your information is being reviewed. The review should complete in 5 minutes. Once you're successfully verified, we'll send your XLM within one week.",
            comment: "Description for when KYC verification is in progress and the user is waiting for a Stellar airdrop."
        )
        static let accountApproved = NSLocalizedString(
            "Account Approved",
            comment: "Text displayed when KYC verification is approved."
        )
        static let accountApprovedDescription = NSLocalizedString(
            "Congratulations! We successfully verified your identity. You can now Exchange cryptocurrencies at Blockchain.",
            comment: "Description for when KYC verification is approved."
        )
        static let accountApprovedBadge = NSLocalizedString(
            "Approved",
            comment: "KYC verification is approved."
        )
        static let accountInReviewBadge = NSLocalizedString(
            "In Review",
            comment: "KYC verification is in Review."
        )
        static let accountUnderReviewBadge = NSLocalizedString(
            "Under Review",
            comment: "KYC verification is under Review."
        )
        static let verificationUnderReview = NSLocalizedString(
            "Verification Under Review",
            comment: "Text displayed when KYC verification is under review."
        )
        static let verificationUnderReviewDescription = NSLocalizedString(
            "We had some trouble verifying your account with the documents provided. Our support team will contact you shortly to resolve this.",
            comment: "Description for when KYC verification is under review."
        )
        static let accountUnconfirmedBadge = NSLocalizedString(
            "Unconfirmed",
            comment: "KYC verification is unconfirmed."
        )
        static let accountUnverifiedBadge = NSLocalizedString(
            "Unverified",
            comment: "KYC verification is unverified."
        )
        static let accountVerifiedBadge = NSLocalizedString(
            "Verified",
            comment: "KYC verification is complete."
        )
        static let verificationFailed = NSLocalizedString(
            "Verification Failed",
            comment: "Text displayed when KYC verification failed."
        )
        static let verificationFailedBadge = NSLocalizedString(
            "Failed",
            comment: "Text displayed when KYC verification failed."
        )
        static let verificationFailedDescription = NSLocalizedString(
            "Unfortunately we had some trouble verifying your identity with the documents you’ve supplied and your account can’t be verified at this time.",
            comment: "Description for when KYC verification failed."
        )
        static let notifyMe = NSLocalizedString(
            "Notify Me",
            comment: "Title of the button the user can tap when they want to be notified of update with their KYC verification process."
        )
        static let getStarted = NSLocalizedString(
            "Get Started",
            comment: "Title of the button the user can tap when they want to start trading on the Exchange. This is displayed after their KYC verification has been approved."
        )
        static let contactSupport = NSLocalizedString(
            "Contact Support",
            comment: "Title of the button the user can tap when they want to contact support as a result of a failed KYC verification."
        )
        static let whatHappensNext = NSLocalizedString(
            "What happens next?",
            comment: "Text displayed (subtitle) when KYC verification is under progress"
        )
        static let comingSoonToX = NSLocalizedString(
            "Coming soon to %@!",
            comment: "Title text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        static let unsupportedCountryDescription = NSLocalizedString(
            "Every country has different rules on how to buy and sell cryptocurrencies. Keep your eyes peeled, we’ll let you know as soon as we launch in %@!",
            comment: "Description text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        static let unsupportedStateDescription = NSLocalizedString(
            "Every state has different rules on how to buy and sell cryptocurrencies. Keep your eyes peeled, we’ll let you know as soon as we launch in %@!",
            comment: "Description text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        static let messageMeWhenAvailable = NSLocalizedString(
            "Message Me When Available",
            comment: "Text displayed on a button when the user wishes to be notified when crypto-to-crypto exchange is available in their country."
        )
        static let yourHomeAddress = NSLocalizedString(
            "Your Home Address",
            comment: "Text displayed on the search bar when adding an address during KYC."
        )
        static let whichDocumentAreYouUsing = NSLocalizedString(
            "Which document are you using?",
            comment: ""
        )
        static let passport = NSLocalizedString(
            "Valid Passport",
            comment: "The title of the UIAlertAction for the passport option."
        )
        static let driversLicense = NSLocalizedString(
            "Driver's License",
            comment: "The title of the UIAlertAction for the driver's license option."
        )
        static let nationalIdentityCard = NSLocalizedString(
            "National ID Card",
            comment: "The title of the UIAlertAction for the national identity card option."
        )
        static let residencePermit = NSLocalizedString(
            "Residence Card",
            comment: "The title of the UIAlertAction for the residence permit option."
        )
        static let documentsNeededSummary = NSLocalizedString(
            "Unfortunately we're having trouble verifying your identity, and we need you to resubmit your verification information.",
            comment: "The main message shown in the Documents Needed screen."
        )
        static let reasonsTitle = NSLocalizedString(
            "Main reasons for this to happen:",
            comment: "Title text in the Documents Needed screen preceding the list of reasons a user would need to resubmit their documents"
        )
        static let reasonsDescription = NSLocalizedString(
            "The required photos are missing.\n\nThe document you submitted is incorrect.\n\nWe were unable to read the images you submitted due to image quality. ",
            comment: "Description text in the Documents Needed screen preceding the list of reasons a user would need to resubmit their documents"
        )
        static let submittingInformation = NSLocalizedString(
            "Submitting information...",
            comment: "Text prompt to the user when the client is submitting the identity documents to Blockchain's servers."
        )
        static let emailAddressAlreadyInUse = NSLocalizedString(
            "This email address has already been used to verify an existing wallet.",
            comment: "The error message when a user attempts to start KYC using an existing email address."
        )
        static let failedToSendVerificationEmail = NSLocalizedString(
            "Failed to send verification email. Please try again.",
            comment: "The error message shown when the user tries to verify their email but the server failed to send the verification email."
        )
        static let whyDoWeNeedThis = NSLocalizedString(
            "Why do we need this?",
            comment: "Header text for an a page in the KYC flow where we justify why a certain piece of information is being collected."
        )
        static let enterEmailExplanation = NSLocalizedString(
            "We need to verify your email address as an added layer of security.",
            comment: "Text explaning to the user why we are collecting their email address."
        )
        static let checkYourInbox = NSLocalizedString(
            "Check your inbox.",
            comment: "Header text telling the user to check their mail inbox to verify their email"
        )
        static let confirmEmailExplanation = NSLocalizedString(
            "We just sent you an email with further instructions.",
            comment: "Text telling the user to check their mail inbox to verify their email."
        )
        static let didntGetTheEmail = NSLocalizedString(
            "Didn't get the email?",
            comment: "Text asking if the user didn't get the verification email."
        )
        static let sendAgain = NSLocalizedString(
            "Send again",
            comment: "Text asking if the user didn't get the verification email."
        )
        static let emailSent = NSLocalizedString(
            "Email sent!",
            comment: "Text displayed when the email verification has successfully been sent."
        )
        static let freeCrypto = NSLocalizedString(
            "Get Free Crypto",
            comment: "Headline displayed on a KYC Tier 2 Cell"
        )
        static let unlock = NSLocalizedString(
            "Unlock",
            comment: "Prompt to complete a verification tier"
        )
        static let tierZeroVerification = NSLocalizedString(
            "Tier zero",
            comment: "Tier 0 Verification"
        )
        static let tierOneVerification = NSLocalizedString(
            "Silver Level",
            comment: "Tier 1 Verification"
        )
        static let tierTwoVerification = NSLocalizedString(
            "Gold Level",
            comment: "Tier 2 Verification"
        )
        static let annualSwapLimit = NSLocalizedString(
            "Annual Swap Limit",
            comment: "Annual Swap Limit"
        )
        static let dailySwapLimit = NSLocalizedString(
            "Daily Swap Limit",
            comment: "Daily Swap Limit"
        )
        static let takesThreeMinutes = NSLocalizedString(
            "Takes 3 min",
            comment: "Duration for Tier 1 application"
        )
        static let takesTenMinutes = NSLocalizedString(
            "Takes 10 min",
            comment: "Duration for Tier 2 application"
        )
        static let swapNow = NSLocalizedString("Swap Now", comment: "Swap Now")
        static let swapLimits = NSLocalizedString("Swap Limits", comment: "Swap Limits")
        static let swapTagline = NSLocalizedString(
            "Trading your crypto doesn't mean trading away control.",
            comment: "The tagline describing what Swap is"
        )
        static let swapStatusInReview = NSLocalizedString(
            "In Review",
            comment: "Swap status is in review"
        )
        static let swapStatusInReviewCTA = NSLocalizedString(
            "In Review - Need More Info",
            comment: "Swap status is in review but we require more info from the user."
        )
        static let swapStatusUnderReview = NSLocalizedString(
            "Under Review",
            comment: "Swap status is under review."
        )
        static let swapStatusApproved = NSLocalizedString(
            "Approved!",
            comment: "Swap status is approved."
        )
        static let swapAnnouncement = NSLocalizedString(
            "Swap by Blockchain enables you to trade crypto with best prices, and quick settlement, all while maintaining full control of your funds.",
            comment: "The announcement and description describing what Swap is."
        )
        static let swapLimitDescription = NSLocalizedString(
            "Your Swap Limit is the maximum amount of crypto you can trade.",
            comment: "A description of what the user's swap limit is."
        )
        static let swapUnavailable = NSLocalizedString(
            "Swap Currently Unavailable",
            comment: "Swap Currently Unavailable"
        )
        static let swapUnavailableDescription = NSLocalizedString(
            "We had trouble approving your identity. Your Swap feature has been disabled at this time.",
            comment: "A description as to why Swap has been disabled"
        )
        static let available = NSLocalizedString(
            "Available",
            comment: "Available"
        )
        static let availableToday = NSLocalizedString(
            "Available Today",
            comment: "Available Today"
        )
        static let tierTwoVerificationIsBeingReviewed = NSLocalizedString(
            "Your Gold level verification is currently being reviewed by a Blockchain Support Member.",
            comment: "The Tiers overview screen when the user is approved for Tier 1 but they are in review for Tier 2"
        )
        static let tierOneRequirements = NSLocalizedString(
            "Requires Email, Name, Date of Birth and Address",
            comment: "A descriptions of the requirements to complete Tier 1 verification"
        )
        // TODO: how should we handle conditional strings? What if the mobile requirement gets added back?
        static let tierTwoRequirements = NSLocalizedString(
            "Requires Silver level, Govt. ID and a Selfie",
            comment: "A descriptions of the requirements to complete Tier 2 verification"
        )
        static let notNow = NSLocalizedString(
            "Not Now",
            comment: "Text displayed when the user does not want to continue with tier 2 KYC."
        )
        static let moreInfoNeededHeaderText = NSLocalizedString(
            "We Need Some More Information to Complete Your Profile",
            comment: "Header text when more information is needed from the user for KYCing"
        )
        static let moreInfoNeededSubHeaderText = NSLocalizedString(
            "You’ll need to verify your phone number, provide a government issued ID and a Selfie.",
            comment: "Header text when more information is needed from the user for KYCing"
        )
        static let openEmailApp = NSLocalizedString(
            "Open Email App",
            comment: "CTA for when the user should open the email app to continue email verification."
        )
        static let submit = NSLocalizedString(
            "Submit",
            comment: "Text displayed on the CTA when submitting KYC information."
        )
        static let termsOfServiceAndPrivacyPolicyNoticeAddress = NSLocalizedString(
            "By tapping Submit, you agree to Blockchain’s %@ & %@",
            comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they start the KYC process."
        )
        static let completingTierTwoAutoEligible = NSLocalizedString(
            "By completing the Gold Level requirements you are automatically eligible for our airdrop program.",
            comment: "Description of what the user gets out of completing Tier 2 verification that is seen at the bottom of the Tiers screen. This particular description is when the user has been Tier 1 verified."
        )
        static let needSomeHelp = NSLocalizedString("Need some help?", comment: "Need some help?")
        static let helpGuides = NSLocalizedString(
            "Our Blockchain Support Team has written Help Guides explaining why we need to verify your identity",
            comment: "Description shown in modal that is presented when tapping the question mark in KYC."
        )
        static let readNow = NSLocalizedString("Read Now", comment: "Read Now")
        static let enableCamera = NSLocalizedString(
            "Also, enable your camera!",
            comment: "Requesting user to enable their camera"
        )
        static let enableCameraDescription = NSLocalizedString(
            "Please allow your Blockchain App access your camera to upload your ID and take a Selfie.",
            comment: "Description as to why the user should permit camera access"
        )
        static let allowCameraAccess = NSLocalizedString(
            "Allow camera access?",
            comment: "Headline in alert asking the user to allow camera access."
        )
        static let streetLine = NSLocalizedString("Street line", comment: "Street line")
        static let addressLine = NSLocalizedString("Address line", comment: "Address line")
        static let city = NSLocalizedString("City", comment: "city")
        static let cityTownVillage = NSLocalizedString("City / Town / Village", comment: "City / Town / Village")
        static let zipCode = NSLocalizedString("Zip Code", comment: "zip code")
        static let required = NSLocalizedString("Required", comment: "required")
        static let state = NSLocalizedString("State", comment: "state")
        static let stateRegionProvinceCountry = NSLocalizedString("State / Region / Province / Country", comment: "State / Region / Province / Country")
        static let postalCode = NSLocalizedString("Postal Code", comment: "postal code")
    }

    struct Swap {
        static let viewMySwapLimit = NSLocalizedString(
            "View My Swap Limit",
            comment: "Text displayed on the CTA when the user wishes to view their swap limits."
        )
        static let helpDescription = NSLocalizedString(
            "Our Blockchain Support Team is standing by to help any questions you have.",
            comment: "Text displayed in the help modal."
        )
        static let tier = NSLocalizedString(
            "Tier", comment: "Text shown to represent the level of access a user has to Swap features."
        )
        static let locked = NSLocalizedString(
            "Locked", comment: "Text shown to indicate that Swap features have not been unlocked yet."
        )
        static let swapLimit = NSLocalizedString(
            "Swap Limit", comment: "Text shown to represent the level of access a user has to Swap features."
        )
        static let swap = NSLocalizedString(
            "Swap", comment: "Text shown for the crypto exchange service."
        )
        static let exchange = NSLocalizedString(
            "Exchange", comment: "Button text shown on the exchange screen to progress to the confirm screen"
        )
        static let confirmSwap = NSLocalizedString(
            "Confirm Swap", comment: "Button text shown on the exchange confirm screen to execute the swap"
        )
        static let swapLocked = NSLocalizedString(
            "Swap Locked", comment: "Button text shown on the exchange screen to show that a swap has been confirmed"
        )
        static let tierlimitErrorMessage = NSLocalizedString(
            "Your max is %@.", comment: "Error message shown on the exchange screen when a user's exchange input would exceed their tier limit"
        )
        static let upgradeNow = NSLocalizedString(
            "Upgrade now.", comment: "Call to action shown to encourage the user to reach a higher swap tier"
        )
        static let postTierError = NSLocalizedString(
            "An error occurred when selecting your tier. Please try again later.", comment: "Error shown when a user selects a tier and an error occurs when posting the tier to the server"
        )
        static let swapCardMessage = NSLocalizedString(
            "Exchange one crypto for another without ever leaving your Blockchain Wallet.",
            comment: "Message on the swap card"
        )
        static let checkItOut = NSLocalizedString("Check it out!", comment: "CTA on the swap card")
        static let swapInfo = NSLocalizedString("Swap Info", comment: "Swap Info")
        static let close = NSLocalizedString("Close", comment: "Close")
        static let orderHistory = NSLocalizedString("Order History", comment: "Order History")
    }

    struct Lockbox {
        static let getYourLockbox = NSLocalizedString(
            "Get Your Lockbox",
            comment: "Title prompting the user to buy a lockbox."
        )
        static let safelyStoreYourLockbox = NSLocalizedString(
            "Safely store your crypto currency offline.",
            comment: "Subtitle prompting the user to buy a lockbox."
        )
        static let buyNow = NSLocalizedString(
            "Buy Now",
            comment: "Buy now CTA for a lockbox device."
        )
        static let alreadyOwnOne = NSLocalizedString(
            "Already own one?",
            comment: "Title for anouncement card for the lockbox."
        )
        static let announcementCardSubtitle = NSLocalizedString(
            "From your computer log into blockchain.com and connect your Lockbox.",
            comment: "Subtitle for anouncement card for the lockbox."
        )
        static let balancesComingSoon = NSLocalizedString(
            "Balances Coming Soon",
            comment: "Title displayed to the user when they have a synced lockbox."
        )
        static let balancesComingSoonSubtitle = NSLocalizedString(
            "We are unable to display your Lockbox balance at this time. Don’t worry, your funds are safe. We’ll be adding this feature soon. While you wait, you can check your balance on the web.",
            comment: "Subtitle display to the user when they have a synced lockbox."
        )
        static let checkMyBalance = NSLocalizedString(
            "Check My Balance",
            comment: "CTA for when the user has a synced lockbox."
        )
        static let wantToLearnMoreX = NSLocalizedString(
            "Want to learn more? Tap here to visit %@",
            comment: "Footer text in the lockbox view."
        )
    }

    struct Stellar {
        static let memoTitle = NSLocalizedString("Memo", comment: "Memo title")
        static let memoDescription = NSLocalizedString(
            "Memos are used to communicate optional information to the recipient.",
            comment: "Description of what a memo is and the two types of memos you can send."
        )
        static let memoText = NSLocalizedString("Memo Text", comment: "memo text")
        static let memoID = NSLocalizedString("Memo ID", comment: "memo ID")
        static let minimumBalance = NSLocalizedString(
            "Minimum Balance",
            comment: "Title of page explaining XLM's minimum balance"
        )
        static let minimumBalanceInfoExplanation = NSLocalizedString(
            "Stellar requires that all Stellar accounts hold a minimum balance of lumens, or XLM. This means you cannot send a balance out of your Stellar Wallet that would leave your Stellar Wallet with less than the minimum balance. This also means that in order to send XLM to a new Stellar account, you must send enough XLM to meet the minimum balance requirement.",
            comment: "General explanation for minimum balance for XLM."
        )
        static let minimumBalanceInfoCurrentArgument = NSLocalizedString(
            "The current minimum balance requirement is %@.",
            comment: "Explanation for the current minimum balance for XLM."
        )
        static let totalFundsLabel = NSLocalizedString(
            "Total Funds",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        static let xlmReserveRequirement = NSLocalizedString(
            "XLM Reserve Requirement",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        static let transactionFee = NSLocalizedString(
            "Transaction Fee",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        static let availableToSend = NSLocalizedString(
            "Available to Send",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        static let minimumBalanceMoreInformation = NSLocalizedString(
            "You can read more information about Stellar's minimum balance requirement at Stellar.org",
            comment: "Helper text for user to learn more about the minimum balance requirement for XLM."
        )
        static let readMore = NSLocalizedString(
            "Read More",
            comment: "Button title for user to learn more about the minimum balance requirement for XLM."
        )
        static let defaultLabelName = NSLocalizedString(
            "My Stellar Wallet",
            comment: "The default label of the XLM wallet."
        )
        static let enterStellarAddress = NSLocalizedString(
            "Enter a Stellar address or select",
            comment: "Placeholder text for the Lumens send screen."
        )
        static let viewOnArgument = NSLocalizedString(
            "View on %@",
            comment: "Button title for viewing a transaction on the explorer")
        static let cannotSendXLMAtThisTime = NSLocalizedString(
            "Cannot send XLM at this time. Please try again.",
            comment: "Error displayed when XLM cannot be sent due to an error."
        )
        static let notEnoughXLM = NSLocalizedString(
            "Not enough XLM.",
            comment: "Error message displayed if the user tries to send XLM but does not have enough of it."
        )
        static let invalidDestinationAddress = NSLocalizedString(
            "Invalid destination address",
            comment: "Error message displayed if the user tries to send XLM to an invalid address"
        )
        static let useSpendableBalanceX = NSLocalizedString(
            "Use total spendable balance: ",
            comment: "Tappable text displayed in the send XLM screen for when the user wishes to send their full spendable balance."
        )
        static let minimumForNewAccountsError = NSLocalizedString(
            "Minimum of 1.0 XLM needed for new accounts",
            comment: "This is the error shown when too little XLM is sent to a primary key that does not yet have an XLM account"
        )
        static let claimYourStellarXLM = NSLocalizedString(
            "Claim Your Stellar (XLM)",
            comment: "Title displayed in the onboarding card prompting the user to join the waitlist to receive Stellar."
        )
        static let weNowSupportStellar = NSLocalizedString(
            "We Now Support Stellar",
            comment: "Title displayed in the onboarding card showing that we support Stellar."
        )
        static let weNowSupportStellarDescription = NSLocalizedString(
            "XLM is a token that enables quick, low cost global transactions. Send, receive, and trade XLM in the wallet today.",
            comment: "Description displayed in the onboarding card showing that we support Stellar."
        )
        static let claimYourFreeXLMNow = NSLocalizedString(
            "Claim Your Free XLM Now",
            comment: "CTA prompting the user to join the XLM waitlist."
        )
        static let claimYourStellarDescription = NSLocalizedString(
            "Looks like you've started verifying your identity but didn't finish. Pick up where you left off.",
            comment: "Description displayed on the onboarding card prompting the user to complete KYC to receive their airdrop."
        )
        static let yourXLMIsOnItsWay = NSLocalizedString(
            "Your XLM is on its way",
            comment: "Title displayed on the onboarding card notifying them that their airdrop is on its way."
        )
        static let yourXLMIsOnItsWayDescription = NSLocalizedString(
            "We have successfully verified your identity.",
            comment: "Description displayed on the onboarding card notifying them that their airdrop is on its way."
        )
        static let ohNo = NSLocalizedString(
            "Oh no!",
            comment: "Error title shown when deep linking from a claim your XLM link."
        )
    }

    struct Airdrop {
        static let invalidCampaignUser = NSLocalizedString(
            "We're sorry, the airdrop program is currently not available where you are.",
            comment: "Error message displayed when the user that is trying to register for the campaign cannot register."
        )
        static let alreadyRegistered = NSLocalizedString(
            "Looks like you've already received your airdrop!",
            comment: "Error message displayed when the user has already claimed their airdrop."
        )
        static let xlmCampaignOver = NSLocalizedString(
            "We're sorry, the XLM airdrop is over. Complete your profile to be eligible for future airdrops and access trading.",
            comment: "Error message displayed when the XLM airdrop is over."
        )
        static let genericError = NSLocalizedString(
            "Oops! We had trouble processing your airdrop. Please try again.",
            comment: "Generic airdrop error."
        )
    }
}

// TODO: deprecate this once Obj-C is no longer using this
/// LocalizationConstants class wrapper so that LocalizationConstants can be accessed from Obj-C.
@objc class LocalizationConstantsObjcBridge: NSObject {
    @objc class func paxFee() -> String { return LocalizationConstants.Transactions.paxfee }

    @objc class func copiedToClipboard() -> String { return LocalizationConstants.Receive.copiedToClipboard }

    @objc class func createWalletLegalAgreementPrefix() -> String {
        return LocalizationConstants.Onboarding.termsOfServiceAndPrivacyPolicyNoticePrefix
    }

    @objc class func termsOfService() -> String {
        return LocalizationConstants.tos
    }

    @objc class func privacyPolicy() -> String {
        return LocalizationConstants.privacyPolicy
    }

    @objc class func tapToCopyThisAddress() -> String { return LocalizationConstants.Receive.tapToCopyThisAddress }

    @objc class func requestPayment() -> String { return LocalizationConstants.Receive.requestPayment }

    @objc class func continueString() -> String { return LocalizationConstants.continueString }

    @objc class func warning() -> String { return LocalizationConstants.Errors.warning }

    @objc class func requestFailedCheckConnection() -> String { return LocalizationConstants.Errors.requestFailedCheckConnection }

    @objc class func information() -> String { return LocalizationConstants.information }

    @objc class func error() -> String { return LocalizationConstants.Errors.error }

    @objc class func noInternetConnection() -> String { return LocalizationConstants.Errors.noInternetConnection }

    @objc class func onboardingRecoverFunds() -> String { return LocalizationConstants.Onboarding.recoverFunds }

    @objc class func tryAgain() -> String { return LocalizationConstants.tryAgain }

    @objc class func passwordRequired() -> String { return LocalizationConstants.Authentication.passwordRequired }

    @objc class func downloadingWallet() -> String { return LocalizationConstants.Authentication.downloadingWallet }

    @objc class func timedOut() -> String { return LocalizationConstants.Errors.timedOut }

    @objc class func incorrectPin() -> String { return LocalizationConstants.Pin.incorrect }

    @objc class func logout() -> String { return LocalizationConstants.SideMenu.logout }

    @objc class func debug() -> String { return LocalizationConstants.SideMenu.debug }

    @objc class func noPasswordEntered() -> String { return LocalizationConstants.Authentication.noPasswordEntered }

    @objc class func secondPasswordRequired() -> String { return LocalizationConstants.Authentication.secondPasswordRequired }

    @objc class func secondPasswordDefaultDescription() -> String { return LocalizationConstants.Authentication.secondPasswordDefaultDescription }

    @objc class func privateKeyNeeded() -> String { return LocalizationConstants.Authentication.privateKeyNeeded }

    @objc class func privateKeyDefaultDescription() -> String { return LocalizationConstants.Authentication.privateKeyPasswordDefaultDescription }

    @objc class func success() -> String { return LocalizationConstants.success }

    @objc class func syncingWallet() -> String { return LocalizationConstants.syncingWallet }

    @objc class func loadingImportKey() -> String { return LocalizationConstants.AddressAndKeyImport.loadingImportKey }

    @objc class func loadingProcessingKey() -> String { return LocalizationConstants.AddressAndKeyImport.loadingProcessingKey }

    @objc class func incorrectBip38Password() -> String { return LocalizationConstants.AddressAndKeyImport.incorrectBip38Password }

    @objc class func scanQRCode() -> String { return LocalizationConstants.scanQRCode }

    @objc class func nameAlreadyInUse() -> String { return LocalizationConstants.Errors.nameAlreadyInUse }

    @objc class func unknownKeyFormat() -> String { return LocalizationConstants.AddressAndKeyImport.unknownKeyFormat }

    @objc class func unsupportedPrivateKey() -> String { return LocalizationConstants.AddressAndKeyImport.unsupportedPrivateKey }

    @objc class func cookiePolicy() -> String { return LocalizationConstants.Settings.cookiePolicy }

    @objc class func gettingQuote() -> String { return LocalizationConstants.Exchange.gettingQuote }

    @objc class func confirming() -> String { return LocalizationConstants.Exchange.confirming }

    @objc class func loadingTransactions() -> String { return LocalizationConstants.Exchange.loadingTransactions }

    @objc class func xPaymentRequest() -> String { return LocalizationConstants.ReceiveAsset.xPaymentRequest }

    @objc class func invalidXAddressY() -> String { return LocalizationConstants.SendAsset.invalidXAddressY }

    @objc class func reminderBackupMessageFirstBitcoin() -> String { return LocalizationConstants.Backup.reminderBackupMessageFirstBitcoin }

    @objc class func reminderBackupMessageHasFunds() -> String { return LocalizationConstants.Backup.reminderBackupMessageHasFunds }

    @objc class func upgradeSuccess() -> String { return LocalizationConstants.LegacyUpgrade.upgradeSuccess }

    @objc class func upgradeSuccessTitle() -> String { return LocalizationConstants.LegacyUpgrade.upgradeSuccessTitle }

    @objc class func upgrade() -> String { return LocalizationConstants.LegacyUpgrade.upgrade }

    @objc class func upgradeFeatureOne() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureOne }

    @objc class func upgradeFeatureTwo() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureTwo }

    @objc class func upgradeFeatureThree() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureThree }

    @objc class func useBiometricsAsPin() -> String { return LocalizationConstants.Settings.useBiometricsAsPin }

    @objc class func biometryWarning() -> String { return LocalizationConstants.Biometrics.biometryWarning }

    @objc class func biometricInstructions() -> String { return LocalizationConstants.Onboarding.biometricInstructions }

    @objc class func enableBiometrics() -> String { return LocalizationConstants.Biometrics.enableX }

    @objc class func nonSpendable() -> String { return LocalizationConstants.AddressAndKeyImport.nonSpendable }

    @objc class func dontShowAgain() -> String { return LocalizationConstants.dontShowAgain }

    @objc class func loadingExchange() -> String { return LocalizationConstants.Exchange.loading }

    @objc class func etherSecondPasswordPrompt() -> String { return LocalizationConstants.Authentication.etherSecondPasswordPrompt }

    @objc class func myEtherWallet() -> String { return LocalizationConstants.myEtherWallet }

    @objc class func buySellCardTitle() -> String { return LocalizationConstants.AnnouncementCards.buySellCardTitle }

    @objc class func buySellCardDescription() -> String { return LocalizationConstants.AnnouncementCards.buySellCardDescription }

    @objc class func notEnoughXForFees() -> String { return LocalizationConstants.Errors.notEnoughXForFees }

    @objc class func balances() -> String { return LocalizationConstants.balances }

    @objc class func dashboardPriceCharts() -> String { return LocalizationConstants.Dashboard.priceCharts }

    @objc class func dashboardBitcoinPrice() -> String { return LocalizationConstants.Dashboard.bitcoinPrice }

    @objc class func dashboardEtherPrice() -> String { return LocalizationConstants.Dashboard.etherPrice }

    @objc class func dashboardBitcoinCashPrice() -> String { return LocalizationConstants.Dashboard.bitcoinCashPrice }

    @objc class func dashboardStellarPrice() -> String { return LocalizationConstants.Dashboard.stellarPrice }

    @objc class func justNow() -> String { return LocalizationConstants.Transactions.justNow }

    @objc class func secondsAgo() -> String { return LocalizationConstants.Transactions.secondsAgo }

    @objc class func oneMinuteAgo() -> String { return LocalizationConstants.Transactions.oneMinuteAgo }

    @objc class func minutesAgo() -> String { return LocalizationConstants.Transactions.minutesAgo }

    @objc class func oneHourAgo() -> String { return LocalizationConstants.Transactions.oneHourAgo }

    @objc class func hoursAgo() -> String { return LocalizationConstants.Transactions.hoursAgo }

    @objc class func yesterday() -> String { return LocalizationConstants.Transactions.yesterday }

    @objc class func myBitcoinWallet() -> String { return LocalizationConstants.ObjCStrings.BC_STRING_MY_BITCOIN_WALLET }

    @objc class func balancesErrorGeneric() -> String { return LocalizationConstants.Errors.balancesGeneric }
}
