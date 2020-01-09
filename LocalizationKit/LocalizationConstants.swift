//
//  LocalizationConstants.swift
//  Localization
//
//  Created by AlexM on 1/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// swiftlint:disable line_length
// swiftlint:disable identifier_name
// swiftlint:disable type_body_length
public struct LocalizationConstants {
    
    public struct ObjCStrings {
        public static let  BC_STRING_ALL_WALLETS = NSLocalizedString("All Wallets", comment: "")
        public static let  BC_STRING_WALLETS = NSLocalizedString("Wallets", comment: "")
        public static let  BC_STRING_ANY_ADDRESS = NSLocalizedString("Any address", comment: "")
        public static let  BC_STRING_ARGUMENT_ADDRESSES = NSLocalizedString("%d addresses", comment: "")
        public static let  BC_STRING_ARGUMENT_ADDRESS = NSLocalizedString("%d address", comment: "")
        public static let  BC_STRING_NO_ADDRESSES_WITH_SPENDABLE_BALANCE_ABOVE_OR_EQUAL_TO_DUST = NSLocalizedString("You have no addresses with a spendable balance greater than or equal to the required dust threshold.", comment: "")
        public static let  BC_STRING_SOME_FUNDS_CANNOT_BE_TRANSFERRED_AUTOMATICALLY = NSLocalizedString("Some funds cannot be transferred automatically.", comment: "")
        public static let  BC_STRING_ENTER_BITCOIN_ADDRESS_OR_SELECT = NSLocalizedString("Enter btc address or select", comment: "")
        public static let  BC_STRING_ENTER_ETHER_ADDRESS = NSLocalizedString("Enter eth address", comment: "")
        public static let  BC_STRING_YOU_MUST_ENTER_DESTINATION_ADDRESS = NSLocalizedString("You must enter a destination address", comment: "")
        public static let  BC_STRING_INVALID_TO_BITCOIN_ADDRESS = NSLocalizedString("Invalid to bitcoin address", comment: "")
        public static let  BC_STRING_FROM_TO_DIFFERENT = NSLocalizedString("From and destination have to be different", comment: "")
        public static let  BC_STRING_FROM_TO_ADDRESS_DIFFERENT = NSLocalizedString("From and destination address have to be different", comment: "")
        public static let  BC_STRING_INVALID_SEND_VALUE = NSLocalizedString("Invalid Send Value", comment: "")
        public static let  BC_STRING_SIGNING_INPUTS = NSLocalizedString("Signing Inputs", comment: "")
        public static let  BC_STRING_SIGNING_INPUT = NSLocalizedString("Signing Input %d", comment: "")
        public static let  BC_STRING_FINISHED_SIGNING_INPUTS = NSLocalizedString("Finished Signing Inputs", comment: "")
        public static let  BC_STRING_TRANSFER_ALL_FROM_ADDRESS_ARGUMENT_ARGUMENT = NSLocalizedString("Transferring all funds: Address %i of %i", comment: "")
        public static let  BC_STRING_TRANSFER_ALL_CALCULATING_AMOUNTS_AND_FEES_ARGUMENT_OF_ARGUMENT = NSLocalizedString("Calculating: Address %@ of %@", comment: "")
        public static let  BC_STRING_TRANSFER_ALL_PREPARING_TRANSFER = NSLocalizedString("Preparing transfer", comment: "")
        public static let  BC_STRING_ADD_TO_ADDRESS_BOOK = NSLocalizedString("Add to Address book?", comment: "")
        public static let  BC_STRING_NO = NSLocalizedString("No", comment: "")
        public static let  BC_STRING_YES = NSLocalizedString("Yes", comment: "")
        public static let  BC_STRING_SEND = NSLocalizedString("Send", comment: "")
        public static let  BC_STRING_NO_AVAILABLE_FUNDS = NSLocalizedString("You have no available funds to send from this address", comment: "")
        public static let  BC_STRING_MUST_BE_ABOVE_OR_EQUAL_TO_DUST_THRESHOLD = NSLocalizedString("Amount must be greater than or equal to the dust threshold (%lld Satoshi)", comment: "")
        public static let  BC_STRING_RECEIVE = NSLocalizedString("Receive", comment: "")
        public static let  BC_STRING_TRANSACTIONS = NSLocalizedString("Transactions", comment: "")
        public static let  BC_STRING_LOAD_MORE_TRANSACTIONS = NSLocalizedString("Load More Transactions", comment: "")
        public static let  BC_STRING_SENDING_TRANSACTION = NSLocalizedString("Sending Transaction", comment: "")
        public static let  BC_STRING_USE_TOTAL_AVAILABLE_MINUS_FEE_ARGUMENT = NSLocalizedString("Use total available minus fee: %@", comment: "")
        public static let  BC_STRING_PAYMENT_SENT = NSLocalizedString("Payment Sent!", comment: "")
        public static let  BC_STRING_PAYMENT_SENT_ETHER = NSLocalizedString("Payment Sent! Your balance and transactions will update soon.", comment: "")
        public static let  BC_STRING_WAITING_FOR_ETHER_PAYMENT_TO_FINISH_TITLE = NSLocalizedString("Waiting for payment", comment: "")
        public static let  BC_STRING_PAYMENTS_SENT = NSLocalizedString("Payments Sent", comment: "")
        public static let  BC_STRING_PAYMENT_TRANSFERRED_FROM_ARGUMENT_ARGUMENT = NSLocalizedString("Transferred funds from %d %@", comment: "")
        public static let  BC_STRING_PAYMENT_TRANSFERRED_FROM_ARGUMENT_ARGUMENT_OUTPUTS_ARGUMENT_ARGUMENT_TOO_SMALL = NSLocalizedString("Transferred funds from %d %@. Outputs for %d %@ were too small.", comment: "")
        public static let  BC_STRING_PAYMENT_ASK_TO_ARCHIVE_TRANSFERRED_ADDRESSES = NSLocalizedString("Would you like to archive the addresses used?", comment: "")
        public static let  BC_STRING_PAYMENT_RECEIVED = NSLocalizedString("Payment Received", comment: "")
        public static let  BC_STRING_ERROR_COPYING_TO_CLIPBOARD = NSLocalizedString("An error occurred while copying your address to the clipboard. Please re-select the destination address or restart the app and try again.", comment: "")
        public static let  BC_STRING_TRADE_COMPLETED = NSLocalizedString("Trade Completed", comment: "")
        public static let  BC_STRING_THE_TRADE_YOU_CREATED_ON_DATE_ARGUMENT_HAS_BEEN_COMPLETED = NSLocalizedString("The trade you created on %@ has been completed!", comment: "")
        public static let  BC_STRING_VIEW_DETAILS = NSLocalizedString("View details", comment: "")
        public static let  BC_STRING_BUY_WEBVIEW_ERROR_MESSAGE = NSLocalizedString("Something went wrong, please try reopening Buy & Sell Bitcoin again.", comment: "")
        public static let  BC_STRING_CONFIRM_PAYMENT = NSLocalizedString("Confirm Payment", comment: "")
        public static let  BC_STRING_ADJUST_FEE = NSLocalizedString("Adjust Fee", comment: "")
        public static let  BC_STRING_ASK_TO_ADD_TO_ADDRESS_BOOK = NSLocalizedString("Would you like to add the bitcoin address %@ to your address book?", comment: "")
        public static let  BC_STRING_ARGUMENT_COPIED_TO_CLIPBOARD = NSLocalizedString("%@ copied to clipboard", comment: "")
        public static let  BC_STRING_SEND_FROM = NSLocalizedString("Send from...", comment: "")
        public static let  BC_STRING_SEND_TO = NSLocalizedString("Send to...", comment: "")
        public static let  BC_STRING_RECEIVE_TO = NSLocalizedString("Receive to...", comment: "")
        public static let  BC_STRING_WHERE = NSLocalizedString("Where", comment: "")
        public static let  BC_STRING_SEND_TO_ADDRESS = NSLocalizedString("Send to address", comment: "")
        public static let  BC_STRING_YOU_MUST_ENTER_A_LABEL = NSLocalizedString("You must enter a label", comment: "")
        public static let  BC_STRING_LABEL_MUST_HAVE_LESS_THAN_18_CHAR = NSLocalizedString("Label must have less than 18 characters", comment: "")
        public static let  BC_STRING_LABEL_MUST_BE_ALPHANUMERIC = NSLocalizedString("Label must contain letters and numbers only", comment: "")
        public static let  BC_STRING_UNARCHIVE = NSLocalizedString("Unarchive", comment: "")
        public static let  BC_STRING_ARCHIVE = NSLocalizedString("Archive", comment: "")
        public static let  BC_STRING_ARCHIVING_ADDRESSES = NSLocalizedString("Archiving addresses", comment: "")
        public static let  BC_STRING_ARCHIVED = NSLocalizedString("Archived", comment: "")
        public static let  BC_STRING_NO_LABEL = NSLocalizedString("No Label", comment: "")
        public static let  BC_STRING_TRANSACTIONS_COUNT = NSLocalizedString("%d Transactions", comment: "")
        public static let  BC_STRING_LOADING_EXTERNAL_PAGE = NSLocalizedString("Loading External Page", comment: "")
        public static let  BC_STRING_PASSWORD_NOT_STRONG_ENOUGH = NSLocalizedString("Your password is not strong enough. Please choose a different password.", comment: "")
        public static let  BC_STRING_PASSWORD_MUST_BE_LESS_THAN_OR_EQUAL_TO_255_CHARACTERS = NSLocalizedString("Password must be less than or equal to 255 characters", comment: "")
        public static let  BC_STRING_PASSWORDS_DO_NOT_MATCH = NSLocalizedString("Passwords do not match", comment: "")
        public static let  BC_STRING_PASSWORD_MUST_BE_DIFFERENT_FROM_YOUR_EMAIL = NSLocalizedString("Password must be different from your email", comment: "")
        public static let  BC_STRING_NEW_PASSWORD_MUST_BE_DIFFERENT = NSLocalizedString("New password must be different", comment: "")
        public static let  BC_STRING_PLEASE_PROVIDE_AN_EMAIL_ADDRESS = NSLocalizedString("Please provide an email address.", comment: "")
        public static let  BC_STRING_PLEASE_VERIFY_EMAIL_ADDRESS_FIRST = NSLocalizedString("Please verify your email address first.", comment: "")
        public static let  BC_STRING_PLEASE_VERIFY_MOBILE_NUMBER_FIRST = NSLocalizedString("Please verify your mobile number first.", comment: "")
        public static let  BC_STRING_INVALID_EMAIL_ADDRESS = NSLocalizedString("Invalid email address.", comment: "")
        public static let  BC_STRING_MY_BITCOIN_WALLET = NSLocalizedString("My Bitcoin Wallet", comment: "")
        public static let  BC_STRING_PASSWORD_STRENGTH_WEAK = NSLocalizedString("Weak", comment: "")
        public static let  BC_STRING_PASSWORD_STRENGTH_REGULAR = NSLocalizedString("Regular", comment: "")
        public static let  BC_STRING_PASSWORD_STRENGTH_NORMAL = NSLocalizedString("Normal", comment: "")
        public static let  BC_STRING_PASSWORD_STRENGTH_STRONG = NSLocalizedString("Strong", comment: "")
        public static let  BC_STRING_UNCONFIRMED = NSLocalizedString("Unconfirmed", comment: "")
        public static let  BC_STRING_COUNT_CONFIRMATIONS = NSLocalizedString("%d Confirmations", comment: "")
        public static let  BC_STRING_ARGUMENT_CONFIRMATIONS = NSLocalizedString("%@ Confirmations", comment: "")
        public static let  BC_STRING_TRANSFERRED = NSLocalizedString("Transferred", comment: "")
        public static let  BC_STRING_RECEIVED = NSLocalizedString("Received", comment: "")
        public static let  BC_STRING_SENT = NSLocalizedString("Sent", comment: "")
        public static let  BC_STRING_ERROR = NSLocalizedString("Error", comment: "")
        public static let  BC_STRING_LEARN_MORE = NSLocalizedString("Learn More", comment: "")
        public static let  BC_STRING_IMPORT_PRIVATE_KEY = NSLocalizedString("Import Private Key", comment: "")
        public static let  BC_STRING_DECRYPTING_PRIVATE_KEY = NSLocalizedString("Decrypting Private Key", comment: "")
        public static let  BC_STRING_EXTENDED_PUBLIC_KEY = NSLocalizedString("Extended Public Key", comment: "")
        public static let  BC_STRING_SCAN_PAIRING_CODE = NSLocalizedString("Scan Pairing Code", comment: "")
        public static let  BC_STRING_PARSING_PAIRING_CODE = NSLocalizedString("Parsing Pairing Code", comment: "")
        public static let  BC_STRING_INVALID_PAIRING_CODE = NSLocalizedString("Invalid Pairing Code", comment: "")
        public static let  BC_STRING_INSUFFICIENT_FUNDS = NSLocalizedString("Insufficient Funds", comment: "")
        public static let  BC_STRING_PLEASE_SELECT_DIFFERENT_ADDRESS = NSLocalizedString("Please select a different address to send from.", comment: "")
        public static let  BC_STRING_OK = NSLocalizedString("OK", comment: "")
        public static let  BC_STRING_OPEN_MAIL_APP = NSLocalizedString("Open Mail App", comment: "")
        public static let  BC_STRING_CANNOT_OPEN_MAIL_APP = NSLocalizedString("Cannot open Mail App", comment: "")
        //static let  BC_STRING_REQUEST_FAILED_PLEASE_CHECK_INTERNET_CONNECTION = NSLocalizedString("Request failed. Please check your internet connection.", comment: "")
        public static let  BC_STRING_SOMETHING_WENT_WRONG_CHECK_INTERNET_CONNECTION = NSLocalizedString("An error occurred while updating your spendable balance. Please check your internet connection and try again.", comment: "")
        public static let  BC_STRING_EMPTY_RESPONSE = NSLocalizedString("Empty response from server.", comment: "")
        public static let  BC_STRING_FORGET_WALLET = NSLocalizedString("Forget Wallet", comment: "")
        public static let  BC_STRING_CLOSE_APP = NSLocalizedString("Close App", comment: "")
        public static let  BC_STRING_INVALID_GUID = NSLocalizedString("Invalid Wallet ID", comment: "")
        public static let  BC_STRING_ENTER_YOUR_CHARACTER_WALLET_IDENTIFIER = NSLocalizedString("Please enter your 36 character wallet identifier correctly. It can be found in the welcome email on startup.", comment: "")
        public static let  BC_STRING_INVALID_IDENTIFIER = NSLocalizedString("Invalid Identifier", comment: "")
        public static let  BC_STRING_DISABLE_TWO_FACTOR = NSLocalizedString("You must have two-factor authentication disabled to pair manually.", comment: "")
        public static let  BC_STRING_WATCH_ONLY = NSLocalizedString("Watch Only", comment: "")
        public static let  BC_STRING_WATCH_ONLY_RECEIVE_WARNING = NSLocalizedString("You are about to receive bitcoin to a watch-only address. You can only spend these funds if you have access to the private key. Continue?", comment: "")
        public static let  BC_STRING_USER_DECLINED = NSLocalizedString("User Declined", comment: "")
        public static let  BC_STRING_CHANGE_PIN = NSLocalizedString("Change PIN", comment: "")
        public static let  BC_STRING_ADDRESS = NSLocalizedString("Address", comment: "")
        public static let  BC_STRING_BITCOIN_ADDRESSES = NSLocalizedString("Bitcoin Addresses", comment: "")
        public static let  BC_STRING_ADDRESSES = NSLocalizedString("Addresses", comment: "")
        public static let  BC_STRING_SETTINGS = NSLocalizedString("Settings", comment: "")
        public static let  BC_STRING_BACKUP = NSLocalizedString("Backup", comment: "")
        public static let  BC_STRING_START_BACKUP = NSLocalizedString("START BACKUP", comment: "")
        public static let  BC_STRING_BACKUP_NEEDED = NSLocalizedString("Backup Needed", comment: "")
        public static let  BC_STRING_ADD_EMAIL = NSLocalizedString("Add Email", comment: "")
        public static let  BC_STRING_BUY_AND_SELL_BITCOIN = NSLocalizedString("Buy & Sell Bitcoin", comment: "")
        public static let  BC_STRING_WARNING = NSLocalizedString("Warning!!!", comment: "")
        public static let  BC_STRING_NEXT = NSLocalizedString("Next", comment: "")
        public static let  BC_STRING_CANCEL = NSLocalizedString("Cancel", comment: "")
        public static let  BC_STRING_DISMISS = NSLocalizedString("Dismiss", comment: "")
        public static let  BC_STRING_DELETE = NSLocalizedString("Delete", comment: "")
        public static let  BC_STRING_CONFIRM = NSLocalizedString("Confirm", comment: "")
        public static let  BC_STRING_CANCELLING = NSLocalizedString("Cancelling", comment: "")
        public static let  BC_STRING_HOW_WOULD_YOU_LIKE_TO_PAIR = NSLocalizedString("How would you like to pair?", comment: "")
        public static let  BC_STRING_MANUALLY = NSLocalizedString("Manually", comment: "")
        public static let  BC_STRING_AUTOMATICALLY = NSLocalizedString("Automatically", comment: "")
        public static let  BC_STRING_ENTER_PIN = NSLocalizedString("Enter PIN", comment: "")
        public static let  BC_STRING_PLEASE_ENTER_PIN = NSLocalizedString("Please enter your PIN", comment: "")
        public static let  BC_STRING_PLEASE_ENTER_NEW_PIN = NSLocalizedString("Please enter a new PIN", comment: "")
        public static let  BC_STRING_CONFIRM_PIN = NSLocalizedString("Confirm your PIN", comment: "")
        public static let  BC_STRING_WARNING_TITLE = NSLocalizedString("Warning", comment: "")
        public static let  BC_STRING_PAYMENT_REQUEST_BITCOIN_ARGUMENT_ARGUMENT = NSLocalizedString("Please send %@ to bitcoin address.\n%@", comment: "")
        public static let  BC_STRING_PAYMENT_REQUEST_BITCOIN_CASH_ARGUMENT = NSLocalizedString("Please send BCH to the Bitcoin Cash address\n%@", comment: "")
        public static let  BC_STRING_AMOUNT = NSLocalizedString("Amount", comment: "")
        public static let  BC_STRING_PAYMENT_REQUEST_HTML = NSLocalizedString("Please send payment to bitcoin address (<a href=\"https://blockchain.info/wallet/bitcoin-faq\">help?</a>): %@", comment: "")
        public static let  BC_STRING_CLOSE = NSLocalizedString("Close", comment: "")
        public static let  BC_STRING_TRANSACTION_DETAILS = NSLocalizedString("Transaction details", comment: "")
        public static let  BC_STRING_CREATE = NSLocalizedString("Create", comment: "")
        public static let  BC_STRING_NAME = NSLocalizedString("Name", comment: "")
        public static let  BC_STRING_EDIT = NSLocalizedString("Edit", comment: "")
        public static let  BC_STRING_LABEL = NSLocalizedString("Label", comment: "")
        public static let  BC_STRING_DONE = NSLocalizedString("Done", comment: "")
        public static let  BC_STRING_SAVE = NSLocalizedString("Save", comment: "")
        public static let  BC_STRING_CREATE_WALLET = NSLocalizedString("Create Wallet", comment: "")
        public static let  BC_STRING_ACCOUNTS = NSLocalizedString("Accounts", comment: "")
        public static let  BC_STRING_TOTAL_BALANCE = NSLocalizedString("Total Balance", comment: "")
        public static let  BC_STRING_IMPORTED_ADDRESSES = NSLocalizedString("Imported Addresses", comment: "")
        public static let  BC_STRING_IMPORTED_ADDRESSES_ARCHIVED = NSLocalizedString("Imported Addresses (Archived)", comment: "")
        public static let  BC_STRING_UPGRADE_TO_V3 = NSLocalizedString("Upgrade to V3", comment: "")
        public static let  BC_STRING_ADDRESS_BOOK = NSLocalizedString("Address book", comment: "")
        public static let  BC_STRING_LOADING_LOADING_TRANSACTIONS = NSLocalizedString("Loading transactions", comment: "")
        public static let  BC_STRING_LOADING_CHECKING_WALLET_UPDATES = NSLocalizedString("Checking for Wallet updates", comment: "")
        public static let  BC_STRING_LOADING_CREATING_V3_WALLET = NSLocalizedString("Creating V3 Wallet", comment: "")
        public static let  BC_STRING_LOADING_CREATING = NSLocalizedString("Creating", comment: "")
        public static let  BC_STRING_LOADING_CREATING_NEW_ADDRESS = NSLocalizedString("Creating new address", comment: "")
        public static let  BC_STRING_LOADING_CREATING_REQUEST = NSLocalizedString("Creating request", comment: "")
        public static let  BC_STRING_LOADING_CREATING_INVITATION = NSLocalizedString("Creating invitation", comment: "")
        public static let  BC_STRING_IDENTIFIER = NSLocalizedString("Identifier", comment: "")
        public static let  BC_STRING_OPEN_ARGUMENT = NSLocalizedString("Open %@?", comment: "")
        public static let  BC_STRING_LEAVE_APP = NSLocalizedString("You will be leaving the app.", comment: "")
        public static let  BC_STRING_TERMS_OF_SERVICE = NSLocalizedString("Terms of Service", comment: "")
        public static let  BC_STRING_TRANSACTION = NSLocalizedString("Transaction", comment: "")
        public static let  BC_STRING_AUTOMATIC_PAIRING = NSLocalizedString("Automatic Pairing", comment: "")
        public static let  BC_STRING_INCORRECT_PASSWORD = NSLocalizedString("Incorrect password", comment: "")
        public static let  BC_STRING_CREATE_A_WALLET = NSLocalizedString("Create a Wallet", comment: "")
        public static let  BC_STRING_REQUEST_AMOUNT = NSLocalizedString("Request Amount", comment: "")
        public static let  BC_STRING_REQUEST = NSLocalizedString("Request", comment: "")
        public static let  BC_STRING_LABEL_ADDRESS = NSLocalizedString("Label Address", comment: "")
        public static let  BC_STRING_SCAN_PRIVATE_KEY = NSLocalizedString("Scan Private Key", comment: "")
        public static let  BC_STRING_IMPORT_ADDRESS = NSLocalizedString("Import address", comment: "")
        public static let  BC_STRING_CONTINUE = NSLocalizedString("Continue", comment: "")
        public static let  BC_STRING_LOG_IN = NSLocalizedString("Log In", comment: "")
        public static let  BC_STRING_PASSWORD_MODAL_INSTRUCTIONS = NSLocalizedString("Please enter your password to log into your Blockchain wallet.", comment: "")
        public static let  BC_STRING_OR_START_OVER_AND = NSLocalizedString("Or start over and ", comment: "")
        public static let  BC_STRING_COPY_ADDRESS = NSLocalizedString("Copy Address", comment: "")
        public static let  BC_STRING_ARCHIVE_ADDRESS = NSLocalizedString("Archive Address", comment: "")
        public static let  BC_STRING_UNARCHIVE_ADDRESS = NSLocalizedString("Unarchive Address", comment: "")
        public static let  BC_STRING_AT_LEAST_ONE_ACTIVE_ADDRESS = NSLocalizedString("You must leave at least one active address", comment: "")
        public static let  BC_STRING_LOGOUT_AND_FORGET_WALLET = NSLocalizedString("Logout and forget wallet", comment: "")
        public static let  BC_STRING_SURVEY_ALERT_TITLE = NSLocalizedString("Would you like to tell us about your experience with Blockchain?", comment: "")
        public static let  BC_STRING_SURVEY_ALERT_MESSAGE = NSLocalizedString("You will be leaving the app.", comment: "")
        public static let  BC_STRING_INVALID_BITCOIN_ADDRESS_ARGUMENT = NSLocalizedString("Invalid Bitcoin address: %@", comment: "")
        public static let  BC_STRING_UPDATE = NSLocalizedString("Update", comment: "")
        public static let  BC_STRING_DISABLED = NSLocalizedString("Disabled", comment: "")
        public static let  BC_STRING_REMINDER_CHECK_EMAIL_TITLE = NSLocalizedString("Check Your Inbox", comment: "")
        public static let  BC_STRING_CONTINUE_TO_MAIL = NSLocalizedString("Continue To Mail", comment: "")
        public static let  BC_STRING_REMINDER_CHECK_EMAIL_MESSAGE = NSLocalizedString("Look for an email from Blockchain and click the verification link to complete your wallet setup.", comment: "")
        public static let  BC_STRING_REMINDER_BACKUP_TITLE = NSLocalizedString("Backup Your Funds", comment: "")
        public static let  BC_STRING_REMINDER_BACKUP_NOW = NSLocalizedString("Backup Now", comment: "")
        public static let  BC_STRING_REMINDER_TWO_FACTOR_TITLE = NSLocalizedString("2-Step Verification", comment: "")
        public static let  BC_STRING_REMINDER_TWO_FACTOR_MESSAGE = NSLocalizedString("Prevent unauthorized access to your wallet. Enable 2-step verification to increase wallet security.", comment: "")
        public static let  BC_STRING_SETTINGS_ACCOUNT_DETAILS = NSLocalizedString("Account Details", comment: "")
        public static let  BC_STRING_SETTINGS_NOTIFICATIONS = NSLocalizedString("Notifications", comment: "")
        public static let  BC_STRING_SETTINGS_EMAIL = NSLocalizedString("Email", comment: "")
        public static let  BC_STRING_SETTINGS_UPDATE_EMAIL = NSLocalizedString("Update Email", comment: "")
        public static let  BC_STRING_SETTINGS_ENTER_EMAIL_ADDRESS = NSLocalizedString("Enter Email Address", comment: "")
        public static let  BC_STRING_SETTINGS_VERIFIED = NSLocalizedString("Verified", comment: "")
        public static let  BC_STRING_SETTINGS_UNVERIFIED = NSLocalizedString("Unverified", comment: "")
        public static let  BC_STRING_SETTINGS_UNCONFIRMED = NSLocalizedString("Unconfirmed", comment: "")
        public static let  BC_STRING_SETTINGS_STORED = NSLocalizedString("Stored", comment: "")
        public static let  BC_STRING_SETTINGS_NOT_STORED = NSLocalizedString("Not Stored", comment: "")
        public static let  BC_STRING_SETTINGS_PLEASE_ADD_EMAIL = NSLocalizedString("Please add an email address", comment: "")
        public static let  BC_STRING_SETTINGS_NEW_EMAIL_MUST_BE_DIFFERENT = NSLocalizedString("New email must be different", comment: "")
        public static let  BC_STRING_SETTINGS_MOBILE_NUMBER = NSLocalizedString("Mobile Number", comment: "")
        public static let  BC_STRING_SETTINGS_UPDATE_MOBILE = NSLocalizedString("Update Mobile", comment: "")
        public static let  BC_STRING_SETTINGS_ENTER_MOBILE_NUMBER = NSLocalizedString("Enter Mobile Number", comment: "")
        public static let  BC_STRING_SETTINGS_PREFERENCES = NSLocalizedString("Preferences", comment: "")
        public static let  BC_STRING_SETTINGS_DISPLAY_PREFERENCES = NSLocalizedString("Display", comment: "")
        public static let  BC_STRING_SETTINGS_FEES = NSLocalizedString("Fees", comment: "")
        public static let  BC_STRING_SETTINGS_FEE_PER_KB = NSLocalizedString("Fee per KB", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY = NSLocalizedString("Security", comment: "")
        public static let  BC_STRING_SETTINGS_PIN_SWIPE_TO_RECEIVE = NSLocalizedString("Swipe to Receive", comment: "")
        public static let  BC_STRING_SWIPE_TO_RECEIVE_NO_INTERNET_CONNECTION_WARNING = NSLocalizedString("We can't check whether this address has been used. Show anyway?", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION = NSLocalizedString("2-step Verification", comment: "")
        public static let  BC_STRING_ENABLE = NSLocalizedString("Enable", comment: "")
        public static let  BC_STRING_DISABLE = NSLocalizedString("Disable", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_MUST_DISABLE_TWO_FACTOR_SMS_ARGUMENT = NSLocalizedString("You must disable SMS 2-Step Verification before changing your mobile number (%@).", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED_ARGUMENT = NSLocalizedString("2-step Verification is currently enabled for %@.", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_ENABLED = NSLocalizedString("2-step Verification is currently enabled.", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_DISABLED = NSLocalizedString("2-step Verification is currently disabled.", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_MESSAGE_SMS_ONLY = NSLocalizedString("You can enable 2-step Verification via SMS on your mobile phone. In order to use other authentication methods instead, please login to our web wallet.", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_GOOGLE = NSLocalizedString("Google Authenticator", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_YUBI_KEY = NSLocalizedString("Yubi Key", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_TWO_STEP_VERIFICATION_SMS = NSLocalizedString("SMS", comment: "")
        public static let  BC_STRING_UNKNOWN = NSLocalizedString("Unknown", comment: "")
        public static let  BC_STRING_ENTER_ARGUMENT_TWO_FACTOR_CODE = NSLocalizedString("Please enter your %@ 2FA code", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_CHANGE_PASSWORD = NSLocalizedString("Change Password", comment: "")
        public static let  BC_STRING_SETTINGS_SECURITY_PASSWORD_CHANGED = NSLocalizedString("Password changed. Please login to continue.", comment: "")
        public static let  BC_STRING_SETTINGS_LOCAL_CURRENCY = NSLocalizedString("Local Currency", comment: "")
        public static let  BC_STRING_SETTINGS_BTC = NSLocalizedString("Bitcoin Unit", comment: "")
        public static let  BC_STRING_SETTINGS_EMAIL_NOTIFICATIONS = NSLocalizedString("Email Notifications", comment: "")
        public static let  BC_STRING_SETTINGS_SMS_NOTIFICATIONS = NSLocalizedString("SMS Notifications", comment: "")
        public static let  BC_STRING_SETTINGS_PUSH_NOTIFICATIONS = NSLocalizedString("Push Notifications", comment: "")
        public static let  BC_STRING_SETTINGS_NOTIFICATIONS_SMS = NSLocalizedString("SMS", comment: "")
        public static let  BC_STRING_SETTINGS_EMAIL_PROMPT = NSLocalizedString("Your verified email address is used to send payment alerts, ID reminders, and login codes.", comment: "")
        public static let  BC_STRING_SETTINGS_SMS_PROMPT = NSLocalizedString("Your mobile phone can be used to enable two-factor authentication or to receive alerts.", comment: "")
        public static let  BC_STRING_SETTINGS_NOTIFICATIONS_FOOTER = NSLocalizedString("Enable notifications to receive an email or SMS message whenever you receive bitcoin.", comment: "")
        public static let  BC_STRING_SETTINGS_SWIPE_TO_RECEIVE_IN_FIVES_FOOTER = NSLocalizedString("Enable this option to reveal a receive address when you swipe left on the PIN screen, making receiving bitcoin even faster. Five addresses will be loaded consecutively, after which logging in is required to show new addresses.", comment: "")
        public static let  BC_STRING_SETTINGS_SWIPE_TO_RECEVE_IN_SINGLES_FOOTER = NSLocalizedString("Enable this option to reveal a receive address when you swipe left on the PIN screen, making receiving bitcoin even faster. Only one address will be loaded, logging in is required to show a new address.", comment: "")
        public static let  BC_STRING_SETTINGS_ABOUT = NSLocalizedString("About", comment: "")
        public static let  BC_STRING_SETTINGS_ABOUT_US = NSLocalizedString("About Us", comment: "")
        public static let  BC_STRING_SETTINGS_PRIVACY_POLICY = NSLocalizedString("Privacy Policy", comment: "")
        public static let  BC_STRING_SETTINGS_TERMS_OF_SERVICE = NSLocalizedString("Terms of Service", comment: "")
        public static let  BC_STRING_SETTINGS_COOKIE_POLICY = NSLocalizedString("Cookies Policy", comment: "")
        public static let  BC_STRING_SETTINGS_VERIFY = NSLocalizedString("Verify", comment: "")
        public static let  BC_STRING_SETTINGS_SENT_TO_ARGUMENT = NSLocalizedString("Sent to %@", comment: "")
        public static let  BC_STRING_SETTINGS_VERIFY_MOBILE_SEND = NSLocalizedString("Send verification SMS", comment: "")
        public static let  BC_STRING_SETTINGS_VERIFY_MOBILE_RESEND = NSLocalizedString("Resend verification SMS", comment: "")
        public static let  BC_STRING_SETTINGS_VERIFY_ENTER_CODE = NSLocalizedString("Enter your verification code", comment: "")
        public static let  BC_STRING_ENTER_VERIFICATION_CODE = NSLocalizedString("Enter Verification Code", comment: "")
        public static let  BC_STRING_SETTINGS_VERIFY_EMAIL_RESEND = NSLocalizedString("Resend verification email", comment: "")
        public static let  BC_STRING_SETTINGS_VERIFY_INVALID_CODE = NSLocalizedString("Invalid verification code. Please try again.", comment: "")
        public static let  BC_STRING_SETTINGS_CHANGE_EMAIL = NSLocalizedString("Change Email", comment: "")
        public static let  BC_STRING_SETTINGS_NEW_EMAIL_ADDRESS = NSLocalizedString("New Email Address", comment: "")
        public static let  BC_STRING_SETTINGS_NEW_EMAIL_ADDRESS_WARNING_DISABLE_NOTIFICATIONS = NSLocalizedString("You currently have email notifications enabled. Changing your email will disable email notifications.", comment: "")
        public static let  BC_STRING_SETTINGS_EMAIL_VERIFIED = NSLocalizedString("Your email has been verified.", comment: "")
        public static let  BC_STRING_SETTINGS_WALLET_ID = NSLocalizedString("Wallet ID", comment: "")
        public static let  BC_STRING_SETTINGS_PROFILE = NSLocalizedString("Profile", comment: "")
        public static let  BC_STRING_SETTINGS_CHANGE_MOBILE_NUMBER = NSLocalizedString("Change Mobile Number", comment: "")
        public static let  BC_STRING_SETTINGS_NEW_MOBILE_NUMBER = NSLocalizedString("New Mobile Number", comment: "")
        public static let  BC_STRING_SETTINGS_NEW_MOBILE_NUMBER_WARNING_DISABLE_NOTIFICATIONS = NSLocalizedString("You currently have SMS notifications enabled. Changing your email will disable SMS notifications.", comment: "")
        public static let  BC_STRING_SETTINGS_ERROR_INVALID_MOBILE_NUMBER = NSLocalizedString("Invalid mobile number.", comment: "")
        public static let  BC_STRING_SETTINGS_MOBILE_NUMBER_VERIFIED = NSLocalizedString("Your mobile number has been verified.", comment: "")
        public static let  BC_STRING_SETTINGS_ERROR_LOADING_TITLE = NSLocalizedString("Error loading settings", comment: "")
        public static let  BC_STRING_SETTINGS_ERROR_LOADING_MESSAGE = NSLocalizedString("Please check your internet connection.", comment: "")
        public static let  BC_STRING_SETTINGS_ERROR_UPDATING_TITLE = NSLocalizedString("Error updating settings", comment: "")
        public static let  BC_STRING_SETTINGS_CHANGE_FEE_TITLE = NSLocalizedString("Change fee per kilobyte", comment: "")
        public static let  BC_STRING_SETTINGS_CHANGE_FEE_MESSAGE_ARGUMENT = NSLocalizedString("Current rate: %@ BTC", comment: "")
        public static let  BC_STRING_SETTINGS_FEE_ARGUMENT_BTC = NSLocalizedString("%@ BTC", comment: "")
        public static let  BC_STRING_SETTINGS_FEE_TOO_HIGH = NSLocalizedString("Fee is too high (0.01 BTC limit)", comment: "")
        public static let  BC_STRING_SETTINGS_COPY_GUID = NSLocalizedString("Copy Wallet ID", comment: "")
        public static let  BC_STRING_SETTINGS_COPY_GUID_WARNING = NSLocalizedString("Warning: Your wallet identifier is sensitive information. Copying it may compromise the security of your wallet.", comment: "")
        public static let  BC_STRING_COPY_TO_CLIPBOARD = NSLocalizedString("Copy to clipboard", comment: "")
        public static let  BC_STRING_WARNING_FOR_ZERO_FEE = NSLocalizedString("Transactions with no fees may take a long time to confirm or may not be confirmed at all. Would you like to continue?", comment: "")
        public static let  BC_STRING_SETTINGS_ERROR_FEE_OUT_OF_RANGE = NSLocalizedString("Please enter a fee greater than 0 BTC and at most 0.01 BTC", comment: "")
        public static let  BC_STRING_VERIFY_EMAIL = NSLocalizedString("Verify Email", comment: "")
        public static let  BC_STRING_EMAIL_VERIFIED = NSLocalizedString("Email Verified", comment: "")
        public static let  BC_STRING_BACKUP_PHRASE = NSLocalizedString("Backup Phrase", comment: "")
        public static let  BC_STRING_WALLET_RECOVERY_PHRASE = NSLocalizedString("Recovery Phrase", comment: "")
        public static let  BC_STRING_PHRASE_BACKED = NSLocalizedString("Phrase Backed", comment: "")
        public static let  BC_STRING_LINK_MOBILE = NSLocalizedString("Link Mobile", comment: "")
        public static let  BC_STRING_MOBILE_LINKED = NSLocalizedString("Mobile Linked", comment: "")
        public static let  BC_STRING_TWO_STEP_ENABLED_SUCCESS = NSLocalizedString("2-Step has been enabled for SMS.", comment: "")
        public static let  BC_STRING_TWO_STEP_DISABLED_SUCCESS = NSLocalizedString("2-Step has been disabled.", comment: "")
        public static let  BC_STRING_TWO_STEP_ERROR = NSLocalizedString("An error occurred while changing 2-Step verification.", comment: "")
        public static let  BC_STRING_TWO_STEP_ENABLED = NSLocalizedString("2-Step Enabled", comment: "")
        public static let  BC_STRING_ENABLE_TWO_STEP = NSLocalizedString("Enable 2-Step", comment: "")
        public static let  BC_STRING_ENABLE_TWO_STEP_SMS = NSLocalizedString("Enable 2-Step for SMS", comment: "")
        public static let  BC_STRING_NEW_ADDRESS = NSLocalizedString("New Address", comment: "")
        public static let  BC_STRING_NEW_ADDRESS_SCAN_QR_CODE = NSLocalizedString("Scan QR code", comment: "")
        public static let  BC_STRING_NEW_ADDRESS_CREATE_NEW = NSLocalizedString("Create new address", comment: "")
        public static let  BC_STRING_SEARCH = NSLocalizedString("Search", comment: "")
        public static let  BC_STRING_TOTAL = NSLocalizedString("Total", comment: "")
        public static let  BC_STRING_SENDING = NSLocalizedString("Sending", comment: "")
        public static let  BC_STRING_RECOVERY_PHRASE_ERROR_INSTRUCTIONS = NSLocalizedString("Please enter your recovery phrase with words separated by spaces", comment: "")
        public static let  BC_STRING_LOADING_RECOVERING_WALLET = NSLocalizedString("Recovering Funds", comment: "")
        public static let  BC_STRING_LOADING_RECOVERING_WALLET_CHECKING_ARGUMENT_OF_ARGUMENT = NSLocalizedString("Checking for more: Step %d of %d", comment: "")
        public static let  BC_STRING_LOADING_RECOVERING_WALLET_ARGUMENT_FUNDS_ARGUMENT = NSLocalizedString("Found %d, with %@", comment: "")
        public static let  BC_STRING_INVALID_RECOVERY_PHRASE = NSLocalizedString("Invalid recovery phrase. Please try again", comment: "")
        public static let  BC_STRING_SEND_ERROR_NO_INTERNET_CONNECTION = NSLocalizedString("No internet connection available. Please check your network settings.", comment: "")
        public static let  BC_STRING_SEND_ERROR_FEE_TOO_LOW = NSLocalizedString("The fee you have specified is too low.", comment: "")
        public static let  BC_STRING_HIGH_FEE_WARNING_TITLE = NSLocalizedString("Large Transaction", comment: "")
        public static let  BC_STRING_HIGH_FEE_WARNING_MESSAGE = NSLocalizedString("This is an oversized bitcoin transaction. Your wallet needs to consolidate many smaller payments you've received in the past. This requires a relatively high fee in order to be confirmed quickly. If it’s fine for the transaction to take longer to confirm, you can reduce the fee manually by tapping \"Customize Fee.\"", comment: "")
        public static let  BC_STRING_NO_EMAIL_CONFIGURED = NSLocalizedString("You do not have an account set up for Mail. Please contact %@", comment: "")
        public static let  BC_STRING_PIN = NSLocalizedString("PIN", comment: "")
        public static let  BC_STRING_MAKE_DEFAULT = NSLocalizedString("Make Default", comment: "")
        public static let  BC_STRING_DEFAULT = NSLocalizedString("Default", comment: "")
        public static let  BC_STRING_TRANSFER_FUNDS = NSLocalizedString("Transfer Funds", comment: "")
        public static let  BC_STRING_TRANSFER_AMOUNT = NSLocalizedString("Transfer Amount", comment: "")
        public static let  BC_STRING_FEE = NSLocalizedString("Fee", comment: "")
        public static let  BC_STRING_TRANSFER_FUNDS_DESCRIPTION_ONE = NSLocalizedString("For your safety, we recommend you to transfer any balances in your imported addresses into your Blockchain wallet.", comment: "")
        public static let  BC_STRING_TRANSFER_FUNDS_DESCRIPTION_TWO = NSLocalizedString("Your transferred funds will be safe and secure, and you'll benefit from increased privacy and convenient backup and recovery features.", comment: "")
        public static let  BC_STRING_ARCHIVE_FOOTER_TITLE = NSLocalizedString("Archive this if you do NOT want to use it anymore. Your funds will remain safe, and you can unarchive it at any time.", comment: "")
        public static let  BC_STRING_ARCHIVED_FOOTER_TITLE = NSLocalizedString("This is archived. Though you cannot send funds from here, any and all funds will remain safe. Simply unarchive to start using it again.", comment: "")
        public static let  BC_STRING_TRANSFER_FOOTER_TITLE = NSLocalizedString("For your safety, we recommend you to transfer any balances in your imported addresses into your Blockchain wallet.", comment: "")
        public static let  BC_STRING_EXTENDED_PUBLIC_KEY_FOOTER_TITLE = NSLocalizedString("Keep your xPub private. Someone with access to your xPub will be able to see all of your funds and transactions.", comment: "")
        public static let  BC_STRING_EXTENDED_PUBLIC_KEY_WARNING = NSLocalizedString("Sharing your xPub authorizes others to track your transaction history. As authorized persons may be able to disrupt you from accessing your wallet, only share your xPub with people you trust.", comment: "")
        public static let  BC_STRING_WATCH_ONLY_FOOTER_TITLE = NSLocalizedString("This is a watch-only address. To spend your funds from this wallet, please scan your private key.", comment: "")
        public static let  BC_STRING_SET_DEFAULT_ACCOUNT = NSLocalizedString("Set as Default?", comment: "")
        public static let  BC_STRING_AT_LEAST_ONE_ADDRESS_REQUIRED = NSLocalizedString("You must have at least one active address", comment: "")
        public static let  BC_STRING_EXTENDED_PUBLIC_KEY_DETAIL_HEADER_TITLE = NSLocalizedString("Your xPub is an advanced feature that contains all of your public addresses.", comment: "")
        public static let  BC_STRING_COPY_XPUB = NSLocalizedString("Copy xPub", comment: "")
        public static let  BC_STRING_IMPORTED_PRIVATE_KEY_TO_OTHER_ADDRESS_ARGUMENT = NSLocalizedString("You've successfully imported the private key for ​the address %@, and you can now spend from it. If you want to spend from this address, make sure you scan the correct private key.", comment: "")
        public static let  BC_STRING_VERIFICATION_EMAIL_SENT_TO_ARGUMENT = NSLocalizedString("Verification email has been sent to %@.", comment: "")
        public static let  BC_STRING_PLEASE_CHECK_AND_CLICK_EMAIL_VERIFICATION_LINK = NSLocalizedString("Please check your email and click on the verification link.", comment: "")
        public static let  BC_STRING_ERROR_PLEASE_REFRESH_PAIRING_CODE = NSLocalizedString("Please refresh the pairing code and try again.", comment: "")
        
        public static let  BC_STRING_NOT_NOW = NSLocalizedString("Not Now", comment: "")
        public static let  BC_STRING_ILL_DO_THIS_LATER = NSLocalizedString("I'll do this later", comment: "")
        public static let  BC_STRING_PRIVATE_KEY_NEEDED_MESSAGE_ARGUMENT = NSLocalizedString("This action requires the private key for the Bitcoin address %@. Please scan the QR code.", comment: "")
        public static let  BC_STRING_ENTER_ARGUMENT_AMOUNT = NSLocalizedString("Enter %@ amount", comment: "")
        public static let  BC_STRING_RETRIEVING_RECOMMENDED_FEE = NSLocalizedString("Retrieving recommended fee", comment: "")
        public static let  BC_STRING_FEE_HIGHER_THAN_RECOMMENDED_ARGUMENT_SUGGESTED_ARGUMENT = NSLocalizedString("You specified an unusually high transaction fee of %@. Even if you lower the fee to %@, you can expect the transaction to confirm within the next 10 minutes (one block).", comment: "")
        public static let  BC_STRING_FEE_LOWER_THAN_RECOMMENDED_ARGUMENT_SUGGESTED_ARGUMENT = NSLocalizedString("You specified an exceptionally small transaction fee of %@. Your transaction may be stuck and possibly never be confirmed. To increase the likelihood for your transaction to confirm within approximately one hour (six blocks), we strongly recommend a fee of no less than %@.", comment: "")
        public static let  BC_STRING_FEE_LOWER_THAN_RECOMMENDED_ARGUMENT_MUST_LOWER_AMOUNT_SUGGESTED_FEE_ARGUMENT_SUGGESTED_AMOUNT_ARGUMENT = NSLocalizedString("You specified an exceptionally small transaction fee of %@. Your transaction may become stuck and possibly never confirm. To increase the likelihood for your transaction to confirm within approximately one hour (six blocks), we strongly recommend a fee of no less than %@. Since you don’t have sufficient funds, that means the Send amount will also have to be lowered to %@.", comment: "")
        public static let  BC_STRING_INCREASE_FEE = NSLocalizedString("Increase fee", comment: "")
        public static let  BC_STRING_LOWER_FEE = NSLocalizedString("Lower fee", comment: "")
        public static let  BC_STRING_KEEP_HIGHER_FEE = NSLocalizedString("Keep higher fee", comment: "")
        public static let  BC_STRING_KEEP_LOWER_FEE = NSLocalizedString("Keep lower fee", comment: "")
        public static let  BC_STRING_USE_RECOMMENDED_VALUES = NSLocalizedString("Use recommended values", comment: "")
        public static let  BC_STRING_PLEASE_LOWER_CUSTOM_FEE = NSLocalizedString("Please lower the fee to an amount that is less than your balance", comment: "")
        public static let  BC_STRING_SURGE_OCCURRING_TITLE = NSLocalizedString("Surge Occurring", comment: "")
        public static let  BC_STRING_SURGE_OCCURRING_MESSAGE = NSLocalizedString("The Bitcoin mining network is currently experiencing a high volume of activity, resulting in recommended fees that are higher than usual.", comment: "")
        public static let  BC_STRING_FEE_INFORMATION_TITLE = NSLocalizedString("Transaction Fees", comment: "")
        public static let  BC_STRING_FEE_INFORMATION_MESSAGE = NSLocalizedString("Transaction fees impact how quickly the mining network will confirm your transactions, and depend on the current network conditions.", comment: "")
        public static let  BC_STRING_FEE_INFORMATION_MESSAGE_APPEND_REGULAR_SEND = NSLocalizedString(" We recommend the fee shown for the transaction at this time.", comment: "")
        public static let  BC_STRING_FEE_INFORMATION_DUST = NSLocalizedString("This transaction requires a higher fee for dust consumption due to the small amount of change to be returned.", comment: "")
        public static let  BC_STRING_FEE_INFORMATION_MESSAGE_ETHER = NSLocalizedString("Miners receive this fee to process this transaction.", comment: "")
        public static let  BC_STRING_TRANSACTION_DESCRIPTION_PLACEHOLDER = NSLocalizedString("What's this for?", comment: "")
        public static let  BC_STRING_NO_DESCRIPTION = NSLocalizedString("No description", comment: "")
        public static let  BC_STRING_WHATS_THIS = NSLocalizedString("What's this?", comment: "")
        public static let  BC_STRING_BLOCKCHAIN_ALL_RIGHTS_RESERVED = NSLocalizedString("All rights reserved.", comment: "")
        public static let  BC_STRING_RATE_US = NSLocalizedString("Rate us", comment: "")
        public static let  BC_STRING_ERROR_SAVING_WALLET_CHECK_FOR_OTHER_DEVICES = NSLocalizedString("An error occurred while saving your changes. Please make sure you are not logged into your wallet on another device.", comment: "")
        public static let  BC_STRING_ADDRESS_ALREADY_USED_PLEASE_LOGIN = NSLocalizedString("This address has already been used. Please login.", comment: "")
        public static let  BC_STRING_PLEASE_LOGIN_TO_LOAD_MORE_ADDRESSES = NSLocalizedString("Please login to load more addresses.", comment: "")
        public static let  BC_STRING_ERROR_TICKER = NSLocalizedString("An error occurred while retrieving currency conversion rates. Please try again later.", comment: "")
        public static let  BC_STRING_DESCRIPTION = NSLocalizedString("Description", comment: "")
        public static let  BC_STRING_DETAILS = NSLocalizedString("Details", comment: "")
        public static let  BC_STRING_VALUE_WHEN_SENT_ARGUMENT = NSLocalizedString("Value when sent: %@", comment: "")
        public static let  BC_STRING_VALUE_WHEN_RECEIVED_ARGUMENT = NSLocalizedString("Value when received: %@", comment: "")
        public static let  BC_STRING_STATUS = NSLocalizedString("Status", comment: "")
        public static let  BC_STRING_CONFIRMED = NSLocalizedString("Confirmed", comment: "")
        public static let  BC_STRING_PENDING_ARGUMENT_CONFIRMATIONS = NSLocalizedString("Pending (%@ Confirmations)", comment: "")
        public static let  BC_STRING_TRANSACTION_FEE_ARGUMENT = NSLocalizedString("Transaction fee: %@", comment: "")
        public static let  BC_STRING_PENDING = NSLocalizedString("Pending", comment: "")
        public static let  BC_STRING_DOUBLE_SPEND_WARNING = NSLocalizedString("May be at risk for a double spend.", comment: "")
        public static let  BC_STRING_ARGUMENT_RECIPIENTS = NSLocalizedString("%lu Recipients", comment: "")
        public static let  BC_STRING_TO = NSLocalizedString("To", comment: "")
        public static let  BC_STRING_DATE = NSLocalizedString("Date", comment: "")
        public static let  BC_STRING_FROM = NSLocalizedString("From", comment: "")
        public static let  BC_STRING_ERROR_GETTING_FIAT_AT_TIME = NSLocalizedString("Could not get value when sent - please check your internet connection and try again.", comment: "")
        public static let  BC_STRING_COULD_NOT_FIND_TRANSACTION_ARGUMENT = NSLocalizedString("Could not find transaction with hash %@ when reloading data", comment: "")
        public static let  BC_STRING_RECIPIENTS = NSLocalizedString("Recipients", comment: "")
        public static let  BC_STRING_US_DOLLAR = NSLocalizedString("U.S. Dollar", comment: "")
        public static let  BC_STRING_EURO = NSLocalizedString("Euro", comment: "")
        public static let  BC_STRING_ICELANDIC_KRONA = NSLocalizedString("lcelandic Króna", comment: "")
        public static let  BC_STRING_HONG_KONG_DOLLAR = NSLocalizedString("Hong Kong Dollar", comment: "")
        public static let  BC_STRING_NEW_TAIWAN_DOLLAR = NSLocalizedString("New Taiwan Dollar", comment: "")
        public static let  BC_STRING_SWISS_FRANC = NSLocalizedString("Swiss Franc", comment: "")
        public static let  BC_STRING_DANISH_KRONE = NSLocalizedString("Danish Krone", comment: "")
        public static let  BC_STRING_CHILEAN_PESO = NSLocalizedString("Chilean Peso", comment: "")
        public static let  BC_STRING_CANADIAN_DOLLAR = NSLocalizedString("Canadian Dollar", comment: "")
        public static let  BC_STRING_INDIAN_RUPEE = NSLocalizedString("Indian Rupee", comment: "")
        public static let  BC_STRING_CHINESE_YUAN = NSLocalizedString("Chinese Yuan", comment: "")
        public static let  BC_STRING_THAI_BAHT = NSLocalizedString("Thai Baht",  comment: "")
        public static let  BC_STRING_AUSTRALIAN_DOLLAR = NSLocalizedString("Australian Dollar", comment: "")
        public static let  BC_STRING_SINGAPORE_DOLLAR = NSLocalizedString("Singapore Dollar", comment: "")
        public static let  BC_STRING_SOUTH_KOREAN_WON = NSLocalizedString("South Korean Won", comment: "")
        public static let  BC_STRING_JAPANESE_YEN = NSLocalizedString("Japanese Yen", comment: "")
        public static let  BC_STRING_POLISH_ZLOTY = NSLocalizedString("Polish Zloty", comment: "")
        public static let  BC_STRING_GREAT_BRITISH_POUND = NSLocalizedString("Great British Pound", comment: "")
        public static let  BC_STRING_SWEDISH_KRONA = NSLocalizedString("Swedish Krona", comment: "")
        public static let  BC_STRING_NEW_ZEALAND_DOLLAR = NSLocalizedString("New Zealand Dollar", comment: "")
        public static let  BC_STRING_BRAZIL_REAL = NSLocalizedString("Brazil Real", comment: "")
        public static let  BC_STRING_RUSSIAN_RUBLE = NSLocalizedString("Russian Ruble", comment: "")
        public static let  BC_STRING_NO_TRANSACTIONS_TITLE = NSLocalizedString("No Transactions", comment: "")
        public static let  BC_STRING_NO_TRANSACTIONS_TEXT_BITCOIN = NSLocalizedString("Transactions occur when you send and request bitcoin.", comment: "")
        public static let  BC_STRING_NO_TRANSACTIONS_TEXT_ETHER = NSLocalizedString("Transactions occur when you send and request ether.", comment: "")
        public static let  BC_STRING_NO_TRANSACTIONS_TEXT_BITCOIN_CASH = NSLocalizedString("Transactions occur when you send and request bitcoin cash.", comment: "")
        public static let  BC_STRING_YOUR_TRANSACTIONS = NSLocalizedString("Your Transactions", comment: "")
        public static let  BC_STRING_VIEW_ON_URL_ARGUMENT = NSLocalizedString("View on", comment: "")
        public static let  BC_STRING_BACKUP_COMPLETE = NSLocalizedString("Backup Complete", comment: "")
        public static let  BC_STRING_BACKUP_COMPLETED_EXPLANATION = NSLocalizedString("Use your Recovery Phrase to restore your funds in case of a lost password.  Anyone with access to your Recovery Phrase can access your funds, so keep it offline somewhere safe and secure.", comment: "")
        public static let  BC_STRING_BACKUP_NEEDED_BODY_TEXT_ONE = NSLocalizedString("The following 12 word Recovery Phrase will give you access to your funds in case you lose your password.", comment: "")
        public static let  BC_STRING_BACKUP_NEEDED_BODY_TEXT_TWO = NSLocalizedString("Be sure to write down your phrase on a piece of paper and keep it somewhere safe and secure.", comment: "")
        public static let  BC_STRING_BACKUP_WORDS_INSTRUCTIONS = NSLocalizedString("Write down the following 12 word Recovery Phrase exactly as they appear and in this order:", comment: "")
        public static let  BC_STRING_BACKUP_PREVIOUS = NSLocalizedString("PREVIOUS", comment: "")
        public static let  BC_STRING_BACKUP_NEXT = NSLocalizedString("NEXT", comment: "")
        public static let  BC_STRING_BACKUP_AGAIN = NSLocalizedString("BACKUP AGAIN", comment: "")
        public static let  BC_STRING_TRANSFER_ALL = NSLocalizedString("Transfer all", comment: "")
        public static let  BC_STRING_TRANSFER_IMPORTED_ADDRESSES = NSLocalizedString("Transfer imported addresses?", comment: "")
        public static let  BC_STRING_TRANSFER_ALL_BACKUP = NSLocalizedString("Imported addresses are not backed up by your Recovery Phrase. To secure these funds, we recommend transferring these balances to include in your backup.", comment: "")
        public static let  BC_STRING_BE_YOUR_OWN_BANK = NSLocalizedString("Be your own bank", comment: "")
        public static let  BC_STRING_WELCOME_MESSAGE_ONE = NSLocalizedString ("Welcome to Blockchain", comment: "")
        public static let  BC_STRING_WELCOME_MESSAGE_TWO = NSLocalizedString ("Securely store bitcoin", comment: "")
        public static let  BC_STRING_WELCOME_MESSAGE_THREE = NSLocalizedString ("Seamlessly transact with others around the world", comment: "")
        public static let  BC_STRING_OVERVIEW_MARKET_PRICE_TITLE = NSLocalizedString("Current Price", comment: "")
        public static let  BC_STRING_OVERVIEW_MARKET_PRICE_DESCRIPTION = NSLocalizedString ("We work with exchange partners all over the world, so you can buy and sell bitcoin directly from your wallet.", comment: "")
        public static let  BC_STRING_OVERVIEW_REQUEST_FUNDS_TITLE = NSLocalizedString("Request Funds", comment: "")
        public static let  BC_STRING_OVERVIEW_REQUEST_FUNDS_DESCRIPTION = NSLocalizedString ("Send your wallet address to a friend to request funds. An address is a string of random letters and numbers that change for each transaction.", comment: "")
        public static let  BC_STRING_OVERVIEW_QR_CODES_TITLE = NSLocalizedString("QR Codes", comment: "")
        public static let  BC_STRING_OVERVIEW_QR_CODES_DESCRIPTION = NSLocalizedString("An address can also be shown as a QR code. Scan a friend's QR code to quickly capture their wallet address.", comment: "")
        public static let  BC_STRING_OVERVIEW_COMPLETE_TITLE = NSLocalizedString("That's it for now!", comment: "")
        public static let  BC_STRING_OVERVIEW_COMPLETE_DESCRIPTION = NSLocalizedString("We'll keep you up-to-date here with recommendations and new features.", comment: "")
        public static let  BC_STRING_START_OVER = NSLocalizedString("Start Over", comment: "")
        public static let  BC_STRING_OPEN_MAIL = NSLocalizedString("Open Mail", comment: "")
        public static let  BC_STRING_SCAN_ADDRESS = NSLocalizedString("Scan Address", comment: "")
        public static let  BC_STRING_SKIP_ALL = NSLocalizedString("Skip All", comment: "")
        public static let  BC_STRING_GET_BITCOIN = NSLocalizedString("Get Bitcoin", comment: "")
        public static let  BC_STRING_GET_ETHER = NSLocalizedString("Get Ether", comment: "")
        public static let  BC_STRING_REQUEST_ETHER = NSLocalizedString("Request Ether", comment: "")
        public static let  BC_STRING_GET_BITCOIN_CASH = NSLocalizedString("Get Bitcoin Cash", comment: "")
        public static let  BC_STRING_REQUEST_BITCOIN_CASH = NSLocalizedString("Request Bitcoin Cash", comment: "")
        public static let  BC_STRING_OVERVIEW = NSLocalizedString("Overview", comment: "")
        public static let  BC_STRING_DASHBOARD = NSLocalizedString("Dashboard", comment: "")
        public static let  BC_STRING_ENABLED_EXCLAMATION = NSLocalizedString("Enabled!", comment: "")
        public static let  BC_STRING_CUSTOM = NSLocalizedString("Custom", comment: "")
        public static let  BC_STRING_ADVANCED_USERS_ONLY = NSLocalizedString("Advanced users only", comment: "")
        public static let  BC_STRING_GREATER_THAN_ONE_HOUR = NSLocalizedString("1+ hour", comment: "")
        public static let  BC_STRING_PRIORITY = NSLocalizedString("Priority", comment: "")
        public static let  BC_STRING_LESS_THAN_ONE_HOUR = NSLocalizedString("~0-60 min", comment: "")
        public static let  BC_STRING_SATOSHI_PER_BYTE = NSLocalizedString("Satoshi per byte", comment: "")
        public static let  BC_STRING_SATOSHI_PER_BYTE_ABBREVIATED = NSLocalizedString("sat/b", comment: "")
        public static let  BC_STRING_HIGH_FEE_NOT_NECESSARY = NSLocalizedString("High fee not necessary", comment: "")
        public static let  BC_STRING_LOW_FEE_NOT_RECOMMENDED = NSLocalizedString("Low fee not recommended", comment: "")
        public static let  BC_STRING_NOT_ENOUGH_FUNDS_TO_USE_FEE = NSLocalizedString("You do not have enough funds to use this fee.", comment: "")
        public static let  BC_STRING_CUSTOM_FEE_WARNING = NSLocalizedString("This feature is recommended for advanced users only. By choosing a custom fee, you risk overpaying or your transaction may get stuck.", comment: "")
        public static let  BC_STRING_AVAILABLE_NOW_TITLE = NSLocalizedString("Available now", comment: "")
        public static let  BC_STRING_BUY_SELL_NOT_SUPPORTED_IOS_8_WEB_LOGIN = NSLocalizedString("Mobile Buy & Sell is supported for iOS 9 and up. Please run a software update or login at login.blockchain.com on your computer.", comment: "")
        public static let  BC_STRING_LOG_IN_TO_WEB_WALLET = NSLocalizedString("Log in to Web Wallet", comment: "")
        public static let  BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_ONE = NSLocalizedString("Go to login.blockchain.com on your computer.", comment: "")
        public static let  BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_TWO = NSLocalizedString("Select Log in via mobile.", comment: "")
        public static let  BC_STRING_WEB_LOGIN_INSTRUCTION_STEP_THREE = NSLocalizedString("Using your computer's camera, scan the QR code below.", comment: "")
        public static let  BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_HIDDEN = NSLocalizedString("Keep this QR code hidden until you're ready.", comment: "")
        public static let  BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_SHOWN_ONE = NSLocalizedString("Keep this QR code safe!", comment: "")
        public static let  BC_STRING_WEB_LOGIN_QR_INSTRUCTION_LABEL_SHOWN_TWO = NSLocalizedString("Do not share it with others.", comment: "")
        public static let  BC_STRING_SHOW_QR_CODE = NSLocalizedString("Show QR Code", comment: "")
        public static let  BC_STRING_HIDE_QR_CODE = NSLocalizedString("Hide QR Code", comment: "")
        public static let  BC_STRING_DAY = NSLocalizedString("Day", comment: "")
        public static let  BC_STRING_WEEK = NSLocalizedString("Week", comment: "")
        public static let  BC_STRING_MONTH = NSLocalizedString("Month", comment: "")
        public static let  BC_STRING_YEAR = NSLocalizedString("Year", comment: "")
        public static let  BC_STRING_ALL = NSLocalizedString("All", comment: "")
        public static let  BC_STRING_AT = NSLocalizedString("at", comment: "")
        public static let  BC_STRING_CONTRACT_ADDRESSES_NOT_SUPPORTED_TITLE = NSLocalizedString("Contract addresses are not supported.", comment: "")
        public static let  BC_STRING_CONTRACT_ADDRESSES_NOT_SUPPORTED_MESSAGE = NSLocalizedString("At the moment we only support ETH. You cannot receive REP, ICN, GNT, GNO, DGD, BCP.", comment: "")
        
        public static let  BC_STRING_NOW_SUPPORTING_ETHER_TITLE = NSLocalizedString("Now supporting Ether", comment: "")
        public static let  BC_STRING_NOW_SUPPORTING_ETHER_DESCRIPTION = NSLocalizedString("You asked, we listened. We’re excited to announce that your Blockchain wallet will now allow you to seamlessly send and receive ether!", comment: "")
        public static let  BC_STRING_GET_STARTED_WITH_ETHER = NSLocalizedString("Get Started with Ether", comment: "")
        public static let  BC_STRING_EXCHANGE = NSLocalizedString("Exchange", comment: "")
        public static let  BC_STRING_NEW_EXCHANGE = NSLocalizedString("New Exchange", comment: "")
        public static let  BC_STRING_USE_MINIMUM = NSLocalizedString("Use minimum", comment: "")
        public static let  BC_STRING_USE_MAXIMUM = NSLocalizedString("Use maximum", comment: "")
        public static let  BC_STRING_EXCHANGE_TITLE_SENDING_FUNDS = NSLocalizedString("Sending Funds", comment: "")
        public static let  BC_STRING_EXCHANGE_DESCRIPTION_SENDING_FUNDS = NSLocalizedString("Thanks for placing your trade!  Exchange trades can take up to two hours, and you can keep track of your trade’s progress in the Order History section.", comment: "")
        public static let  BC_STRING_IN_PROGRESS = NSLocalizedString("In Progress", comment: "")
        public static let  BC_STRING_EXCHANGE_DESCRIPTION_IN_PROGRESS = NSLocalizedString("Exchanges can take up to two hours, you can keep track of your exchange progress in the Order History. Once the trade is complete, your ether will arrive in your wallet.", comment: "")
        public static let  BC_STRING_EXCHANGE_DESCRIPTION_CANCELED = NSLocalizedString("Your trade has been canceled. Please return to the exchange tab to start your trade again.", comment: "")
        public static let  BC_STRING_FAILED = NSLocalizedString("Failed", comment: "")
        public static let  BC_STRING_EXCHANGE_TITLE_REFUNDED = NSLocalizedString("Trade Refunded", comment: "")
        public static let  BC_STRING_EXCHANGE_DESCRIPTION_FAILED = NSLocalizedString("This trade has failed. Any funds sent from your wallet will be returned minus the transaction fee. Please return to the exchange tab to start a new trade.", comment: "")
        public static let  BC_STRING_EXCHANGE_DESCRIPTION_EXPIRED = NSLocalizedString("Your trade has expired. Please return to the exchange tab to start a new trade.", comment: "")
        public static let  BC_STRING_EXCHANGE_CARD_DESCRIPTION = NSLocalizedString("You can now exchange your bitcoin for ether and vice versa directly from your Blockchain wallet!", comment: "")
        public static let  BC_STRING_ARGUMENT_TO_DEPOSIT = NSLocalizedString("%@ to Deposit", comment: "")
        public static let  BC_STRING_ARGUMENT_TO_BE_RECEIVED = NSLocalizedString("%@ to be Received", comment: "")
        public static let  BC_STRING_EXCHANGE_RATE = NSLocalizedString("Exchange Rate", comment: "")
        public static let  BC_STRING_TRANSACTION_FEE = NSLocalizedString("Transaction Fee", comment: "")
        public static let  BC_STRING_NETWORK_TRANSACTION_FEE = NSLocalizedString("Network Transaction Fee", comment: "")
        public static let  BC_STRING_SHAPESHIFT_WITHDRAWAL_FEE = NSLocalizedString("ShapeShift Withdrawal Fee", comment: "")
        public static let  BC_STRING_TERMS_AND_CONDITIONS = NSLocalizedString("terms and conditions", comment: "")
        public static let  BC_STRING_EXCHANGE_IN_PROGRESS = NSLocalizedString("Exchange In Progress", comment: "")
        public static let  BC_STRING_EXCHANGE_COMPLETED = NSLocalizedString("Exchange Completed", comment: "")
        public static let  BC_STRING_GET_STARTED = NSLocalizedString("Get started", comment: "")
        public static let  BC_STRING_BELOW_MINIMUM_LIMIT = NSLocalizedString("Below minimum limit", comment: "")
        public static let  BC_STRING_ABOVE_MAXIMUM_LIMIT = NSLocalizedString("Above maximum limit", comment: "")
        public static let  BC_STRING_NOT_ENOUGH_TO_EXCHANGE = NSLocalizedString("Not enough to exchange", comment: "")
        public static let  BC_STRING_EXCHANGE_ORDER_ID = NSLocalizedString("Order ID", comment: "")
        public static let  BC_STRING_TOTAL_ARGUMENT_SPENT = NSLocalizedString("Total %@ spent", comment: "")
        public static let  BC_STRING_GETTING_QUOTE = NSLocalizedString("Getting quote", comment: "")
        public static let  BC_STRING_CONFIRMING = NSLocalizedString("Confirming", comment: "")
        public static let  BC_STRING_COMPLETE = NSLocalizedString("Complete", comment: "")
        public static let  BC_STRING_QUOTE_EXIRES_IN_ARGUMENT = NSLocalizedString("Quote expires in %@", comment: "")
        public static let  BC_STRING_STEP_ARGUMENT_OF_ARGUMENT = NSLocalizedString("Step %d of %d", comment: "")
        public static let  BC_STRING_SELECT_YOUR_STATE = NSLocalizedString("Select your State:", comment: "")
        public static let  BC_STRING_SELECT_STATE = NSLocalizedString("Select State", comment: "")
        public static let  BC_STRING_EXCHANGE_NOT_AVAILABLE_TITLE = NSLocalizedString("Not Available", comment: "")
        public static let  BC_STRING_EXCHANGE_NOT_AVAILABLE_MESSAGE = NSLocalizedString("Exchanging coins is not yet available in your state. We’ll be rolling out more states soon.", comment: "")
        public static let  BC_STRING_ERROR_GETTING_BALANCE_ARGUMENT_ASSET_ARGUMENT_MESSAGE = NSLocalizedString("An error occurred when getting your %@ balance. Please try again later. Details: %@", comment: "")
        public static let  BC_STRING_ERROR_GETTING_APPROXIMATE_QUOTE_ARGUMENT_MESSAGE = NSLocalizedString("An error occurred when getting an approximate quote. Please try again later. Details: %@", comment: "")
        public static let  BC_STRING_DEPOSITED_TO_SHAPESHIFT = NSLocalizedString("Deposited to ShapeShift", comment: "")
        public static let  BC_STRING_RECEIVED_FROM_SHAPESHIFT = NSLocalizedString("Received from ShapeShift", comment: "")
        public static let  BC_STRING_ORDER_HISTORY = NSLocalizedString("Order History", comment: "")
        public static let  BC_STRING_INCOMING = NSLocalizedString("Incoming", comment: "")
        public static let  BC_STRING_TRADE_EXPIRED_TITLE = NSLocalizedString("Trade Expired", comment: "")
        public static let  BC_STRING_TRADE_EXPIRED_MESSAGE = NSLocalizedString("Your trade has expired. Please return to the Exchange page to start your trade again.", comment: "")
        public static let  BC_STRING_NO_FUNDS_TO_EXCHANGE_TITLE = NSLocalizedString("No Funds to Exchange", comment: "")
        public static let  BC_STRING_NO_FUNDS_TO_EXCHANGE_MESSAGE = NSLocalizedString("You have no funds to exchange. Why not get started by receiving some funds?", comment: "")
        public static let  BC_STRING_SELECT_ARGUMENT_WALLET = NSLocalizedString("Select other %@ Wallet", comment: "")
        public static let  BC_STRING_ARGUMENT_NEEDED_TO_EXCHANGE = NSLocalizedString("%@ needed to exchange", comment: "")
        public static let  BC_STRING_FAILED_TO_LOAD_EXCHANGE_DATA = NSLocalizedString("Failed to load exchange data", comment: "")
        public static let  BC_STRING_PRICE = NSLocalizedString("Price", comment: "")
        public static let  BC_STRING_SEE_CHARTS = NSLocalizedString("See charts", comment: "")
        public static let  BC_STRING_ENTER_BITCOIN_CASH_ADDRESS_OR_SELECT = NSLocalizedString("Enter bch address or select", comment: "")
        public static let  BC_STRING_BITCOIN_CASH_WARNING_CONFIRM_VALID_ADDRESS_ONE = NSLocalizedString("Are you sure this is a bitcoin cash address?", comment: "")
        public static let  BC_STRING_BITCOIN_CASH_WARNING_CONFIRM_VALID_ADDRESS_TWO = NSLocalizedString("Sending funds to a bitcoin address by accident will result in loss of funds.", comment: "")
        public static let  BC_STRING_COPY_WARNING_TEXT = NSLocalizedString("Copy this receive address to the clipboard? If so, be advised that other applications may be able to look at this information.", comment: "")
    }
    
    public static let verified = NSLocalizedString("Verified", comment: "")
    public static let unverified = NSLocalizedString("Unverified", comment: "")
    public static let verify = NSLocalizedString ("Verify", comment: "")
    public static let beginNow = NSLocalizedString("Begin Now", comment: "")
    public static let enterCode = NSLocalizedString ("Enter Verification Code", comment: "")
    public static let tos = NSLocalizedString ("Terms of Service", comment: "")
    public static let touchId = NSLocalizedString ("Touch ID", comment: "")
    public static let faceId = NSLocalizedString ("Face ID", comment: "")
    public static let disable = NSLocalizedString ("Disable", comment: "")
    public static let disabled = NSLocalizedString ("Disabled", comment: "")
    public static let unknown = NSLocalizedString ("Unknown", comment: "")
    public static let unconfirmed = NSLocalizedString("Unconfirmed", comment: "")
    public static let enable = NSLocalizedString ("Enable", comment: "")
    public static let changeEmail = NSLocalizedString ("Change Email", comment: "")
    public static let addEmail = NSLocalizedString ("Add Email", comment: "")
    public static let newEmail = NSLocalizedString ("New Email Address", comment: "")
    public static let settings = NSLocalizedString ("Settings", comment: "")
    public static let balances = NSLocalizedString(
        "Balances",
        comment: "Generic translation, may be used in multiple places."
    )

    public static let more = NSLocalizedString("More", comment: "")
    public static let privacyPolicy = NSLocalizedString("Privacy Policy", comment: "")
    public static let information = NSLocalizedString("Information", comment: "")
    public static let cancel = NSLocalizedString("Cancel", comment: "")
    public static let close = NSLocalizedString("Close", comment: "")
    public static let continueString = NSLocalizedString("Continue", comment: "")
    public static let okString = NSLocalizedString("OK", comment: "")
    public static let success = NSLocalizedString("Success", comment: "")
    public static let syncingWallet = NSLocalizedString("Syncing Wallet", comment: "")
    public static let tryAgain = NSLocalizedString("Try again", comment: "")
    public static let verifying = NSLocalizedString ("Verifying", comment: "")
    public static let openArg = NSLocalizedString("Open %@", comment: "")
    public static let youWillBeLeavingTheApp = NSLocalizedString("You will be leaving the app.", comment: "")
    public static let openMailApp = NSLocalizedString("Open Mail App", comment: "")
    public static let goToSettings = NSLocalizedString("Go to Settings", comment: "")
    public static let swipeReceive = NSLocalizedString("Swipe to Receive", comment: "")
    public static let twostep = NSLocalizedString("Enable 2-Step", comment: "")
    public static let localCurrency = NSLocalizedString("Local Currency", comment: "")
    public static let scanQRCode = NSLocalizedString("Scan QR Code", comment: "")
    public static let scanPairingCode = NSLocalizedString("Scan Pairing Code", comment: " ")
    public static let parsingPairingCode = NSLocalizedString("Parsing Pairing Code", comment: " ")
    public static let invalidPairingCode = NSLocalizedString("Invalid Pairing Code", comment: " ")
    
    public static let dontShowAgain = NSLocalizedString(
        "Don’t show again",
        comment: "Text displayed to the user when an action has the option to not be asked again."
    )
    public static let myEtherWallet = NSLocalizedString(
        "My Ether Wallet",
        comment: "The default name of the ether wallet."
    )
    public static let loading = NSLocalizedString(
        "Loading",
        comment: "Text displayed when there is an asynchronous action that needs to complete before the user can take further action."
    )
    public static let copiedToClipboard = NSLocalizedString(
        "Copied to clipboard",
        comment: "Text displayed when a user has tapped on an item to copy its text."
    )
    public static let learnMore = NSLocalizedString(
        "Learn More",
        comment: "Learn more button"
    )

    public struct Errors {
        public static let genericError = NSLocalizedString(
            "An error occured. Please try again.",
            comment: "Generic error message displayed when an error occurs."
        )
        public static let error = NSLocalizedString("Error", comment: "")
        public static let pleaseTryAgain = NSLocalizedString("Please try again", comment: "message shown when an error occurs and the user should attempt the last action again")
        public static let loadingSettings = NSLocalizedString("loading Settings", comment: "")
        public static let errorLoadingWallet = NSLocalizedString("Unable to load wallet due to no server response. You may be offline or Blockchain is experiencing difficulties. Please try again later.", comment: "")
        public static let cannotOpenURLArg = NSLocalizedString("Cannot open URL %@", comment: "")
        public static let unsafeDeviceWarningMessage = NSLocalizedString("Your device appears to be jailbroken. The security of your wallet may be compromised.", comment: "")
        public static let twoStep = NSLocalizedString("An error occurred while changing 2-Step verification.", comment: "")
        public static let noInternetConnection = NSLocalizedString("No internet connection.", comment: "")
        public static let noInternetConnectionPleaseCheckNetwork = NSLocalizedString("No internet connection available. Please check your network settings.", comment: "")
        public static let warning = NSLocalizedString("Warning", comment: "")
        public static let checkConnection = NSLocalizedString("Please check your internet connection.", comment: "")
        public static let timedOut = NSLocalizedString("Connection timed out. Please check your internet connection.", comment: "")
        public static let siteMaintenanceError = NSLocalizedString("Blockchain’s servers are currently under maintenance. Please try again later", comment: "")
        public static let invalidServerResponse = NSLocalizedString("Invalid server response. Please try again later.", comment: "")
        public static let invalidStatusCodeReturned = NSLocalizedString("Invalid Status Code Returned %@", comment: "")
        public static let requestFailedCheckConnection = NSLocalizedString("Request failed. Please check your internet connection.", comment: "")
        public static let errorLoadingWalletIdentifierFromKeychain = NSLocalizedString("An error was encountered retrieving your wallet identifier from the keychain. Please close the application and try again.", comment: "")
        public static let cameraAccessDenied = NSLocalizedString("Camera Access Denied", comment: "")
        public static let cameraAccessDeniedMessage = NSLocalizedString("Blockchain does not have access to the camera. To enable access, go to your device Settings.", comment: "")
        public static let microphoneAccessDeniedMessage = NSLocalizedString("Blockchain does not have access to the microphone. To enable access, go to your device Settings.", comment: "")
        public static let nameAlreadyInUse = NSLocalizedString("This name is already in use. Please choose a different name.", comment: "")
        public static let failedToRetrieveDevice = NSLocalizedString("Unable to retrieve the input device.", comment: "AVCaptureDeviceError: failedToRetrieveDevice")
        public static let inputError = NSLocalizedString("There was an error with the device input.", comment: "AVCaptureDeviceError: inputError")
        public static let noEmail = NSLocalizedString("Please provide an email address.", comment: "")
        public static let differentEmail = NSLocalizedString("New email must be different", comment: "")
        public static let failedToValidateCertificateTitle = NSLocalizedString("Failed to validate server certificate", comment: "Message shown when the app has detected a possible man-in-the-middle attack.")
        public static let failedToValidateCertificateMessage = NSLocalizedString(
            """
            A connection cannot be established because the server certificate could not be validated. Please check your network settings and ensure that you are using a secure connection.
            """, comment: "Message shown when the app has detected a possible man-in-the-middle attack.")
        public static let notEnoughXForFees = NSLocalizedString("Not enough %@ for fees", comment: "Message shown when the user has attempted to send more funds than the user can spend (input amount plus fees)")
        public static let balancesGeneric = NSLocalizedString("We are experiencing a service issue that may affect displayed balances. Don't worry, your funds are safe.", comment: "Message shown when an error occurs while fetching balance or transaction history")
    }

    public struct Authentication {
        public struct DefaultPasswordScreen {
            public static let title = NSLocalizedString(
                "Second Password Required",
                comment: "Password screen: title for general action"
            )
            public static let description = NSLocalizedString(
                "This action requires the second password for your wallet. Please enter it below and press continue.",
                comment: "Password screen: description"
            )
            public static let button = NSLocalizedString(
                "Continue",
                comment: "Password screen: continue button"
            )
        }
        public struct ImportKeyPasswordScreen {
            public static let title = NSLocalizedString(
                "Private Key Needed",
                comment: "Password screen: title for general action"
            )
            public static let description = NSLocalizedString(
                "The private key you are attempting to import is encrypted. Please enter the password below.",
                comment: "Password screen: description"
            )
            public static let button = NSLocalizedString(
                "Continue",
                comment: "Password screen: continue button"
            )
        }
        public struct EtherPasswordScreen {
            public static let title = NSLocalizedString(
                "Second Password Required",
                comment: "Password screen: title for general action"
            )
            public static let description = NSLocalizedString(
                "To use this service, we require you to enter your second password. You should only need to enter this once to set up your Ether wallet.",
                comment: "Password screen: description"
            )
            public static let button = NSLocalizedString(
                "Continue",
                comment: "Password screen: continue button"
            )
        }

        public static let password = NSLocalizedString("Password", comment: "")
        public static let secondPasswordIncorrect = NSLocalizedString("Second Password Incorrect", comment: "")
        public static let recoveryPhrase = NSLocalizedString("Recovery Phrase", comment: "")
        public static let twoStepSMS = NSLocalizedString("2-Step has been enabled for SMS", comment: "")
        public static let twoStepOff = NSLocalizedString("2-Step has been disabled.", comment: "")
        public static let checkLink = NSLocalizedString("Please check your email and click on the verification link.", comment: "")
        public static let googleAuth = NSLocalizedString("Google Authenticator", comment: "")
        public static let yubiKey = NSLocalizedString("Yubi Key", comment: "")
        public static let enableTwoStep = NSLocalizedString(
            """
            You can enable 2-step Verification via SMS on your mobile phone. In order to use other authentication methods instead, please login to our web wallet.
            """, comment: "")
        public static let verifyEmail = NSLocalizedString("Please verify your email address first.", comment: "")
        public static let resendVerificationEmail = NSLocalizedString("Resend verification email", comment: "")

        public static let resendVerification = NSLocalizedString("Resend verification SMS", comment: "")
        public static let enterVerification = NSLocalizedString("Enter your verification code", comment: "")
        public static let errorDecryptingWallet = NSLocalizedString("An error occurred due to interruptions during PIN verification. Please close the app and try again.", comment: "")
        public static let hasVerified = NSLocalizedString("Your mobile number has been verified.", comment: "")
        public static let invalidSharedKey = NSLocalizedString("Invalid Shared Key", comment: "")
        public static let forgotPassword = NSLocalizedString("Forgot Password?", comment: "")
        public static let passwordRequired = NSLocalizedString("Password Required", comment: "")
        public static let loadingWallet = NSLocalizedString("Loading Your Wallet", comment: "")
        public static let noPasswordEntered = NSLocalizedString("No Password Entered", comment: "")
        public static let failedToLoadWallet = NSLocalizedString("Failed To Load Wallet", comment: "")
        public static let failedToLoadWalletDetail = NSLocalizedString("An error was encountered loading your wallet. You may be offline or Blockchain is experiencing difficulties. Please close the application and try again later or re-pair your device.", comment: "")
        public static let forgetWallet = NSLocalizedString("Forget Wallet", comment: "")
        public static let forgetWalletDetail = NSLocalizedString("This will erase all wallet data on this device. Please confirm you have your wallet information saved elsewhere otherwise any bitcoin in this wallet will be inaccessible!!", comment: "")
        public static let enterPassword = NSLocalizedString("Enter Password", comment: "")
        public static let retryValidation = NSLocalizedString("Retry Validation", comment: "")
        public static let manualPairing = NSLocalizedString("Manual Pairing", comment: "")
        public static let invalidTwoFactorAuthenticationType = NSLocalizedString("Invalid two-factor authentication type", comment: "")
    }

    public struct Pin {
        public struct Accessibility {
            public static let faceId = NSLocalizedString(
                "Face id authentication",
                comment: "Accessiblity label for face id biometrics authentication"
            )
            
            public static let touchId = NSLocalizedString(
                "Touch id authentication",
                comment: "Accessiblity label for touch id biometrics authentication"
            )
            
            public static let backspace = NSLocalizedString(
                "Backspace button",
                comment: "Accessiblity label for backspace button"
            )
            
            public static let swipeHint = NSLocalizedString(
                "Swipe right to see your addresses",
                comment: "Accessiblity hint for swipe to receive label"
            )
        }
        
        public struct LogoutAlert {
            public static let title = NSLocalizedString(
                "Log Out",
                comment: "Log out alert title"
            )
            
            public static let message = NSLocalizedString(
                "Do you really want to log out?",
                comment: "Log out alert message"
            )
        }
        
        public static let swipeToReceiveLabel = NSLocalizedString(
            "Swipe to Receive",
            comment: "Title label indicating the can swipe the screen to see his wallet addresses on login"
        )
        
        public static let enableFaceIdTitle = NSLocalizedString(
            "Enable Face ID",
            comment: "Title for alert letting the user to enable face id"
        )
        
        public static let enableTouchIdTitle = NSLocalizedString(
            "Enable Touch ID",
            comment: "Title for alert letting the user to enable touch id"
        )
        
        public static let enableBiometricsMessage = NSLocalizedString(
            "Quickly sign into your wallet instead of using your PIN.",
            comment: "Title for alert letting the user to enable biometrics authenticators"
        )
        
        public static let enableBiometricsNotNowButton = NSLocalizedString(
            "Not Now",
            comment: "Cancel button for alert letting the user to enable biometrics authenticators"
        )
        
        public static let logoutButton = NSLocalizedString(
            "Log Out",
            comment: "Button for opting out in the PIN screen"
        )
        
        public static let changePinTitle = NSLocalizedString(
            "Change PIN",
            comment: "Title for changing PIN flow"
        )
        
        public static let pinSuccessfullySet = NSLocalizedString(
            "Your New PIN is Ready",
            comment: "PIN was set successfully message label"
        )
        
        public static let createYourPinLabel = NSLocalizedString(
            "Create Your PIN",
            comment: "Create PIN code title label"
        )
        
        public static let confirmYourPinLabel = NSLocalizedString(
            "Confirm Your PIN",
            comment: "Confirm PIN code title label"
        )
        
        public static let enterYourPinLabel = NSLocalizedString(
            "Enter Your PIN",
            comment: "Enter PIN code title label"
        )
        
        public static let tooManyAttemptsTitle = NSLocalizedString(
            "Too Many PIN Attempts",
            comment: "Title for alert that tells the user he had too many PIN attempts"
        )
        
        public static let tooManyAttemptsMessage = NSLocalizedString(
            "Please enter your wallet password.",
            comment: "Message for alert that tells the user he had too many PIN attempts"
        )
        
        public static let revealAddress = NSLocalizedString(
        """
        Enable this option to reveal a receive address when you swipe left on the PIN screen, making
        receiving bitcoin even faster. Five addresses will be loaded consecutively, after which logging in is
        required to show new addresses.
        """, comment: "")

        public static let genericError = NSLocalizedString(
            "An error occured. Please try again",
            comment: "Fallback error for all other errors that may occur during the PIN validation/change flow."
        )
        public static let newPinMustBeDifferent = NSLocalizedString(
            "Your new PIN must be different",
            comment: "Error message displayed to the user that they must enter a PIN code that is different from their previous PIN."
        )
        public static let chooseAnotherPin = NSLocalizedString(
            "Please choose another PIN",
            comment: "Error message displayed to the user when they must enter another PIN code."
        )

        public static let incorrect = NSLocalizedString(
            "Incorrect PIN",
            comment: "Error message displayed when the entered PIN is incorrect and the user should try to enter the PIN code again."
        )
        public static let pinsDoNotMatch = NSLocalizedString(
            "PINs don't match",
            comment: "Message presented to user when they enter an incorrect PIN when confirming a PIN."
        )
        public static let cannotSaveInvalidWalletState = NSLocalizedString(
            "Cannot save PIN Code while wallet is not initialized or password is null",
            comment: "Error message displayed when the wallet is in an invalid state and the user tried to enter a new PIN code."
        )
        public static let responseKeyOrValueLengthZero = NSLocalizedString(
            "PIN Response Object key or value length 0",
            comment: "Error message displayed to the user when the PIN-store endpoint is returning an invalid response."
        )
        public static let responseSuccessLengthZero = NSLocalizedString(
            "PIN response Object success length 0",
            comment: "Error message displayed to the user when the PIN-store endpoint is returning an invalid response."
        )
        public static let decryptedPasswordLengthZero = NSLocalizedString(
            "Decrypted PIN Password length 0",
            comment: "Error message displayed when the user’s decrypted password length is 0."
        )
        public static let validationError = NSLocalizedString(
            "PIN Validation Error",
            comment: "Title of the error message displayed to the user when their PIN cannot be validated if it is correct."
        )
        public static let validationErrorMessage = NSLocalizedString(
        """
        An error occurred validating your PIN code with the remote server. You may be offline or Blockchain may be experiencing difficulties. Would you like retry validation or instead enter your password manually?
        """, comment: "Error message displayed to the user when their PIN cannot be validated if it is correct."
        )
    }

    public struct Onboarding {
        public struct WelcomeScreen {
            public struct Description {
                public static let prefix = NSLocalizedString(
                    "The easy way to ",
                    comment: "Welcome screen description: description prefix"
                )
                public static let comma = NSLocalizedString(
                    ", ",
                    comment: "Welcome screen description: comma separator"
                )
                public static let send = NSLocalizedString(
                    "send",
                    comment: "Welcome screen description: send word"
                )
                public static let receive = NSLocalizedString(
                    "receive",
                    comment: "Welcome screen description: receive word"
                )
                public static let store = NSLocalizedString(
                    "store",
                    comment: "Welcome screen description: store word"
                )
                public static let and = NSLocalizedString(
                    " and ",
                    comment: "Welcome screen description: store word"
                )
                public static let trade = NSLocalizedString(
                    "trade",
                    comment: "Welcome screen description: trade word"
                )
                public static let suffix = NSLocalizedString(
                    " digital currencies.",
                    comment: "Welcome screen description: suffix"
                )
            }
            public struct Button {
                public static let createWallet = NSLocalizedString(
                    "Create a Wallet",
                    comment: "Welcome screen: create wallet CTA button"
                )
                public static let login = NSLocalizedString(
                    "Log In",
                    comment: "Welcome screen: login CTA button"
                )
                public static let recoverFunds = NSLocalizedString(
                    "Recover Funds",
                    comment: "Welcome screen: recover funds CTA button"
                )
            }
            public static let title = NSLocalizedString(
                "Welcome to Blockchain",
                comment: "Welcome screen: title"
            )
        }
        public struct PairingIntroScreen {
            public struct Instruction {
                public static let firstPrefix = NSLocalizedString(
                    "Log in to your Blockchain Wallet via your PC or Mac at ",
                    comment: "Pairing intro screen: first instruction prefix"
                )
                public static let firstSuffix = NSLocalizedString(
                    "login.blockchain.com",
                    comment: "Pairing intro screen: first instruction suffix"
                )
                public static let second = NSLocalizedString(
                    "Go to Settings / General.",
                    comment: "Pairing intro screen: second instruction"
                )
                public static let third = NSLocalizedString(
                    "Click Show Pairing Code to reveal a QR Code, a square black & white barcode. Scan the code with your camera.",
                    comment: "Pairing intro screen: third instruction"
                )
            }
            public static let title = NSLocalizedString(
                "Log In",
                comment: "Manual pairing screen title"
            )
            public static let primaryButton = NSLocalizedString(
                "Scan Pairing Code",
                comment: "Scan pairing code CTA button"
            )
            public static let secondaryButton = NSLocalizedString(
                "Manual Pairing",
                comment: "Manual pairing CTA button"
            )
        }
        public struct AutoPairingScreen {
            public static let title = NSLocalizedString(
                "Automatic Pairing",
                comment: "Automatic pairing screen title"
            )
            public struct ErrorAlert {
                public static let title = NSLocalizedString(
                    "Error",
                    comment: "Auto pairing error alert title"
                )
                public static let message = NSLocalizedString(
                    "There was an error while scanning your pairing QR code",
                    comment: "Auto pairing error alert message"
                )
                public static let scanAgain = NSLocalizedString(
                    "Try Again",
                    comment: "Auto pairing error alert scan again button"
                )
                public static let manualPairing = NSLocalizedString(
                    "Cancel",
                    comment: "Auto pairing error alert cancel button"
                )
            }
        }
        public struct ManualPairingScreen {
            public struct TwoFAAlert {
                public static let wrongCodeTitle = NSLocalizedString(
                    "Wrong Verification Code",
                    comment: "2FA alert: title"
                )
                public static let title = NSLocalizedString(
                    "Verification Code",
                    comment: "2FA alert: title"
                )
                public static let wrongCodeMessage = NSLocalizedString(
                    "%d login attempts left. Please enter your %@ 2FA code",
                    comment: "2FA alert: title"
                )
                public static let message = NSLocalizedString(
                    "Please enter your %@ 2FA code",
                    comment: "2FA alert: message"
                )
                public static let verifyButton = NSLocalizedString(
                    "Verify",
                    comment: "2FA alert: verify button"
                )
                public static let resendButton = NSLocalizedString(
                    "Send again",
                    comment: "2FA alert: resend button"
                )
            }
            public struct AccountLockedAlert {
                public static let title = NSLocalizedString(
                    "Locked Account",
                    comment: "Locked account alert: title"
                )
                public static let message = NSLocalizedString(
                    "Your wallet has been locked because of too many failed login attempts. You can try again in 4 hours.",
                    comment: "Locked account alert: message"
                )
            }
            public static let title = NSLocalizedString(
                "Manual Pairing",
                comment: "Manual pairing screen title"
            )
            public static let button = NSLocalizedString(
                "Continue",
                comment: "Manual pairing screen CTA button"
            )
            public struct EmailAuthorizationAlert {
                public static let title = NSLocalizedString(
                    "Authorization Required",
                    comment: "Title for email authorization alert"
                )
                public static let message = NSLocalizedString(
                    "Please check your email and authorize this log-in attempt. After doing so, please return here.",
                    comment: "Message for email authorization alert"
                )
            }
            public struct RequestOtpMessageErrorAlert {
                public static let title = NSLocalizedString(
                    "An Error Occurred",
                    comment: "Title for alert displayed when an error occurrs during otp request"
                )
                public static let message = NSLocalizedString(
                    "There was a problem sending the SMS code. Please try again later.",
                    comment: "Message for alert displayed when an error occurrs during otp request"
                )
            }
        }
        public struct CreateWalletScreen {
            public static let title = NSLocalizedString(
                "Create New Wallet",
                comment: "Create new wallet screen title"
            )
            public static let button = NSLocalizedString(
                "Create Wallet",
                comment: "Create new wallet screen CTA button"
            )
            public struct TermsOfUse {
                public static let prefix = NSLocalizedString(
                    "By creating a wallet you agree to Blockchain’s ",
                    comment: "Create new wallet screen TOS prefix"
                )
                public static let termsOfServiceLink = NSLocalizedString(
                    "Terms of Services",
                    comment: "Create new wallet screen TOS terms part"
                )
                public static let linkDelimiter = NSLocalizedString(
                    " & ",
                    comment: "Create new wallet screen TOS terms part"
                )
                public static let privacyPolicyLink = NSLocalizedString(
                    "Privacy Policy",
                    comment: "Create new wallet screen TOS privacy policy part"
                )
            }
            // TODO: Format it properly
            public static let termsOfUseFormat = NSLocalizedString(
                "By creating a wallet you agree to Blockchain’s Terms of Services & Privacy Policy",
                comment: "Create new wallet screen terms of use text label"
            )
        }
        
        public struct PasswordRequiredScreen {
            public static let title = NSLocalizedString(
                "Password Required",
                comment: "Password required screen title"
            )
            public static let continueButton = NSLocalizedString(
                "Continue",
                comment: "Password required CTA"
            )
            public static let forgotButton = NSLocalizedString(
                "Forgot Password?",
                comment: "Forgot password CTA"
            )
            public static let forgetWalletButton = NSLocalizedString(
                "Forget Wallet",
                comment: "Forget wallet CTA"
            )
            public static let description = NSLocalizedString(
                "You have logged out or there was an error decrypting your wallet file. Enter your password below to login.",
                comment: "Description of Password Required form"
            )
            public static let forgetWalletDescription = NSLocalizedString(
                "If you would like to forget this wallet and start over, press ‘Forget Wallet’.",
                comment: "Description of forget wallet functionality."
            )
            public struct ForgotPasswordAlert {
                public static let title = NSLocalizedString(
                    "Open Support",
                    comment: "forgot password alert title"
                )
                public static let message = NSLocalizedString(
                    "You will be redirected to\n%@.",
                    comment: "forgot password alert body"
                )
            }
            public struct ForgetWalletAlert {
                public static let title = NSLocalizedString(
                    "Warning",
                    comment: "forget wallet alert title"
                )
                public static let message = NSLocalizedString(
                    "This will erase all wallet data on this device. Please confirm you have your wallet information saved elsewhere, otherwise any bitcoin in this wallet will be inaccessible!",
                    comment: "forget wallet alert body"
                )
                public static let forgetButton = NSLocalizedString(
                    "Forget",
                    comment: "forget wallet alert button"
                )
            }
        }
        
        public struct RecoverFunds {
            public static let title = NSLocalizedString(
                "Recover Funds",
                comment: "Title of the recover funds screen"
            )
            public static let description = NSLocalizedString(
                "Enter your 12 recovery words with spaces to recover your funds & transactions",
                comment: "Description of what to type into the recover funds screen"
            )
            public static let placeholder = NSLocalizedString(
                "Recovery phrase",
                comment: "Placeholder for the text field on the Recover Funds screen."
            )
            public static let button = NSLocalizedString(
                "Continue",
                comment: "CTA on the recover funds screen"
            )
        }
        
        public static let createNewWallet = NSLocalizedString("Create New Wallet", comment: "")
        public static let termsOfServiceAndPrivacyPolicyNoticePrefix = NSLocalizedString("By creating a wallet you agree to Blockchain’s", comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they create a wallet")
        public static let automaticPairing = NSLocalizedString("Automatic Pairing", comment: "")
        public static let recoverFunds = NSLocalizedString("Recover Funds", comment: "")
        public static let recoverFundsOnlyIfForgotCredentials = NSLocalizedString("You should always pair or login if you have access to your Wallet ID and password. Recovering your funds will create a new Wallet ID. Would you like to continue?", comment: "")
        public static let askToUserOldWalletTitle = NSLocalizedString("We’ve detected a previous installation of Blockchain Wallet on your phone.", comment: "")
        public static let askToUserOldWalletMessage = NSLocalizedString("Please choose from the options below.", comment: "")
        public static let loginExistingWallet = NSLocalizedString("Login existing Wallet", comment: "")
        public static let biometricInstructions = NSLocalizedString("Use %@ instead of PIN to authenticate Blockchain and access your wallet.", comment: "")
        
        public struct IntroductionSheet {
            public static let next = NSLocalizedString("Next", comment: "Next")
            public static let done = NSLocalizedString("Done", comment: "Done")
            public struct Home {
                public static let title = NSLocalizedString("View Your Portfolio", comment: "View Your Portfolio")
                public static let description = NSLocalizedString(
                    "Keep track of your crypto balances from your Wallet's dashboard. Your Wallet currently supports Bitcoin, Ether, Bitcoin Cash, Stellar XLM and USD PAX.",
                    comment: "Keep track of your crypto balances from your Wallet's dashboard. Your Wallet currently supports Bitcoin, Ether, Bitcoin Cash, Stellar XLM and USD PAX."
                )
            }
            public struct Send {
                public static let title = NSLocalizedString("Send", comment: "Send")
                public static let description = NSLocalizedString(
                    "Send crypto anywhere, anytime. All you need is the recipient’s crypto address.",
                    comment: "Send crypto anywhere, anytime. All you need is the recipient’s crypto address."
                )
            }
            public struct Request {
                public static let title = NSLocalizedString("Request", comment: "Request")
                public static let description = NSLocalizedString(
                    "To receive crypto, all the sender needs is your crypto's address. You can find these addresses here.",
                    comment: "To receive crypto, all the sender needs is your crypto's address. You can find these addresses here."
                )
            }
            public struct Swap {
                public static let title = NSLocalizedString("Swap", comment: "Swap")
                public static let description = NSLocalizedString(
                    "Trade crypto with low fees without leaving your wallet.",
                    comment: "Trade crypto with low fees without leaving your wallet."
                )
            }
            public struct BuySell {
                public static let title = NSLocalizedString("Buy & Sell", comment: "Buy & Sell")
                public static let description = NSLocalizedString(
                    "Jumpstart your crypto portfolio by easily buying and selling Bitcoin.",
                    comment: "Jumpstart your crypto portfolio by easily buying and selling Bitcoin."
                )
            }
        }
    }

    public struct DeepLink {
        public static let deepLinkUpdateTitle = NSLocalizedString(
            "Link requires app update",
            comment: "Title of alert shown if the deep link requires a newer version of the app."
        )
        public static let deepLinkUpdateMessage = NSLocalizedString(
            "The link you have used is not supported on this version of the app. Please update the app to access this link.",
            comment: "Message of alert shown if the deep link requires a newer version of the app."
        )
        public static let updateNow = NSLocalizedString(
            "Update Now",
            comment: "Action of alert shown if the deep link requires a newer version of the app."
        )
    }
    
    public struct Dashboard {
        public struct Balance {
            public static let totalBalance = NSLocalizedString(
                "Total Balance",
                comment: "Dashboard: total balance component - title"
            )
            public static let notice = NSLocalizedString(
                "You have a pending {swap/buy/sell} order that may impact your total balance.",
                comment: "Dashboard: balance notice"
            )
            public static let lockboxNotice = NSLocalizedString(
                "The Total Balance shown on this device does not include your linked Lockbox.",
                comment: "Dashboard: lockbox notice"
            )
        }
    
        public static let chartsError = NSLocalizedString(
            "An error occurred while retrieving the latest chart data. Please try again later.",
            comment: "The error message for when the method fetchChartDataForAsset fails."
        )
        public static let bitcoinPrice = NSLocalizedString(
            "Bitcoin Price",
            comment: "The title of the Bitcoin price chart on the dashboard."
        )
        public static let etherPrice = NSLocalizedString(
            "Ether Price",
            comment: "The title of the Ethereum price chart on the dashboard."
        )
        public static let bitcoinCashPrice = NSLocalizedString(
            "Bitcoin Cash Price",
            comment: "The title of the Bitcoin Cash price chart on the dashboard."
        )
        public static let stellarPrice = NSLocalizedString(
            "Stellar Price",
            comment: "The title of the Stellar price chart on the dashboard."
        )
        public static let seeCharts = NSLocalizedString(
            "See Charts",
            comment: "The title of the action button in the price preview views."
        )
        public static let activity = NSLocalizedString("Activity", comment: "Activity tab item")
        public static let send = NSLocalizedString("Send", comment: "Send tab item")
        public static let request = NSLocalizedString("Request", comment: "request tab item")
    }
    
    public struct DashboardDetails {
        public static let currentPrice = NSLocalizedString("Current Price", comment: "Current Price")
        
        public static let send = NSLocalizedString("Send", comment: "Send")
        public static let request = NSLocalizedString("Request", comment: "Request")
        
        public static let day = NSLocalizedString("Day", comment: "Day")
        public static let week = NSLocalizedString("Week", comment: "Week")
        public static let month = NSLocalizedString("Month", comment: "Month")
        public static let year = NSLocalizedString("Year", comment: "Year")
        public static let all = NSLocalizedString("All", comment: "All")
    }

    public struct VersionUpdate {
        public static let version = NSLocalizedString(
            "v %@",
            comment: "Version top note for a `recommended` update alert"
        )
        
        public static let title = NSLocalizedString(
            "Update Available",
            comment: "Title for a `recommended` update alert"
        )
        
        public static let description = NSLocalizedString(
            "Ready for the the best Blockchain App yet? Download our latest build and get more out of your Crypto.",
            comment: "Description for a `recommended` update alert"
        )
        
        public static let updateNowButton = NSLocalizedString(
            "Update Now",
            comment: "`Update` button for an alert that notifies the user that a new app version is available on the store"
        )
    }
    
    public struct TabItems {
        public static let home = NSLocalizedString(
            "Home",
            comment: "Tab item: home"
        )
        public static let activity = NSLocalizedString(
            "Activity",
            comment: "Tab item: activity"
        )
        public static let swap = NSLocalizedString(
            "Swap",
            comment: "Tab item: swap"
        )
        public static let send = NSLocalizedString(
            "Send",
            comment: "Tab item: send"
        )
        public static let request = NSLocalizedString(
            "Request",
            comment: "Tab item: request"
        )
    }
    
    public struct DashboardScreen {
        public static let title = NSLocalizedString(
            "Home",
            comment: "Dashboard screen: title label"
        )
    }
    
    public struct AnnouncementCards {
        
        // MARK: - Persistent
        
        public struct Welcome {
            public static let title = NSLocalizedString(
                "Welcome to Blockchain!",
                comment: "Welcome announcement card title"
            )
            public static let description = NSLocalizedString(
                "Here are a few tips to get your account up and running, we’ll also help you make sure everything is secure.",
                comment: "Welcome announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Tell Me More",
                comment: "Welcome announcement card CTA button title"
            )
            public static let skipButton = NSLocalizedString(
                "Maybe Later",
                comment: "Welcome announcement card skip button title"
            )
        }
        public struct VerifyEmail {
            public static let title = NSLocalizedString(
                "Verify Your Email Address",
                comment: "Verify email announcement card title"
            )
            public static let description = NSLocalizedString(
                "You need to confirm your email address so that we can keep you informed about your wallet.",
                comment: "Verify email announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Verify Email Address",
                comment: "Verify email announcement card CTA button title"
            )
        }
        public struct BackupFunds {
            public static let title = NSLocalizedString(
                "Wallet Recovery Phrase",
                comment: "Backup funds announcement card title"
            )
            public static let description = NSLocalizedString(
                "You control your crypto. Write down your recovery phrase to restore all your funds in case you lose your password.",
                comment: "Backup funds announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Backup Phrase",
                comment: "Backup funds announcement card CTA button title"
            )
        }
        
        // MARK: - One time
        
        public struct BlockstackAirdropReceived {
            public static let title = NSLocalizedString(
                "Your Airdrop Has Landed",
                comment: "STX airdrop received announcement card title"
            )
            public static let description = NSLocalizedString(
                "Your stacks are now in your wallet. We’ll let you know as soon as these are available to be used.",
                comment: "STX airdrop received announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "View Details",
                comment: "STX airdrop received announcement card CTA button title"
            )
        }
        public struct BlockstackAirdropRegisteredMini {
            public static let title = NSLocalizedString(
                "A Reward for Being Gold Level",
                comment: "STX airdrop registered announcement mini card title"
            )
            public static let description = NSLocalizedString(
                "We're airdropping you free crypto in 2020",
                comment: "STX airdrop registered announcement mini card description"
            )
        }
        public struct IdentityVerification {
            public static let title = NSLocalizedString(
                "Finish Verifying Your Account",
                comment: "Finish identity verification announcement card title"
            )
            public static let description = NSLocalizedString(
                "Pick up where you left off and complete your identity verification.",
                comment: "Finish identity verification announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Continue Verification",
                comment: "Finish identity verification announcement card CTA button title"
            )
        }
        public struct Pax {
            public static let title = NSLocalizedString(
                "Digital US Dollar",
                comment: "Pax announcement card title"
            )
            public static let description = NSLocalizedString(
                "Introducing USD PAX, a safe and stable crypto asset you can use to store value. 1 PAX = 1 USD.",
                comment: "Pax announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Get USD PAX",
                comment: "Pax announcement card CTA button title"
            )
        }
        public struct Pit {
            public static let title = NSLocalizedString(
                "Introducing The PIT",
                comment: "PIT announcement card title"
            )
            public static let variantADescription = NSLocalizedString(
                "Trade crypto & fiat on The PIT, Blockchain’s new lighting fast exchange.",
                comment: "PIT announcement card description - variantA"
            )
            public static let variantBDescription = NSLocalizedString(
                "Link your Wallet and trade crypto & fiat on The PIT, Blockchain’s new lighting fast exchange.",
                comment: "PIT announcement card description - variantB"
            )
            public static let ctaButton = NSLocalizedString(
                "Get Started",
                comment: "PIT announcement card CTA button title"
            )
        }
        public struct Bitpay {
            public static let description = NSLocalizedString(
                "With BitPay, you can now use your Blockchain wallet for purchases with supporting retailers.",
                comment: "Bitpay announcement card description"
            )
        }
        
        // MARK: - Periodic
        
        public struct BuyBitcoin {
            public static let title = NSLocalizedString(
                "Buy Bitcoin",
                comment: "Buy BTC announcement card title"
            )
            public static let description = NSLocalizedString(
                "Buy Bitcoin with your credit card or bank account to kickstart your crypto portfolio.",
                comment: "Buy BTC announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Buy Bitcoin",
                comment: "Buy BTC announcement card CTA button title"
            )
        }
        public struct Swap {
            public static let title = NSLocalizedString(
                "Trade Crypto",
                comment: "Swap announcement card title"
            )
            public static let description = NSLocalizedString(
                "Trade one crypto for another without giving up control of your keys. Get competitive, real-time prices and fast on-chain settlement.",
                comment: "Swap announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Check out Swap",
                comment: "Swap announcement card CTA button title"
            )
        }
        public struct TransferInCrypto {
            public static let title = NSLocalizedString(
                "Transfer In Crypto",
                comment: "Transfer crypto announcement card title"
            )
            public static let description = NSLocalizedString(
                "Deposit crypto in your wallet to get started. It's the best way to store your crypto while keeping control of your keys.",
                comment: "Transfer crypto announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Get Started",
                comment: "Transfer crypto announcement card CTA button title"
            )
        }
        public struct ResubmitDocuments {
            public static let title = NSLocalizedString(
                "Documents Needed",
                comment: "The title of the action on the announcement card for when a user needs to submit documents to verify their identity."
            )
            public static let description = NSLocalizedString(
                "We had some issues with the documents you’ve supplied. Please try uploading the documents again to continue with your verification.",
                comment: "The description on the announcement card for when a user needs to submit documents to verify their identity."
            )
            public static let ctaButton = NSLocalizedString(
                "Upload Documents",
                comment: "The title of the action on the announcement card for when a user needs to submit documents to verify their identity."
            )
        }
        public struct KycAirdrop {
            public static let title = NSLocalizedString(
                "Want Free Crypto?",
                comment: "Kyc airdrop announcement card title"
            )
            public static let description = NSLocalizedString(
                "Verify your identity to participate in our Airdrop program and receive free crypto from future Airdrops.",
                comment: "Kyc airdrop announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Start Verification",
                comment: "Kyc airdrop announcement card CTA button title"
            )
        }
        public struct TwoFA {
            public static let title = NSLocalizedString(
                "Enable 2-Step Verification",
                comment: "2FA announcement card title"
            )
            public static let description = NSLocalizedString(
                "Protect your wallet from unauthorized access by enabling 2-Step Verification.",
                comment: "2FA announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Enable 2-Step Verification",
                comment: "2FA announcement card CTA button title"
            )
        }
        public struct CoinifyKyc {
            public static let title = NSLocalizedString(
                "More Information Needed",
                comment: "Coinify kyc announcement card title"
            )
            public static let description = NSLocalizedString(
                "To keep using Buy & Sell, you’ll need to update your profile. Once completed, you’ll also unlock higher trading limits in Swap.",
                comment: "Coinify kyc announcement card description"
            )
            public static let ctaButton = NSLocalizedString(
                "Update Now",
                comment: "Coinify kyc announcement card CTA button title"
            )
        }
    }
    
    public struct PIT {
        public static let title = NSLocalizedString("The PIT", comment: "The PIT")
        public static let connect = NSLocalizedString("Connect", comment: "Connect")
        public static let connected = NSLocalizedString("Connected", comment: "Connected")
        public static let twoFactorNotEnabled = NSLocalizedString("Please enable 2FA on your PIT account to complete deposit.", comment: "User must have 2FA enabled to deposit from send.")
        public struct Alerts {
            public static let connectingYou = NSLocalizedString("Connecting You To The PIT", comment: "Connecting You To The PIT")
            public static let newWindow = NSLocalizedString("A new window should open within 10 seconds.", comment: "A new window should open within 10 seconds.")
            public static let success = NSLocalizedString("Success!", comment: "Success!")
            public static let successDescription = NSLocalizedString("Please return to The PIT to complete account setup.", comment: "Please return to The PIT to complete account setup.")
            public static let error = NSLocalizedString("Connection Error", comment: "Connection Error")
            public static let errorDescription = NSLocalizedString("We could not connect your Wallet to The PIT. Please try again", comment: "We could not connect your Wallet to The PIT. Please try again")
        }
        public struct EmailVerification {
            public static let title = NSLocalizedString("Verify Your Email", comment: "")
            public static let description = NSLocalizedString(
                "We just sent you a verification email. Your email address needs to be verified before you can connect to The PIT.",
                comment: ""
            )
            public static let didNotGetEmail = NSLocalizedString("Didn't get the email?", comment: "")
            public static let sendAgain = NSLocalizedString("Send Again", comment: "")
            public static let openMail = NSLocalizedString("Open Mail", comment: "")
            public static let justAMoment = NSLocalizedString("Just a moment.", comment: "")
            public static let verified = NSLocalizedString("Email Verified", comment: "")
            public static let verifiedDescription = NSLocalizedString(
                "You’re all set to connect your Blockchain Wallet to The PIT.",
                comment: ""
            )
        }
        public struct Launch {
            public static let launchPIT = NSLocalizedString("Launch The PIT", comment: "")
            public static let contactSupport = NSLocalizedString("Contact Support", comment: "")
        }
        public struct ConnectionPage {
            public struct Descriptors {
                public static let description = NSLocalizedString("There's a new way to trade. Link your Wallet for instant access.", comment: "Description of the pit.")
                public static let lightningFast = NSLocalizedString("Trade Lightning Fast", comment: "")
                public static let withdrawDollars = NSLocalizedString("Deposit & Withdraw Euros/Dollars", comment: "")
                public static let accessCryptos = NSLocalizedString("Access More Cryptos", comment: "")
                public static let builtByBlockchain = NSLocalizedString("Built by Blockchain", comment: "")
            }
            
            public struct Features {
                public static let pitWillBeAbleTo = NSLocalizedString("The PIT will be able to:", comment: "")
                public static let shareStatus = NSLocalizedString("Share your Gold or Silver Level status for unlimited trading", comment: "")
                public static let shareAddresses = NSLocalizedString("Sync addresses with your Wallet so you can securely sweep crypto between accounts", comment: "")
                public static let lowFees = NSLocalizedString("Low Fees", comment: "")
                public static let builtByBlockchain = NSLocalizedString("Built by Blockchain.com", comment: "")
                
                public static let pitWillNotBeAbleTo = NSLocalizedString("Will Not:", comment: "")
                public static let viewYourPassword = NSLocalizedString("Access the crypto in your wallet, access your keys, or view your password.", comment: "")
            }
            
            public struct Actions {
                public static let learnMore = NSLocalizedString("Learn More", comment: "")
                public static let connectNow = NSLocalizedString("Connect Now", comment: "")
            }
            
            public struct Send {
                public static let destination = NSLocalizedString(
                    "My PIT %@ Wallet",
                    comment: "PIT address as per asset type"
                )
            }
        }
        
        public struct Send {
            public static let destination = NSLocalizedString(
                "My PIT %@ Wallet",
                comment: "PIT address for a wallet"
            )
        }
    }
    
    // MARK: - Transfer Screen
    
    public struct Send {
        public struct Source {
            public static let subject = NSLocalizedString(
                "From",
                comment: "Transfer screen: source address / account subject"
            )
        }
        
        public struct Destination {
            public static let subject = NSLocalizedString(
                "To",
                comment: "Transfer screen: destination address / account subject"
            )
            public static let placeholder = NSLocalizedString(
                "Enter %@ address",
                comment: "Transfer screen: destination address / account placeholder"
            )
            public static let pitCover = NSLocalizedString(
                "My PIT %@ Wallet",
                comment: "PIT address for a wallet"
            )
        }
        
        public struct Fees {
            public static let subject = NSLocalizedString(
                "Fees",
                comment: "Transfer screen: fees subject"
            )
        }
        
        public struct SpendableBalance {
            public static let prefix = NSLocalizedString(
                "Use total spendable balance: ",
                comment: "String displayed to the user when they want to send their full balance to an address."
            )
        }
        
        public static let primaryButton = NSLocalizedString(
            "Continue",
            comment: "Transfer screen: primary CTA button"
        )
        
        public struct Error {
            public struct Balance {
                public static let title = NSLocalizedString(
                    "Not Enough %@",
                    comment: "Prefix for alert title when there is not enough balance"
                )
                public static let description = NSLocalizedString(
                    "You will need %@ to send the transaction",
                    comment: "Prefix for alert description when there is not enough balance"
                )
                public static let descriptionERC20 = NSLocalizedString(
                    "You will need ETH to send your ERC20 Token",
                    comment: "Prefix for alert description when there is not enough balance"
                )
            }
            public struct DestinationAddress {
                public static let title = NSLocalizedString(
                    "Invalid %@ Address",
                    comment: "Prefix for alert title when the destination address is invalid"
                )
                public static let description = NSLocalizedString(
                    "You must enter a valid %@ address to send the transaction",
                    comment: "Prefix for alert description when the destination address is invalid"
                )
                public static let descriptionERC20 = NSLocalizedString(
                    "You must enter a valid %@ address to send your ERC20 Token",
                    comment: "Prefix for alert description when the destination address is invalid"
                )
            }
            public struct PendingTransaction {
                public static let title = NSLocalizedString(
                    "Waiting for Payment",
                    comment: "Alert title when transaction cannot be sent because there is another in progress"
                )
                public static let description = NSLocalizedString(
                    "Please wait until your last ETH transaction confirms",
                    comment: "Alert description when transaction cannot be sent because there is another in progress"
                )
            }
        }
    }

    public struct SideMenu {
        public static let loginToWebWallet = NSLocalizedString("Pair Web Wallet", comment: "")
        public static let logout = NSLocalizedString("Logout", comment: "")
        public static let debug = NSLocalizedString("Debug", comment: "")
        public static let logoutConfirm = NSLocalizedString("Do you really want to log out?", comment: "")
        public static let buySellBitcoin = NSLocalizedString(
            "Buy & Sell Bitcoin",
            comment: "Item displayed on the side menu of the app for when the user wants to buy and sell Bitcoin."
        )
        public static let addresses = NSLocalizedString(
            "Addresses",
            comment: "Item displayed on the side menu of the app for when the user wants to view their crypto addresses."
        )
        public static let backupFunds = NSLocalizedString(
            "Backup Funds",
            comment: "Item displayed on the side menu of the app for when the user wants to back up their funds by saving their 12 word mneumonic phrase."
        )
        public static let airdrops = NSLocalizedString(
            "Airdrops",
            comment: "Item displayed on the side menu of the app for airdrop center navigation"
        )
        public static let swap = NSLocalizedString(
            "Swap",
            comment: "Item displayed on the side menu of the app for when the user wants to exchange crypto-to-crypto."
        )
        public static let settings = NSLocalizedString(
            "Settings",
            comment: "Item displayed on the side menu of the app for when the user wants to view their wallet settings."
        )
        public static let support = NSLocalizedString(
            "Support",
            comment: "Item displayed on the side menu of the app for when the user wants to contact support."
        )
        public static let new = NSLocalizedString(
            "New",
            comment: "New tag shown for menu items that are new."
        )
        public static let lockbox = NSLocalizedString(
            "Lockbox",
            comment: "Lockbox menu item title."
        )
        public struct PITMenuItem {
            public static let titleA = NSLocalizedString("The PIT Exchange", comment: "The PIT Exchange")
            public static let titleB = NSLocalizedString("Crypto Exchange", comment: "Crypto Exchange")
            public static let titleC = NSLocalizedString("Crypto Trading", comment: "Crypto Trading")
        }
    }

    public struct BuySell {
        public static let tradeCompleted = NSLocalizedString("Trade Completed", comment: "")
        public static let tradeCompletedDetailArg = NSLocalizedString("The trade you created on %@ has been completed!", comment: "")
        public static let viewDetails = NSLocalizedString("View details", comment: "")
        public static let errorTryAgain = NSLocalizedString("Something went wrong, please try reopening Buy & Sell Bitcoin again.", comment: "")
        public static let buySellAgreement = NSLocalizedString(
            "By tapping Begin Now, you agree to Coinify's Terms of Service & Privacy Policy",
            comment: "Disclaimer shown when starting KYC from Buy-Sell"
        )
    }
    
    public struct Exchange {
        public static let navigationTitle = NSLocalizedString(
            "Exchange",
            comment: "Title text shown on navigation bar for exchanging a crypto asset for another"
        )
        public static let complete = NSLocalizedString(
            "Complete",
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
        public static let refundInProgress = NSLocalizedString(
            "Refund in Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let refunded = NSLocalizedString(
            "Refunded",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )

        public static let orderHistory = NSLocalizedString(
            "Order History",
            comment: "Header for the exchange list"
        )

        public static let loading = NSLocalizedString(
            "Loading Exchange",
            comment: "Text presented when the wallet is loading the exchange"
        )
        public static let loadingTransactions = NSLocalizedString("Loading transactions", comment: "")
        public static let gettingQuote = NSLocalizedString("Getting quote", comment: "")
        public static let confirming = NSLocalizedString("Confirming", comment: "")
        public static let useMin = NSLocalizedString(
            "Use min",
            comment: "Text displayed on button for user to tap to create a trade with the minimum amount of crypto allowed"
        )
        public static let useMax = NSLocalizedString(
            "Use max",
            comment: "Text displayed on button for user to tap to create a trade with the maximum amount of crypto allowed"
        )
        public static let to = NSLocalizedString("To", comment: "Label for exchanging to a specific type of crypto")
        public static let from = NSLocalizedString("From", comment: "Label for exchanging from a specific type of crypto")
        public static let homebrewInformationText = NSLocalizedString(
            "All amounts are correct at this time but might change depending on the market price and transaction rates at the time your order is processed",
            comment: "Text displayed on exchange screen to inform user of changing market rates"
        )
        public static let orderID = NSLocalizedString("Order ID", comment: "Label in the exchange locked screen.")
        public static let exchangeLocked = NSLocalizedString("Exchange Locked", comment: "Header title for the Exchange Locked screen.")
        public static let done = NSLocalizedString("Done", comment: "Footer button title")
        public static let confirm = NSLocalizedString("Confirm", comment: "Footer button title for Exchange Confirmation screen")
        public static let creatingOrder = NSLocalizedString("Creating order", comment: "Loading text shown when a final exchange order is being created")
        public static let sendingOrder = NSLocalizedString("Sending order", comment: "Loading text shown when a final exchange order is being sent")
        public static let exchangeXForY = NSLocalizedString(
            "Exchange %@ for %@",
            comment: "Text displayed on the primary action button for the exchange screen when exchanging between 2 assets."
        )
        public static let receive = NSLocalizedString(
            "Receive",
            comment: "Text displayed when reviewing the amount to be received for an exchange order")
        public static let estimatedFees = NSLocalizedString(
            "Estimated fees",
            comment: "Text displayed when reviewing the estimated amount of fees to pay for an exchange order")
        public static let value = NSLocalizedString(
            "Value",
            comment: "Text displayed when reviewing the fiat value of an exchange order")
        public static let sendTo = NSLocalizedString(
            "Send to",
            comment: "Text displayed when reviewing where the result of an exchange order will be sent to")
        public static let expiredDescription = NSLocalizedString(
            "Your order has expired. No funds left your account.",
            comment: "Helper text shown when a user is viewing an order that has expired."
        )
        public static let delayedDescription = NSLocalizedString(
            "Your order has not completed yet due to network delays. It will be processed as soon as funds are received.",
            comment: "Helper text shown when a user is viewing an order that is delayed."
        )
        public static let tradeProblemWindow = NSLocalizedString(
            "Unfortunately, there is a problem with your order. We are researching and will resolve very soon.",
            comment: "Helper text shown when a user is viewing an order that is stuck (e.g. pending withdrawal and older than 24 hours)."
        )
        public static let failedDescription = NSLocalizedString(
            "There was a problem with your order.",
            comment: "Helper text shown when a user is viewing an order that has expired."
        )
        public static let whatDoYouWantToExchange = NSLocalizedString(
            "What do you want to exchange?",
            comment: "Text displayed on the action sheet that is presented when the user is selecting an account to exchange from."
        )
        public static let whatDoYouWantToReceive = NSLocalizedString(
            "What do you want to receive?",
            comment: "Text displayed on the action sheet that is presented when the user is selecting an account to exchange into."
        )

        public static let fees = NSLocalizedString("Fees", comment: "Fees")
        public static let confirmExchange = NSLocalizedString(
            "Confirm Exchange",
            comment: "Confirm Exchange"
        )
        public static let amountVariation = NSLocalizedString(
            "The amounts you send and receive may change slightly due to market activity.",
            comment: "Disclaimer in exchange locked screen"
        )
        public static let orderStartDisclaimer = NSLocalizedString(
            "Once an order starts, we are unable to stop it.",
            comment: "Second disclaimer in exchange locked screen"
        )
        public static let status = NSLocalizedString(
            "Status",
            comment: "Status of a trade in the exchange overview screen"
        )
        public static let exchange = NSLocalizedString(
            "Exchange",
            comment: "Exchange"
        )
        public static let aboveTradingLimit = NSLocalizedString(
            "Above trading limit",
            comment: "Error message shown when a user is attempting to exchange an amount above their designated limit"
        )
        public static let belowTradingLimit = NSLocalizedString(
            "Below trading limit",
            comment: "Error message shown when a user is attempting to exchange an amount below their designated limit"
        )
        public static let insufficientFunds = NSLocalizedString(
            "Insufficient funds",
            comment: "Error message shown when a user is attempting to exchange an amount greater than their balance"
        )

        public static let yourMin = NSLocalizedString(
            "Your Min is",
            comment: "Error that displays what the minimum amount of fiat is required for a trade"
        )
        public static let yourMax = NSLocalizedString(
            "Your Max is",
            comment: "Error that displays what the maximum amount of fiat allowed for a trade"
        )
        public static let notEnough = NSLocalizedString(
            "Not enough",
            comment: "Part of error message shown when the user doesn't have enough funds to make an exchange"
        )
        public static let yourBalance = NSLocalizedString(
            "Your balance is",
            comment: "Part of error message shown when the user doesn't have enough funds to make an exchange"
        )
        public static let tradeExecutionError = NSLocalizedString(
            "Sorry, an order cannot be placed at this time.",
            comment: "Error message shown to a user if something went wrong during the exchange process and the user cannot continue"
        )
        public static let exchangeListError = NSLocalizedString(
            "Sorry, your orders cannot be fetched at this time.",
            comment: "Error message shown to a user if something went wrong while fetching the user's exchange orders"
        )
        public static let yourSpendableBalance = NSLocalizedString(
            "Your spendable balance is",
            comment: "Error message shown to a user if they try to exchange more than what is permitted."
        )
        public static let marketsMoving = NSLocalizedString(
            "Markets are Moving 🚀",
            comment: "Error title when markets are fluctuating on the order confirmation screen"
        )
        public static let holdHorses = NSLocalizedString(
            "Whoa! Hold your horses. 🐴",
            comment: "Error title shown when users are exceeding their limits in the order confirmation screen."
        )
        public static let marketMovementMinimum = NSLocalizedString(
            "Due to market movement, your order value is now below the minimum required threshold of",
            comment: "Error message shown to a user if they try to exchange too little."
        )
        public static let marketMovementMaximum = NSLocalizedString(
            "Due to market movement, your order value is now above the maximum allowable threshold of",
            comment: "Error message shown to a user if they try to exchange too much."
        )
        public static let dailyAnnualLimitExceeded = NSLocalizedString(
            "There is a limit to how much crypto you can exchange. The value of your order must be less than your limit of",
            comment: "Error message shown to a user if they try to exchange beyond their limits whether annual or daily."
        )
        public static let oopsSomethingWentWrong = NSLocalizedString(
            "Ooops! Something went wrong.",
            comment: "Oops error title"
        )
        public static let oopsSwapDescription = NSLocalizedString(
            "We're not sure what happened but we didn't receive your order details.  Unfortunately, you're going to have to enter your order again.",
            comment: "Message that coincides with the `Oops! Something went wrong.` error title."
        )
        public static let somethingNotRight = NSLocalizedString(
            "Hmm, something's not right. 👀",
            comment: "Error title shown when a trade's status is `stuck`."
        )
        public static let somethingNotRightDetails = NSLocalizedString(
            "Most exchanges on Swap are completed seamlessly in two hours.  Please contact us. Together, we can figure this out.",
            comment: "Error description that coincides with `something's not right`."
        )
        public static let networkDelay = NSLocalizedString("Network Delays", comment: "Network Delays")
        public static let dontWorry = NSLocalizedString(
            "Don't worry, your exchange is in process. Swap trades are competed on-chain. If transaction volumes are high, there are sometimes delays.",
            comment: "Network delay description."
        )
        public static let moreInfo = NSLocalizedString("More Info", comment: "More Info")
        public static let updateOrder = NSLocalizedString("Update Order", comment: "Update Order")
        public static let tryAgain = NSLocalizedString("Try Again", comment: "try again")
        public static let increaseMyLimits = NSLocalizedString("Increase My Limits", comment: "Increase My Limits")
        public static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
    }

    public struct AddressAndKeyImport {

        public static let nonSpendable = NSLocalizedString("Non-Spendable", comment: "Text displayed to indicate that part of the funds in the user’s wallet is not spendable.")

        public static let copyWalletId = NSLocalizedString("Copy Wallet ID", comment: "")

        public static let copyCTA = NSLocalizedString("Copy to clipboard", comment: "")
        public static let copyWarning = NSLocalizedString(
        """
        Warning: Your wallet identifier is sensitive information. Copying it may compromise the security of your wallet.
        """, comment: "")

        public static let importedWatchOnlyAddressArgument = NSLocalizedString("Imported watch-only address %@", comment: "")
        public static let importedPrivateKeyArgument = NSLocalizedString("Imported Private Key %@", comment: "")
        public static let loadingImportKey = NSLocalizedString("Importing key", comment: "")
        public static let loadingProcessingKey = NSLocalizedString("Processing key", comment: "")
        public static let importedKeyButForIncorrectAddress = NSLocalizedString("You’ve successfully imported a private key.", comment: "")
        public static let importedKeyDoesNotCorrespondToAddress = NSLocalizedString("NOTE: The scanned private key does not correspond to this watch-only address. If you want to spend from this address, make sure that you scan the correct private key.", comment: "")
        public static let importedKeySuccess = NSLocalizedString("You can now spend from this address.", comment: "")
        public static let incorrectPrivateKey = NSLocalizedString("Incorrect private key", comment: "Incorrect private key")
        public static let keyAlreadyImported = NSLocalizedString("Key already imported", comment: "")
        public static let keyNeedsBip38Password = NSLocalizedString("Needs BIP38 Password", comment: "")
        public static let incorrectBip38Password = NSLocalizedString("Wrong BIP38 Password", comment: "")
        public static let unknownErrorPrivateKey = NSLocalizedString("There was an error importing this private key.", comment: "")
        public static let addressNotPresentInWallet = NSLocalizedString("Your wallet does not contain this address.", comment: "")
        public static let addressNotWatchOnly = NSLocalizedString("This address is not watch-only.", comment: "")
        public static let keyBelongsToOtherAddressNotWatchOnly = NSLocalizedString("This private key belongs to another address that is not watch only", comment: "")
        public static let unknownKeyFormat = NSLocalizedString("Unknown key format", comment: "")
        public static let unsupportedPrivateKey = NSLocalizedString("Unsupported Private Key Format", comment: "")
        public static let addWatchOnlyAddressWarning = NSLocalizedString("You are about to import a watch-only address, an address (or public key script) stored in the wallet without the corresponding private key. This means that the funds can be spent ONLY if you have the private key stored elsewhere. If you do not have the private key stored, do NOT inpublic struct anyone to send you bitcoin to the watch-only address.", comment: "")
        public static let addWatchOnlyAddressWarningPrompt = NSLocalizedString("These options are recommended for advanced users only. Continue?", comment: "")
    }

    public struct SendAsset {
        public static let useTotalSpendableBalance = NSLocalizedString(
            "Use total spendable balance: ",
            comment: "String displayed to the user when they want to send their full balance to an address."
        )
        public static let invalidXAddressY = NSLocalizedString(
            "Invalid %@ address: %@",
            comment: "String presented to the user when they try to scan a QR code with an invalid address."
        )
        public static let send = NSLocalizedString(
            "Send",
            comment: "Text displayed on the button for when a user wishes to send crypto."
        )
        public static let confirmPayment = NSLocalizedString(
            "Confirm Payment",
            comment: "Header displayed asking the user to confirm their payment."
        )
        public static let paymentSent = NSLocalizedString(
            "Payment sent",
            comment: "Alert message shown when crypto is successfully sent to a recipient."
        )
        public static let transferAllFunds = NSLocalizedString(
            "Transfer All Funds",
            comment: "Title shown to use when transferring funds from legacy addresses to their new wallet"
        )
        
        public static let paxComingSoonTitle = NSLocalizedString("USD PAX Coming Soon!", comment: "")
        public static let paxComingSoonMessage = NSLocalizedString("We’re bringing USD PAX to iOS. While you wait, Send, Receive & Exchange USD PAX on the web.", comment: "")
        public static let paxComingSoonLinkText = NSLocalizedString("What is USD PAX?", comment: "")
        public static let notEnoughEth = NSLocalizedString("Not Enough ETH", comment: "")
        public static let notEnoughEthDescription = NSLocalizedString("You'll need ETH to send your ERC20 Token", comment: "")
        public static let invalidDestinationAddress = NSLocalizedString("Invalid ETH Address", comment: "")
        public static let invalidDestinationDescription = NSLocalizedString("You must enter a valid ETH address to send your ERC20 Token", comment: "")
        public static let notEnough = NSLocalizedString("Not Enough", comment: "")
        public static let myPaxWallet = NSLocalizedString("My USD PAX Wallet", comment: "")
    }

    public struct SendEther {
        public static let waitingForPaymentToFinishTitle = NSLocalizedString("Waiting for payment", comment: "")
        public static let waitingForPaymentToFinishMessage = NSLocalizedString("Please wait until your last ether transaction confirms.", comment: "")
    }
    
    public struct Activity {
        public struct Pax {
            public static let emptyStateTitle = NSLocalizedString("USD PAX", comment: "")
            public static let emptyStateMessage = NSLocalizedString("Your USD PAX transactions will show up here once you make your first transaction.", comment: "")
            public static let emptyStateLinkText = NSLocalizedString("Learn more about USD PAX", comment: "")
            public static let emptyStateCTATitle = NSLocalizedString("Swap for USD PAX Now", comment: "")
        }
    }

    public struct Settings {
        public static let notificationsDisabled = NSLocalizedString(
        """
        You currently have email notifications enabled. Changing your email will disable email notifications.
        """, comment: "")
        public static let cookiePolicy = NSLocalizedString("Cookie Policy", comment: "")
        public static let allRightsReserved = NSLocalizedString("All rights reserved.", comment: "")
        public static let useBiometricsAsPin = NSLocalizedString("Use %@ as PIN", comment: "")
    }
    
    public struct PaymentReceivedAlert {
        public static let titleFormat = NSLocalizedString(
            "%@ Received",
            comment: "alert title format announcing a payment was received")
    }

    public struct Address {
        public struct Accessibility {
            public static let addressLabel = NSLocalizedString(
                "This is your address",
                comment: "Accessibility hint for the user's wallet address")
            public static let addressImageView = NSLocalizedString(
                "This is your address QR code",
                comment: "Accessibility hint for the user's wallet address qr code image")
            public static let copyButton = NSLocalizedString(
                "Copy",
                comment: "Accessibility hint for the user's wallet address copy button")
            public static let shareButton = NSLocalizedString(
                "Share",
                comment: "Accessibility hint for the user's wallet address copy button")
        }
        public static let copyButton = NSLocalizedString(
            "Copy",
            comment: "copy address button title before copy was made")
        public static let copiedButton = NSLocalizedString(
            "Copied!",
            comment: "copy address button title after copy was made")
        public static let shareButton = NSLocalizedString(
            "Share",
            comment: "share address button title")
        public static let titleFormat = NSLocalizedString(
            "%@ Wallet Address",
            comment: "format for wallet address title on address screen")
        public static let creatingStatusLabel = NSLocalizedString(
            "Creating a new address",
            comment: "Creating a new address status label")
        public static let loginToRefreshAddress = NSLocalizedString(
            "Log in to refresh addresses",
            comment: "Message that let the user know he has to login to refresh his wallet addresses")
    }

    public struct Receive {
        public static let tapToCopyThisAddress = NSLocalizedString(
            "Tap to copy this address. Share it with the sender via email or text.",
            comment: "Text displayed on the receive screen instructing the user to copy their crypto address."
        )
        public static let requestPayment = NSLocalizedString(
            "Request Payment",
            comment: "Text displayed on the button when requesting for payment to a crypto address."
        )
        public static let copiedToClipboard = NSLocalizedString(
            "Copied to clipboard",
            comment: "Text displayed when a crypto address has been copied to the users clipboard."
        )
        public static let enterYourSecondPassword = NSLocalizedString(
            "Enter Your Second Password",
            comment: "Text on the button prompting the user to enter their second password to proceed with creating a crypto account."
        )

        public static let secondPasswordPromptX = NSLocalizedString(
            "Your second password is required in order to create a %@ account.",
            comment: "Text shown when the second password is required to create an XLM account."
        )
        public static let xPaymentRequest = NSLocalizedString(
            "%@ payment request.",
            comment: "Subject when requesting payment for a given asset."
        )
        public static let pleaseSendXto = NSLocalizedString(
            "Please send %@ to",
            comment: "Message when requesting payment to a given asset."
        )
    }

    public struct ReceiveAsset {
        public static let xPaymentRequest = NSLocalizedString("%@ payment request", comment: "Subject of the email sent when requesting for payment from another user.")
    }

    public struct Transactions {
        public static let paxfee = NSLocalizedString("PAX Fee", comment: "String displayed to indicate that a transaction is due to a fee associated to sending PAX.")
        public static let allWallets = NSLocalizedString("All Wallets", comment: "Label of selectable item that allows user to show all transactions of a certain asset")
        public static let noTransactions = NSLocalizedString("No Transactions", comment: "Text displayed when no recent transactions are being shown")
        public static let noTransactionsAssetArgument = NSLocalizedString("Transactions occur when you send and receive %@.", comment: "Helper text displayed when no recent transactions are being shown")
        public static let requestArgument = NSLocalizedString("Request %@", comment: "Text shown when a user can request a certain asset")
        public static let getArgument = NSLocalizedString("Get %@", comment: "Text shown when a user can purchase a certain asset")
        public static let justNow = NSLocalizedString("Just now", comment: "text shown when a transaction has just completed")
        public static let secondsAgo = NSLocalizedString("%lld seconds ago", comment: "text shown when a transaction has completed seconds ago")
        public static let oneMinuteAgo = NSLocalizedString("1 minute ago", comment: "text shown when a transaction has completed one minute ago")
        public static let minutesAgo = NSLocalizedString("%lld minutes ago", comment: "text shown when a transaction has completed minutes ago")
        public static let oneHourAgo = NSLocalizedString("1 hour ago", comment: "text shown when a transaction has completed one hour ago")
        public static let hoursAgo = NSLocalizedString("%lld hours ago", comment: "text shown when a transaction has completed hours ago")
        public static let yesterday = NSLocalizedString("Yesterday", comment: "text shown when a transaction has completed yesterday")
    }

    public struct Backup {
        public static let wordNumberOfNumber = NSLocalizedString(
            "Word %@ of %@",
            comment: "text displayed when showing individual words of their recovery phrase"
        )
        public static let firstWord = NSLocalizedString(
            "first word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let secondWord = NSLocalizedString(
            "second word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let thirdWord = NSLocalizedString(
            "third word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let fourthWord = NSLocalizedString(
            "fourth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let fifthWord = NSLocalizedString(
            "fifth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let sixthWord = NSLocalizedString(
            "sixth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let seventhWord = NSLocalizedString(
            "seventh word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let eighthWord = NSLocalizedString(
            "eighth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let ninthWord = NSLocalizedString(
            "ninth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let tenthWord = NSLocalizedString(
            "tenth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let eleventhWord = NSLocalizedString(
            "eleventh word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let twelfthWord = NSLocalizedString(
            "twelfth word",
            comment: "text displayed when prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let verifyBackup = NSLocalizedString(
            "Verify Backup",
            comment: "Title displayed in the app for prompting the user to verify that they have written down all words of their recovery phrase"
        )
        public static let backupFunds = NSLocalizedString(
            "Backup Funds",
            comment: "Title displayed in the app for when the user wants to back up their funds by saving their 12 word mneumonic phrase."
        )
        public static let reminderBackupMessageFirstBitcoin = NSLocalizedString(
            "Congrats, you have bitcoin! Now let’s backup your wallet to ensure you can access your funds if you forget your password.",
            comment: "Reminder message for when the user has just received funds prior to having completed the backup phrase."
        )
        public static let reminderBackupMessageHasFunds = NSLocalizedString(
            "For your security, we do not keep any passwords on file. Backup your wallet to ensure your funds are safe in case you lose your password.",
            comment: "Reminder message for when the user already has funds prior to having completed the backup phrase."
        )
    }

    public struct LegacyUpgrade {
        public static let upgrade = NSLocalizedString(
            "Upgrade",
            comment: "The title of the side menu entry item."
        )
        public static let upgradeFeatureOne = NSLocalizedString(
            "Always know the market price",
            comment: "The description in the first view of the legacy wallet upgrade flow."
        )
        public static let upgradeFeatureTwo = NSLocalizedString(
            "Easy one time wallet backup keeps you in control of your funds.",
            comment: "The description in the second view of the legacy wallet upgrade flow."
        )
        public static let upgradeFeatureThree = NSLocalizedString(
            "Everything you need to store, spend and receive BTC, ETH and BCH.",
            comment: "The description in the third view of the legacy wallet upgrade flow."
        )
        public static let upgradeSuccess = NSLocalizedString(
            "You are now running our most secure wallet",
            comment: "The message displayed in the alert view after completing the legacy upgrade flow."
        )
        public static let upgradeSuccessTitle = NSLocalizedString(
            "Success!",
            comment: "The title of the alert view after completing the legacy upgrade flow."
        )
    }

    public struct AppReviewFallbackPrompt {
        public static let title = NSLocalizedString(
            "Rate Blockchain Wallet",
            comment: "The title of the fallback app review prompt."
        )
        public static let message = NSLocalizedString(
            "Enjoying the Blockchain Wallet? Please take a moment to leave a review in the App Store and let others know about it.",
            comment: "The message of the fallback app review prompt."
        )
        public static let affirmativeActionTitle = NSLocalizedString(
            "Yes, rate Blockchain Wallet",
            comment: "The title for the affirmative prompt action."
        )
        public static let secondaryActionTitle = NSLocalizedString(
            "Ask Me Later",
            comment: "The title for the secondary prompt action."
        )
    }

    public struct KYC {
        public static let welcome = NSLocalizedString("Welcome", comment: "Welcome")
        public static let welcomeMainText = NSLocalizedString(
            "Introducing Blockchain's faster, smarter way to trade your crypto. Upgrade now to enjoy benefits such as better prices, higher trade limits and live rates.",
            comment: "Text displayed when user is starting KYC"
        )
        public static let welcomeMainTextSunRiverCampaign = NSLocalizedString(
            "Complete your profile to start instantly trading crypto from the security of your wallet and become eligible for our Airdrop Program.",
            comment: "Text displayed when user is starting KYC coming from the airdrop link"
        )
        public static let invalidPhoneNumber = NSLocalizedString(
            "The mobile number you entered is invalid.",
            comment: "Error message displayed to the user when the phone number they entered during KYC is invalid.")
        public static let failedToConfirmNumber = NSLocalizedString(
            "Failed to confirm mobile number. Please try again.",
            comment: "Error message displayed to the user when the mobile confirmation steps fails."
        )
        public static let termsOfServiceAndPrivacyPolicyNotice = NSLocalizedString(
            "By hitting \"Begin Now\", you agree to Blockchain’s %@ & %@",
            comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they start the KYC process."
        )
        public static let verificationInProgress = NSLocalizedString(
            "Verification in Progress",
            comment: "Text displayed when KYC verification is in progress."
        )
        public static let verificationInProgressDescription = NSLocalizedString(
            "Your information is being reviewed. When all looks good, you’re clear to exchange. You should receive a notification within 5 minutes.",
            comment: "Description for when KYC verification is in progress."
        )
        public static let verificationInProgressDescriptionAirdrop = NSLocalizedString(
            "Your information is being reviewed. The review should complete in 5 minutes. Please be aware there is a large waiting list for Stellar airdrops and unfortunately not all applications for free XLM will be successful.",
            comment: "Description for when KYC verification is in progress and the user is waiting for a Stellar airdrop."
        )
        public static let accountApproved = NSLocalizedString(
            "Account Approved",
            comment: "Text displayed when KYC verification is approved."
        )
        public static let accountApprovedDescription = NSLocalizedString(
            "Congratulations! We successfully verified your identity. You can now Exchange cryptocurrencies at Blockchain.",
            comment: "Description for when KYC verification is approved."
        )
        public static let accountApprovedBadge = NSLocalizedString(
            "Approved",
            comment: "KYC verification is approved."
        )
        public static let accountInReviewBadge = NSLocalizedString(
            "In Review",
            comment: "KYC verification is in Review."
        )
        public static let accountUnderReviewBadge = NSLocalizedString(
            "Under Review",
            comment: "KYC verification is under Review."
        )
        public static let verificationUnderReview = NSLocalizedString(
            "Verification Under Review",
            comment: "Text displayed when KYC verification is under review."
        )
        public static let verificationUnderReviewDescription = NSLocalizedString(
            "We had some trouble verifying your account with the documents provided. Our support team will contact you shortly to resolve this.",
            comment: "Description for when KYC verification is under review."
        )
        public static let accountUnconfirmedBadge = NSLocalizedString(
            "Unconfirmed",
            comment: "KYC verification is unconfirmed."
        )
        public static let accountUnverifiedBadge = NSLocalizedString(
            "Unverified",
            comment: "KYC verification is unverified."
        )
        public static let accountVerifiedBadge = NSLocalizedString(
            "Verified",
            comment: "KYC verification is complete."
        )
        public static let verificationFailed = NSLocalizedString(
            "Verification Failed",
            comment: "Text displayed when KYC verification failed."
        )
        public static let verificationFailedBadge = NSLocalizedString(
            "Failed",
            comment: "Text displayed when KYC verification failed."
        )
        public static let verificationFailedDescription = NSLocalizedString(
            "Unfortunately we had some trouble verifying your identity with the documents you’ve supplied and your account can’t be verified at this time.",
            comment: "Description for when KYC verification failed."
        )
        public static let notifyMe = NSLocalizedString(
            "Notify Me",
            comment: "Title of the button the user can tap when they want to be notified of update with their KYC verification process."
        )
        public static let getStarted = NSLocalizedString(
            "Get Started",
            comment: "Title of the button the user can tap when they want to start trading on the Exchange. This is displayed after their KYC verification has been approved."
        )
        public static let contactSupport = NSLocalizedString(
            "Contact Support",
            comment: "Title of the button the user can tap when they want to contact support as a result of a failed KYC verification."
        )
        public static let whatHappensNext = NSLocalizedString(
            "What happens next?",
            comment: "Text displayed (subtitle) when KYC verification is under progress"
        )
        public static let comingSoonToX = NSLocalizedString(
            "Coming soon to %@!",
            comment: "Title text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        public static let unsupportedCountryDescription = NSLocalizedString(
            "Every country has different rules on how to buy and sell cryptocurrencies. Keep your eyes peeled, we’ll let you know as soon as we launch in %@!",
            comment: "Description text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        public static let unsupportedStateDescription = NSLocalizedString(
            "Every state has different rules on how to buy and sell cryptocurrencies. Keep your eyes peeled, we’ll let you know as soon as we launch in %@!",
            comment: "Description text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        public static let messageMeWhenAvailable = NSLocalizedString(
            "Message Me When Available",
            comment: "Text displayed on a button when the user wishes to be notified when crypto-to-crypto exchange is available in their country."
        )
        public static let yourHomeAddress = NSLocalizedString(
            "Your Home Address",
            comment: "Text displayed on the search bar when adding an address during KYC."
        )
        public static let whichDocumentAreYouUsing = NSLocalizedString(
            "Which document are you using?",
            comment: ""
        )
        public static let passport = NSLocalizedString(
            "Valid Passport",
            comment: "The title of the UIAlertAction for the passport option."
        )
        public static let driversLicense = NSLocalizedString(
            "Driver's License",
            comment: "The title of the UIAlertAction for the driver's license option."
        )
        public static let nationalIdentityCard = NSLocalizedString(
            "National ID Card",
            comment: "The title of the UIAlertAction for the national identity card option."
        )
        public static let residencePermit = NSLocalizedString(
            "Residence Card",
            comment: "The title of the UIAlertAction for the residence permit option."
        )
        public static let documentsNeededSummary = NSLocalizedString(
            "Unfortunately we're having trouble verifying your identity, and we need you to resubmit your verification information.",
            comment: "The main message shown in the Documents Needed screen."
        )
        public static let reasonsTitle = NSLocalizedString(
            "Main reasons for this to happen:",
            comment: "Title text in the Documents Needed screen preceding the list of reasons a user would need to resubmit their documents"
        )
        public static let reasonsDescription = NSLocalizedString(
            "The required photos are missing.\n\nThe document you submitted is incorrect.\n\nWe were unable to read the images you submitted due to image quality. ",
            comment: "Description text in the Documents Needed screen preceding the list of reasons a user would need to resubmit their documents"
        )
        public static let submittingInformation = NSLocalizedString(
            "Submitting information...",
            comment: "Text prompt to the user when the client is submitting the identity documents to Blockchain's servers."
        )
        public static let emailAddressAlreadyInUse = NSLocalizedString(
            "This email address has already been used to verify an existing wallet.",
            comment: "The error message when a user attempts to start KYC using an existing email address."
        )
        public static let failedToSendVerificationEmail = NSLocalizedString(
            "Failed to send verification email. Please try again.",
            comment: "The error message shown when the user tries to verify their email but the server failed to send the verification email."
        )
        public static let whyDoWeNeedThis = NSLocalizedString(
            "Why do we need this?",
            comment: "Header text for an a page in the KYC flow where we justify why a certain piece of information is being collected."
        )
        public static let enterEmailExplanation = NSLocalizedString(
            "We need to verify your email address as an added layer of security.",
            comment: "Text explaning to the user why we are collecting their email address."
        )
        public static let checkYourInbox = NSLocalizedString(
            "Check your inbox.",
            comment: "Header text telling the user to check their mail inbox to verify their email"
        )
        public static let confirmEmailExplanation = NSLocalizedString(
            "We just sent you an email with further instructions.",
            comment: "Text telling the user to check their mail inbox to verify their email."
        )
        public static let didntGetTheEmail = NSLocalizedString(
            "Didn't get the email?",
            comment: "Text asking if the user didn't get the verification email."
        )
        public static let sendAgain = NSLocalizedString(
            "Send again",
            comment: "Text asking if the user didn't get the verification email."
        )
        public static let emailSent = NSLocalizedString(
            "Email sent!",
            comment: "Text displayed when the email verification has successfully been sent."
        )
        public static let freeCrypto = NSLocalizedString(
            "Get Free Crypto",
            comment: "Headline displayed on a KYC Tier 2 Cell"
        )
        public static let unlock = NSLocalizedString(
            "Unlock",
            comment: "Prompt to complete a verification tier"
        )
        public static let tierZeroVerification = NSLocalizedString(
            "Tier zero",
            comment: "Tier 0 Verification"
        )
        public static let tierOneVerification = NSLocalizedString(
            "Silver Level",
            comment: "Tier 1 Verification"
        )
        public static let tierTwoVerification = NSLocalizedString(
            "Gold Level",
            comment: "Tier 2 Verification"
        )
        public static let annualSwapLimit = NSLocalizedString(
            "Annual Swap Limit",
            comment: "Annual Swap Limit"
        )
        public static let dailySwapLimit = NSLocalizedString(
            "Daily Swap Limit",
            comment: "Daily Swap Limit"
        )
        public static let takesThreeMinutes = NSLocalizedString(
            "Takes 3 min",
            comment: "Duration for Tier 1 application"
        )
        public static let takesTenMinutes = NSLocalizedString(
            "Takes 10 min",
            comment: "Duration for Tier 2 application"
        )
        public static let swapNow = NSLocalizedString("Swap Now", comment: "Swap Now")
        public static let swapLimits = NSLocalizedString("Swap Limits", comment: "Swap Limits")
        public static let swapTagline = NSLocalizedString(
            "Trading your crypto doesn't mean trading away control.",
            comment: "The tagline describing what Swap is"
        )
        public static let swapStatusInReview = NSLocalizedString(
            "In Review",
            comment: "Swap status is in review"
        )
        public static let swapStatusInReviewCTA = NSLocalizedString(
            "In Review - Need More Info",
            comment: "Swap status is in review but we require more info from the user."
        )
        public static let swapStatusUnderReview = NSLocalizedString(
            "Under Review",
            comment: "Swap status is under review."
        )
        public static let swapStatusApproved = NSLocalizedString(
            "Approved!",
            comment: "Swap status is approved."
        )
        public static let swapAnnouncement = NSLocalizedString(
            "Swap by Blockchain enables you to trade crypto with best prices, and quick settlement, all while maintaining full control of your funds.",
            comment: "The announcement and description describing what Swap is."
        )
        public static let swapLimitDescription = NSLocalizedString(
            "Your Swap Limit is the maximum amount of crypto you can trade.",
            comment: "A description of what the user's swap limit is."
        )
        public static let swapUnavailable = NSLocalizedString(
            "Swap Currently Unavailable",
            comment: "Swap Currently Unavailable"
        )
        public static let swapUnavailableDescription = NSLocalizedString(
            "We had trouble approving your identity. Your Swap feature has been disabled at this time.",
            comment: "A description as to why Swap has been disabled"
        )
        public static let available = NSLocalizedString(
            "Available",
            comment: "Available"
        )
        public static let availableToday = NSLocalizedString(
            "Available Today",
            comment: "Available Today"
        )
        public static let tierTwoVerificationIsBeingReviewed = NSLocalizedString(
            "Your Gold level verification is currently being reviewed by a Blockchain Support Member.",
            comment: "The Tiers overview screen when the user is approved for Tier 1 but they are in review for Tier 2"
        )
        public static let tierOneRequirements = NSLocalizedString(
            "Requires Email, Name, Date of Birth and Address",
            comment: "A descriptions of the requirements to complete Tier 1 verification"
        )
        // TODO: how should we handle conditional strings? What if the mobile requirement gets added back?
        public static let tierTwoRequirements = NSLocalizedString(
            "Requires Silver level, Govt. ID and a Selfie",
            comment: "A descriptions of the requirements to complete Tier 2 verification"
        )
        public static let notNow = NSLocalizedString(
            "Not Now",
            comment: "Text displayed when the user does not want to continue with tier 2 KYC."
        )
        public static let moreInfoNeededHeaderText = NSLocalizedString(
            "We Need Some More Information to Complete Your Profile",
            comment: "Header text when more information is needed from the user for KYCing"
        )
        public static let moreInfoNeededSubHeaderText = NSLocalizedString(
            "You’ll need to verify your phone number, provide a government issued ID and a Selfie.",
            comment: "Header text when more information is needed from the user for KYCing"
        )
        public static let openEmailApp = NSLocalizedString(
            "Open Email App",
            comment: "CTA for when the user should open the email app to continue email verification."
        )
        public static let submit = NSLocalizedString(
            "Submit",
            comment: "Text displayed on the CTA when submitting KYC information."
        )
        public static let termsOfServiceAndPrivacyPolicyNoticeAddress = NSLocalizedString(
            "By tapping Submit, you agree to Blockchain’s %@ & %@",
            comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they start the KYC process."
        )
        public static let completingTierTwoAutoEligible = NSLocalizedString(
            "By completing the Gold Level requirements you are automatically eligible for our airdrop program.",
            comment: "Description of what the user gets out of completing Tier 2 verification that is seen at the bottom of the Tiers screen. This particular description is when the user has been Tier 1 verified."
        )
        public static let needSomeHelp = NSLocalizedString("Need some help?", comment: "Need some help?")
        public static let helpGuides = NSLocalizedString(
            "Our Blockchain Support Team has written Help Guides explaining why we need to verify your identity",
            comment: "Description shown in modal that is presented when tapping the question mark in KYC."
        )
        public static let readNow = NSLocalizedString("Read Now", comment: "Read Now")
        public static let enableCamera = NSLocalizedString(
            "Also, enable your camera!",
            comment: "Requesting user to enable their camera"
        )
        public static let enableCameraDescription = NSLocalizedString(
            "Please allow your Blockchain App access your camera to upload your ID and take a Selfie.",
            comment: "Description as to why the user should permit camera access"
        )
        public static let enableMicrophoneDescription = NSLocalizedString(
            "Please allow your Blockchain app access to your microphone. This is an optional request designed to enhance user security while performing ID verification",
            comment: "Description as to why the user should permit microphone access"
        )
        public static let isCountrySupportedHeader = NSLocalizedString(
            "Is my country supported?",
            comment: "Header for text notifying the user that maybe not all countries are supported for airdrop."
        )
        public static let isCountrySupportedDescription1 = NSLocalizedString(
            "Not all countries are supported at this time. Check our up to date",
            comment: "Description for text notifying the user that maybe not all countries are supported for airdrop."
        )
        public static let isCountrySupportedDescription2 = NSLocalizedString(
            "list of countries",
            comment: "Description for text notifying the user that maybe not all countries are supported for airdrop."
        )
        public static let isCountrySupportedDescription3 = NSLocalizedString(
            "before proceeding.",
            comment: "Description for text notifying the user that maybe not all countries are supported for airdrop."
        )
        public static let allowCameraAccess = NSLocalizedString(
            "Allow camera access?",
            comment: "Headline in alert asking the user to allow camera access."
        )
        public static let allowMicrophoneAccess = NSLocalizedString(
            "Allow microphone access?",
            comment: "Headline in alert asking the user to allow microphone access."
        )
        public static let streetLine = NSLocalizedString("Street line", comment: "Street line")
        public static let addressLine = NSLocalizedString("Address line", comment: "Address line")
        public static let city = NSLocalizedString("City", comment: "city")
        public static let cityTownVillage = NSLocalizedString("City / Town / Village", comment: "City / Town / Village")
        public static let zipCode = NSLocalizedString("Zip Code", comment: "zip code")
        public static let required = NSLocalizedString("Required", comment: "required")
        public static let state = NSLocalizedString("State", comment: "state")
        public static let stateRegionProvinceCountry = NSLocalizedString("State / Region / Province / Country", comment: "State / Region / Province / Country")
        public static let postalCode = NSLocalizedString("Postal Code", comment: "postal code")
        public static let airdropLargeBacklogNotice = NSLocalizedString(
            "Gold verification is under review, once verified you'll be able to use Swap and trade up to our Gold Level limit.\n\nPlease be aware there is a large waiting list for Stellar airdrops and unfortunately not all applications for free XLM will be successful.",
            comment: "Footer in the tiers page notifying the user that the airdrop program has a large backlog."
        )
    }

    public struct Swap {
        public static let available = NSLocalizedString("Available", comment: "")
        public static let your = NSLocalizedString("Your", comment: "")
        public static let balance = NSLocalizedString("Balance", comment: "")
        public static let successfulExchangeDescription = NSLocalizedString("Success! Your Exchange has been started!", comment: "A successful swap alert")
        public static let viewOrderDetails = NSLocalizedString("View Order Details", comment: "View Order Details")
        public static let exchangeStarted = NSLocalizedString("Your Exchange has been started!", comment: "Your exchange has been started")
        public static let exchangeAirdropDescription = NSLocalizedString("Even better, since you need ETH to make USD PAX trades, we just airdropped enough ETH into your Wallet to cover your first 3 transactions 🙌🏻", comment: "ETH Airdrop description")
        public static let viewMySwapLimit = NSLocalizedString(
            "View My Swap Limit",
            comment: "Text displayed on the CTA when the user wishes to view their swap limits."
        )
        public static let helpDescription = NSLocalizedString(
            "Our Blockchain Support Team is standing by to help any questions you have.",
            comment: "Text displayed in the help modal."
        )
        public static let tier = NSLocalizedString(
            "Tier", comment: "Text shown to represent the level of access a user has to Swap features."
        )
        public static let locked = NSLocalizedString(
            "Locked", comment: "Text shown to indicate that Swap features have not been unlocked yet."
        )
        public static let swapLimit = NSLocalizedString(
            "Swap Limit", comment: "Text shown to represent the level of access a user has to Swap features."
        )
        public static let swap = NSLocalizedString(
            "Swap", comment: "Text shown for the crypto exchange service."
        )
        public static let exchange = NSLocalizedString(
            "Exchange", comment: "Button text shown on the exchange screen to progress to the confirm screen"
        )
        public static let confirmSwap = NSLocalizedString(
            "Confirm Swap", comment: "Button text shown on the exchange confirm screen to execute the swap"
        )
        public static let swapLocked = NSLocalizedString(
            "Swap Locked", comment: "Button text shown on the exchange screen to show that a swap has been confirmed"
        )
        public static let tierlimitErrorMessage = NSLocalizedString(
            "Your max is %@.", comment: "Error message shown on the exchange screen when a user's exchange input would exceed their tier limit"
        )
        public static let upgradeNow = NSLocalizedString(
            "Upgrade now.", comment: "Call to action shown to encourage the user to reach a higher swap tier"
        )
        public static let postTierError = NSLocalizedString(
            "An error occurred when selecting your tier. Please try again later.", comment: "Error shown when a user selects a tier and an error occurs when posting the tier to the server"
        )
        public static let swapCardMessage = NSLocalizedString(
            "Exchange one crypto for another without ever leaving your Blockchain Wallet.",
            comment: "Message on the swap card"
        )
        public static let checkItOut = NSLocalizedString("Check it out!", comment: "CTA on the swap card")
        public static let swapInfo = NSLocalizedString("Swap Info", comment: "Swap Info")
        public static let close = NSLocalizedString("Close", comment: "Close")
        public static let orderHistory = NSLocalizedString("Order History", comment: "Order History")
        
        public struct Tutorial {
            public struct PageOne {
                public static let title = NSLocalizedString("Welcome to Swap!", comment: "")
                public static let subtitle = NSLocalizedString("The easiest way to exchange one crypto for another without leaving your wallet.", comment: "")
            }
            public struct PageTwo {
                public static let title = NSLocalizedString("Real-time Exchange Rates", comment: "")
                public static let subtitle = NSLocalizedString("Access competitive crypto prices right at your fingertips.", comment: "")
            }
            public struct PageThree {
                public static let title = NSLocalizedString("100% On-Chain", comment: "")
                public static let subtitle = NSLocalizedString("All Swap trades are confirmed and settled directly on-chain.", comment: "")
            }
            public struct PageFour {
                public static let title = NSLocalizedString("You Control Your Key", comment: "")
                public static let subtitle = NSLocalizedString("With Swap your crypto is safe, secure, and your keys are always intact.", comment: "")
            }
            public struct PageFive {
                public static let title = NSLocalizedString("Manage Risk Better", comment: "")
                public static let subtitle = NSLocalizedString("Introducing Digital US Dollars (USD PAX) to de-risk your crypto investment or lock-in gains.", comment: "")
            }
        }
    }

    public struct Lockbox {
        public static let getYourLockbox = NSLocalizedString(
            "Get Your Lockbox",
            comment: "Title prompting the user to buy a lockbox."
        )
        public static let safelyStoreYourLockbox = NSLocalizedString(
            "Safely store your crypto currency offline.",
            comment: "Subtitle prompting the user to buy a lockbox."
        )
        public static let buyNow = NSLocalizedString(
            "Buy Now",
            comment: "Buy now CTA for a lockbox device."
        )
        public static let alreadyOwnOne = NSLocalizedString(
            "Already own one?",
            comment: "Title for anouncement card for the lockbox."
        )
        public static let announcementCardSubtitle = NSLocalizedString(
            "From your computer log into blockchain.com and connect your Lockbox.",
            comment: "Subtitle for anouncement card for the lockbox."
        )
        public static let balancesComingSoon = NSLocalizedString(
            "Balances Coming Soon",
            comment: "Title displayed to the user when they have a synced lockbox."
        )
        public static let balancesComingSoonSubtitle = NSLocalizedString(
            "We are unable to display your Lockbox balance at this time. Don’t worry, your funds are safe. We’ll be adding this feature soon. While you wait, you can check your balance on the web.",
            comment: "Subtitle display to the user when they have a synced lockbox."
        )
        public static let checkMyBalance = NSLocalizedString(
            "Check My Balance",
            comment: "CTA for when the user has a synced lockbox."
        )
        public static let wantToLearnMoreX = NSLocalizedString(
            "Want to learn more? Tap here to visit %@",
            comment: "Footer text in the lockbox view."
        )
    }

    public struct Stellar {
        public static let required = NSLocalizedString("Required", comment: "Required")
        public static let memoPlaceholder = NSLocalizedString("Used to identify transactions", comment: "Used to identify transactions")
        public static let sendingToExchange = NSLocalizedString("Sending to an Exchange?", comment: "Sending to an Exchange?")
        public static let addAMemo = NSLocalizedString("Add a Memo to avoid losing funds or use Swap to exchange in this wallet.", comment: "Add a Memo to avoid losing funds or use Swap to exchange in this wallet.")
        public static let memoTitle = NSLocalizedString("Memo", comment: "Memo title")
        public static let memoDescription = NSLocalizedString(
            "Memos are used to communicate optional information to the recipient.",
            comment: "Description of what a memo is and the two types of memos you can send."
        )
        public static let memoText = NSLocalizedString("Memo Text", comment: "memo text")
        public static let memoID = NSLocalizedString("Memo ID", comment: "memo ID")
        public static let minimumBalance = NSLocalizedString(
            "Minimum Balance",
            comment: "Title of page explaining XLM's minimum balance"
        )
        public static let minimumBalanceInfoExplanation = NSLocalizedString(
            "Stellar requires that all Stellar accounts hold a minimum balance of lumens, or XLM. This means you cannot send a balance out of your Stellar Wallet that would leave your Stellar Wallet with less than the minimum balance. This also means that in order to send XLM to a new Stellar account, you must send enough XLM to meet the minimum balance requirement.",
            comment: "General explanation for minimum balance for XLM."
        )
        public static let minimumBalanceInfoCurrentArgument = NSLocalizedString(
            "The current minimum balance requirement is %@.",
            comment: "Explanation for the current minimum balance for XLM."
        )
        public static let totalFundsLabel = NSLocalizedString(
            "Total Funds",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        public static let xlmReserveRequirement = NSLocalizedString(
            "XLM Reserve Requirement",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        public static let transactionFee = NSLocalizedString(
            "Transaction Fee",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        public static let availableToSend = NSLocalizedString(
            "Available to Send",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        public static let minimumBalanceMoreInformation = NSLocalizedString(
            "You can read more information about Stellar's minimum balance requirement at Stellar.org",
            comment: "Helper text for user to learn more about the minimum balance requirement for XLM."
        )
        public static let readMore = NSLocalizedString(
            "Read More",
            comment: "Button title for user to learn more about the minimum balance requirement for XLM."
        )
        public static let defaultLabelName = NSLocalizedString(
            "My Stellar Wallet",
            comment: "The default label of the XLM wallet."
        )
        public static let viewOnArgument = NSLocalizedString(
            "View on %@",
            comment: "Button title for viewing a transaction on the explorer")
        public static let cannotSendXLMAtThisTime = NSLocalizedString(
            "Cannot send XLM at this time. Please try again.",
            comment: "Error displayed when XLM cannot be sent due to an error."
        )
        public static let notEnoughXLM = NSLocalizedString(
            "Not enough XLM.",
            comment: "Error message displayed if the user tries to send XLM but does not have enough of it."
        )
        public static let invalidDestinationAddress = NSLocalizedString(
            "Invalid destination address",
            comment: "Error message displayed if the user tries to send XLM to an invalid address"
        )
        public static let useSpendableBalanceX = NSLocalizedString(
            "Use total spendable balance: ",
            comment: "Tappable text displayed in the send XLM screen for when the user wishes to send their full spendable balance."
        )
        public static let minimumForNewAccountsError = NSLocalizedString(
            "Minimum of 1.0 XLM needed for new accounts",
            comment: "This is the error shown when too little XLM is sent to a primary key that does not yet have an XLM account"
        )
        public static let kycAirdropTitle = NSLocalizedString(
            "Go for Gold",
            comment: "Title displayed in the onboarding card prompting the user to join the waitlist to receive Stellar."
        )
        public static let kycAirdropDescription = NSLocalizedString(
            "Complete your profile to start instantly trading crypto from the security of your wallet.",
            comment: "Description displayed on the onboarding card prompting the user to complete KYC to receive their airdrop."
        )
        public static let weNowSupportStellar = NSLocalizedString(
            "We Now Support Stellar",
            comment: "Title displayed in the onboarding card showing that we support Stellar."
        )
        public static let weNowSupportStellarDescription = NSLocalizedString(
            "XLM is a token that enables quick, low cost global transactions. Send, receive, and trade XLM in the wallet today.",
            comment: "Description displayed in the onboarding card showing that we support Stellar."
        )
        public static let getStellarNow = NSLocalizedString(
            "Get Stellar Now",
            comment: "CTA prompting the user to join the XLM waitlist."
        )
        public static let ohNo = NSLocalizedString(
            "Oh no!",
            comment: "Error title shown when deep linking from a claim your XLM link."
        )
    }
    
    public struct GeneralError {
        public static let loadingData = NSLocalizedString(
            "An error occurred while loading the data. Please try again.",
            comment: "A general data loading error display in an alert controller"
        )
    }

    public struct Airdrop {
        
        public struct CenterScreen {
            public static let title = NSLocalizedString(
                "Airdrops",
                comment: "Airdrop center screen: title"
            )
            public struct Cell {
                public static let fiatTitle = NSLocalizedString(
                    "%@ of %@",
                    comment: "Airdrop center screen: cell title"
                )
                public static let availableDescription = NSLocalizedString(
                    "Drops on %@",
                    comment: "Airdrop center screen: available cell description"
                )
                public static let endedDescription = NSLocalizedString(
                    "Ended on %@",
                    comment: "Airdrop center screen: ended cell description"
                )
            }
            
            public struct Header {
                public static let startedTitle = NSLocalizedString(
                    "Available",
                    comment: "Airdrop center screen: available header title"
                )
                public static let endedTitle = NSLocalizedString(
                    "Ended",
                    comment: "Airdrop center screen: ended header title"
                )
            }
        }
        
        public struct StatusScreen {
            public static let title = NSLocalizedString(
                "Airdrop",
                comment: "Airdrop status screen: title"
            )
            public struct Blockstack {
                public static let title = NSLocalizedString(
                    "Blockstack (STX)",
                    comment: "Airdrop status screen: blockstack, title"
                )
                public static let description = NSLocalizedString(
                    "Own your digital identity and data with hundreds of decentralized apps built with Blockstack.",
                    comment: "Airdrop status screen: blockstack, description"
                )
            }
            public struct Stellar {
                public static let title = NSLocalizedString(
                    "Stellar (XLM)",
                    comment: "Airdrop status screen: stellar, title"
                )
                public static let description = NSLocalizedString(
                    "Stellar is an open-source, decentralized payment protocol that allows for fast and cheap cross-border transactions between any pair of currencies.",
                    comment: "Airdrop status screen: stellar, description"
                )
            }
            public struct Cell {
                public struct Status {
                    public static let label = NSLocalizedString(
                        "Status",
                        comment: "Airdrop status screen: blockstack, status"
                    )
                    public static let received = NSLocalizedString(
                        "Received",
                        comment: "Airdrop status screen: received status"
                    )
                    public static let expired = NSLocalizedString(
                        "Offer Expired",
                        comment: "Airdrop status screen: received status"
                    )
                    public static let failed = NSLocalizedString(
                        "Ineligible",
                        comment: "Airdrop status screen: received status"
                    )
                    public static let claimed = NSLocalizedString(
                        "Claimed",
                        comment: "Airdrop status screen: claimed status"
                    )
                    public static let enrolled = NSLocalizedString(
                        "Enrolled",
                        comment: "Airdrop status screen: enrolled status"
                    )
                    public static let notRegistered = NSLocalizedString(
                        "Not Registered",
                        comment: "Airdrop status screen: not registered status"
                    )
                }
                public struct Amount {
                    public static let label = NSLocalizedString(
                        "Amount",
                        comment: "Airdrop status screen: amount label"
                    )
                    public static let value = NSLocalizedString(
                        "xxx %@ (%@ %@)",
                        comment: "Airdrop status screen: amount value format"
                    )
                }
                public static let date = NSLocalizedString(
                    "Date",
                    comment: "Airdrop status screen: date"
                )

                public static let airdropName = NSLocalizedString(
                    "Airdrop",
                    comment: "Airdrop status screen: airdrop name"
                )
                public static let currency = NSLocalizedString(
                    "Currency",
                    comment: "Airdrop status screen: currency"
                )
            }
        }
        
        public struct IntroScreen {
            public static let title = NSLocalizedString(
                "Get Free Crypto.",
                comment: "Airdrop intro screen: title"
            )
            public static let subtitle = NSLocalizedString(
                "With Blockchain Airdrops, get free crypto sent right to your Blockchain Wallet.",
                comment: "Airdrop intro screen: subtitle"
            )
            public static let disclaimerPrefix = NSLocalizedString(
                "Due to local laws, USA, Canada and Japan nationals cannot particpate in the Blockstack Airdrop.",
                comment: "Airdrop intro screen: description"
            )
            public static let disclaimerLearnMoreLink = NSLocalizedString(
                "Learn more",
                comment: "Airdrop intro screen: learn more link"
            )
            public static let ctaButton = NSLocalizedString(
                "Upgrade to Gold. Get $10",
                comment: "Airdrop intro screen: CTA button"
            )
            public struct InfoCell {
                public struct Number {
                    public static let title = NSLocalizedString(
                        "Current Airdrop",
                        comment: "Airdrop intro screen number of airdrop cell: title"
                    )
                    public static let value = NSLocalizedString(
                        "02 - Blockstack",
                        comment: "Airdrop intro screen number of airdrop cell: value"
                    )
                }
                public struct Currency {
                    public static let title = NSLocalizedString(
                        "Currency",
                        comment: "Airdrop intro screen currency of airdrop cell: title"
                    )
                    public static let value = NSLocalizedString(
                        "Stacks",
                        comment: "Airdrop intro screen currency of airdrop cell: value"
                    )
                }
            }
        }
        
        public static let invalidCampaignUser = NSLocalizedString(
            "We're sorry, the airdrop program is currently not available where you are.",
            comment: "Error message displayed when the user that is trying to register for the campaign cannot register."
        )
        public static let alreadyRegistered = NSLocalizedString(
            "Looks like you've already received your airdrop!",
            comment: "Error message displayed when the user has already claimed their airdrop."
        )
        public static let xlmCampaignOver = NSLocalizedString(
            "We're sorry, the XLM airdrop is over. Complete your profile to be eligible for future airdrops and access trading.",
            comment: "Error message displayed when the XLM airdrop is over."
        )
        public static let genericError = NSLocalizedString(
            "Oops! We had trouble processing your airdrop. Please try again.",
            comment: "Generic airdrop error."
        )
    }
    
    public struct AuthType {
        public static let google = NSLocalizedString(
            "Google",
            comment: "2FA alert: google type"
        )
        public static let yubiKey = NSLocalizedString(
            "Yubi Key",
            comment: "2FA alert: google type"
        )
        public static let sms = NSLocalizedString(
            "SMS",
            comment: "2FA alert: sms type"
        )
    }
}

// TODO: deprecate this once Obj-C is no longer using this
/// LocalizationConstants class wrapper so that LocalizationConstants can be accessed from Obj-C.
@objc public class LocalizationConstantsObjcBridge: NSObject {
    
    @objc public class func etherSecondPasswordPrompt() -> String { return LocalizationConstants.Authentication.EtherPasswordScreen.description }

    @objc public class func privateKeyNeeded() -> String { return LocalizationConstants.Authentication.ImportKeyPasswordScreen.title }

    
    @objc public class func paxFee() -> String { return LocalizationConstants.Transactions.paxfee }

    @objc public class func copiedToClipboard() -> String { return LocalizationConstants.Receive.copiedToClipboard }

    @objc public class func createWalletLegalAgreementPrefix() -> String {
        return LocalizationConstants.Onboarding.termsOfServiceAndPrivacyPolicyNoticePrefix
    }

    @objc public class func termsOfService() -> String {
        return LocalizationConstants.tos
    }

    @objc public class func privacyPolicy() -> String {
        return LocalizationConstants.privacyPolicy
    }
    
    @objc public class func twoFactorPITDisabled() -> String { return LocalizationConstants.PIT.twoFactorNotEnabled }
    
    @objc public class func sendAssetPitDestination() -> String { return LocalizationConstants.PIT.Send.destination }

    @objc public class func tapToCopyThisAddress() -> String { return LocalizationConstants.Receive.tapToCopyThisAddress }

    @objc public class func requestPayment() -> String { return LocalizationConstants.Receive.requestPayment }

    @objc public class func continueString() -> String { return LocalizationConstants.continueString }

    @objc public class func warning() -> String { return LocalizationConstants.Errors.warning }

    @objc public class func requestFailedCheckConnection() -> String { return LocalizationConstants.Errors.requestFailedCheckConnection }

    @objc public class func information() -> String { return LocalizationConstants.information }

    @objc public class func error() -> String { return LocalizationConstants.Errors.error }

    @objc public class func noInternetConnection() -> String { return LocalizationConstants.Errors.noInternetConnection }

    @objc public class func onboardingRecoverFunds() -> String { return LocalizationConstants.Onboarding.recoverFunds }

    @objc public class func tryAgain() -> String { return LocalizationConstants.tryAgain }

    @objc public class func passwordRequired() -> String { return LocalizationConstants.Authentication.passwordRequired }

    @objc public class func loadingWallet() -> String { return LocalizationConstants.Authentication.loadingWallet }

    @objc public class func timedOut() -> String { return LocalizationConstants.Errors.timedOut }

    @objc public class func incorrectPin() -> String { return LocalizationConstants.Pin.incorrect }

    @objc public class func logout() -> String { return LocalizationConstants.SideMenu.logout }

    @objc public class func debug() -> String { return LocalizationConstants.SideMenu.debug }

    @objc public class func noPasswordEntered() -> String { return LocalizationConstants.Authentication.noPasswordEntered }

    @objc public class func success() -> String { return LocalizationConstants.success }

    @objc public class func syncingWallet() -> String { return LocalizationConstants.syncingWallet }

    @objc public class func loadingImportKey() -> String { return LocalizationConstants.AddressAndKeyImport.loadingImportKey }

    @objc public class func loadingProcessingKey() -> String { return LocalizationConstants.AddressAndKeyImport.loadingProcessingKey }

    @objc public class func incorrectBip38Password() -> String { return LocalizationConstants.AddressAndKeyImport.incorrectBip38Password }

    @objc public class func scanQRCode() -> String { return LocalizationConstants.scanQRCode }

    @objc public class func nameAlreadyInUse() -> String { return LocalizationConstants.Errors.nameAlreadyInUse }

    @objc public class func unknownKeyFormat() -> String { return LocalizationConstants.AddressAndKeyImport.unknownKeyFormat }

    @objc public class func unsupportedPrivateKey() -> String { return LocalizationConstants.AddressAndKeyImport.unsupportedPrivateKey }

    @objc public class func cookiePolicy() -> String { return LocalizationConstants.Settings.cookiePolicy }

    @objc public class func gettingQuote() -> String { return LocalizationConstants.Exchange.gettingQuote }

    @objc public class func confirming() -> String { return LocalizationConstants.Exchange.confirming }

    @objc public class func loadingTransactions() -> String { return LocalizationConstants.Exchange.loadingTransactions }

    @objc public class func xPaymentRequest() -> String { return LocalizationConstants.ReceiveAsset.xPaymentRequest }

    @objc public class func invalidXAddressY() -> String { return LocalizationConstants.SendAsset.invalidXAddressY }

    @objc public class func reminderBackupMessageFirstBitcoin() -> String { return LocalizationConstants.Backup.reminderBackupMessageFirstBitcoin }

    @objc public class func reminderBackupMessageHasFunds() -> String { return LocalizationConstants.Backup.reminderBackupMessageHasFunds }

    @objc public class func upgradeSuccess() -> String { return LocalizationConstants.LegacyUpgrade.upgradeSuccess }

    @objc public class func upgradeSuccessTitle() -> String { return LocalizationConstants.LegacyUpgrade.upgradeSuccessTitle }

    @objc public class func upgrade() -> String { return LocalizationConstants.LegacyUpgrade.upgrade }

    @objc public class func upgradeFeatureOne() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureOne }

    @objc public class func upgradeFeatureTwo() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureTwo }

    @objc public class func upgradeFeatureThree() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureThree }

    @objc public class func nonSpendable() -> String { return LocalizationConstants.AddressAndKeyImport.nonSpendable }

    @objc public class func dontShowAgain() -> String { return LocalizationConstants.dontShowAgain }

    @objc public class func loadingExchange() -> String { return LocalizationConstants.Exchange.loading }

    @objc public class func myEtherWallet() -> String { return LocalizationConstants.myEtherWallet }

    @objc public class func notEnoughXForFees() -> String { return LocalizationConstants.Errors.notEnoughXForFees }

    @objc public class func balances() -> String { return LocalizationConstants.balances }

    @objc public class func dashboardBitcoinPrice() -> String { return LocalizationConstants.Dashboard.bitcoinPrice }

    @objc public class func dashboardEtherPrice() -> String { return LocalizationConstants.Dashboard.etherPrice }

    @objc public class func dashboardBitcoinCashPrice() -> String { return LocalizationConstants.Dashboard.bitcoinCashPrice }

    @objc public class func dashboardStellarPrice() -> String { return LocalizationConstants.Dashboard.stellarPrice }

    @objc public class func justNow() -> String { return LocalizationConstants.Transactions.justNow }

    @objc public class func secondsAgo() -> String { return LocalizationConstants.Transactions.secondsAgo }

    @objc public class func oneMinuteAgo() -> String { return LocalizationConstants.Transactions.oneMinuteAgo }

    @objc public class func minutesAgo() -> String { return LocalizationConstants.Transactions.minutesAgo }

    @objc public class func oneHourAgo() -> String { return LocalizationConstants.Transactions.oneHourAgo }

    @objc public class func hoursAgo() -> String { return LocalizationConstants.Transactions.hoursAgo }

    @objc public class func yesterday() -> String { return LocalizationConstants.Transactions.yesterday }

    @objc public class func myBitcoinWallet() -> String { return LocalizationConstants.ObjCStrings.BC_STRING_MY_BITCOIN_WALLET }

    @objc public class func balancesErrorGeneric() -> String { return LocalizationConstants.Errors.balancesGeneric }
}
