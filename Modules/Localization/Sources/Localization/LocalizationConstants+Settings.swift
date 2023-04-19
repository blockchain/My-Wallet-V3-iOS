// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum Settings {}
}

extension LocalizationConstants.Settings {
    public enum Section {
        public static let profile = NSLocalizedString("Profile", comment: "Profile")
        public static let preferences = NSLocalizedString("Preferences", comment: "Preferences")
        public static let exchangeLink = NSLocalizedString("Exchange Link", comment: "Exchange Link")
        public static let security = NSLocalizedString("Security", comment: "Security")
        public static let linkedCards = NSLocalizedString("Linked Cards", comment: "Linked Cards")
        public static let linkedBanks = NSLocalizedString("Linked Banks", comment: "Linked Banks")
        public static let help = NSLocalizedString("Help", comment: "Help settings section title")
    }

    public enum Badge {
        public enum Limits {
            public static let unlockGold = NSLocalizedString("Get Full Access", comment: "Unlock Tier 2")
            public static let inReview = NSLocalizedString("In Review", comment: "KYC status is under review")
            public static let failed = NSLocalizedString("Failed", comment: "Verification Failed")
        }

        public static let mobileNumber = NSLocalizedString("Mobile Number", comment: "Mobile Number")
        public static let email = NSLocalizedString("Email", comment: "Email")
        public static let blockchainExchange = NSLocalizedString("Blockchain Exchange", comment: "Blockchain Exchange")
        public static let recoveryPhrase = NSLocalizedString("Backup Phrase", comment: "Backup phrase")
        public static let confirmed = NSLocalizedString("Confirmed", comment: "Confirmed")
        public static let unconfirmed = NSLocalizedString("Unconfirmed", comment: "Unconfirmed")
        public static let walletDisplayCurrency = NSLocalizedString("Wallet Display Currency", comment: "Wallet Display Currency")
        public static let tradingCurrency = NSLocalizedString("Trading Currency", comment: "Trading Currency")
        public static let notifications = NSLocalizedString("Notifications", comment: "Notifications")
        public static let orderCard = NSLocalizedString("Order Card", comment: "Order Card")
        public static let expired = NSLocalizedString("Expired", comment: "Expired")
        public static let pending = NSLocalizedString("Pending", comment: "Pending")
        public static let inReview = NSLocalizedString("In Review", comment: "In Review")
        public static let unknown = NSLocalizedString("Unknown", comment: "Unknown")
        public static let limit = NSLocalizedString("Limit", comment: "Limit")
        public static let expires = NSLocalizedString("Exp:", comment: "Exp: - Abbreviation for expiration")
    }

    public enum About {
        public static let version = NSLocalizedString("Wallet Version", comment: "Wallet Version")
        public static let copyright = NSLocalizedString("© %i Blockchain.com All rights reserved.", comment: "© Blockchain Luxembourg S.A. All rights reserved.")
    }

    public static let emailNotifications = NSLocalizedString("Email Notifications", comment: "Email Notifications")
    public static let notificationsDisabled = NSLocalizedString(
        """
        You currently have email notifications enabled. Changing your email will disable email notifications.
        """, comment: ""
    )
    public static let twoFactorAuthentication = NSLocalizedString("2-Step Verification", comment: "2-Step Verification")
    public static let cloudBackup = NSLocalizedString("Cloud Backup", comment: "Cloud Backup")
    public static let cookiePolicy = NSLocalizedString("Cookie Policy", comment: "Cookie Policy")
    public static let allRightsReserved = NSLocalizedString("All rights reserved.", comment: "All rights reserved")
    public static let useBiometricsAsPin = NSLocalizedString("Use %@ as PIN", comment: "")
    public static let walletID = NSLocalizedString("Wallet ID", comment: "Wallet ID")
    public static let rateUs = NSLocalizedString("Rate Us", comment: "Rate Us")
    public static let termsOfService = NSLocalizedString("Terms of Service", comment: "Terms of Service")
    public static let privacyPolicy = NSLocalizedString("Privacy Policy", comment: "Privacy Policy")
    public static let cookiesPolicy = NSLocalizedString("Cookies Policy", comment: "Cookies Policy")
    public static let logout = NSLocalizedString("Logout", comment: "Logout cell title in settings")
    public static let deleteAccount = NSLocalizedString("Delete Account", comment: "Delete Account title in settings")
    public static let contactSupport = NSLocalizedString("Contact Support", comment: "Contact support cell title in settings")
    public static let changePIN = NSLocalizedString("Change PIN", comment: "Change PIN")
    public static let loginToWebWallet = NSLocalizedString("Login to Web Wallet", comment: "Log in to Web Wallet")
    public static let webLogin = NSLocalizedString("Web Log In", comment: "Log in to Web Wallet")
    public static let changePassword = NSLocalizedString("Change Password", comment: "Change Password")
    public static let enableTouchID = NSLocalizedString("Enable Touch ID", comment: "Enable Touch ID")
    public static let enableFaceID = NSLocalizedString("Enable Face ID", comment: "Enable Face ID")
    public static let expires = NSLocalizedString("Exp:", comment: "Abbreviation for Expiration")
    public static let cryptoDomainsTitle = NSLocalizedString("Domains", comment: "Domains cell title")
    public static let cryptoDomainsClaim = NSLocalizedString("Claim for free", comment: "Claim for free text")
    public enum Card {
        public static let add = NSLocalizedString("Add a Card", comment: "Add a Card")
        public static let maximum = NSLocalizedString(
            "You can have a maximum of five cards",
            comment: "You can have a maximum of five cards"
        )
        public static let remove = NSLocalizedString("Remove Card", comment: "Remove Card")
        public static let unverified = NSLocalizedString(
            "You must have Full Access level verification status to add a credit card.",
            comment: "You must have Full Access level verification status to add a credit card."
        )
    }

    public enum Bank {
        public static let addPrefix = NSLocalizedString("Add a", comment: "Add a")
        public static let addSuffix = NSLocalizedString("Bank", comment: "Bank")

        public static let maximum = NSLocalizedString(
            "You can have a maximum of one bank per currency",
            comment: "You can have a maximum of one bank per currency"
        )
        public static let remove = NSLocalizedString("Remove Bank", comment: "Remove Bank")
        public static let unverified = NSLocalizedString(
            "You must have Full Access level verification status to link a bank.",
            comment: "You must have Full Access level verification status to link a bank"
        )

        public static let dailyLimit = NSLocalizedString("Daily Limit", comment: "Daily Limit")
    }

    public enum RemoveCardScreen {
        public static let action = NSLocalizedString("Remove Card", comment: "Remove Card")
    }

    public enum UpdateMobile {
        public static let title = NSLocalizedString("Mobile Number", comment: "Mobile Number")
        public static let description = NSLocalizedString(
            "Your mobile phone can be used to enable two-factor authentication or to receive alerts.",
            comment: "Your mobile phone can be used to enable two-factor authentication or to receive alerts."
        )
        public static let disableSMS2FA = NSLocalizedString("You must disable SMS 2-Step Verification before changing your mobile number.", comment: "You must disable SMS 2-Step Verification before changing your mobile number.")
        public static let action = NSLocalizedString("Update", comment: "Update")
    }

    public enum MobileCodeEntry {
        public static let title = NSLocalizedString(
            "Enter 5-character code",
            comment: "Enter 5-character code"
        )
        public static let description = NSLocalizedString(
            "Please enter the 5-character code sent to your number",
            comment: "Please enter the 5-character code sent to your number"
        )
        public static let changeNumber = NSLocalizedString("Change my number", comment: "change my number")
        public static let resendCode = NSLocalizedString("Resend Code", comment: "resend code")
        public static let confirm = NSLocalizedString("Confirm", comment: "confirm")
    }

    public enum UpdateEmail {
        public static let title = NSLocalizedString("Email", comment: "Email")
        public static let description = NSLocalizedString(
            "Your verified email address is used to send payment alerts, ID reminders, and login codes.",
            comment: "Your verified email address is used to send payment alerts, ID reminders, and login codes."
        )
        public static let update = NSLocalizedString("Update", comment: "Update")
        public static let resend = NSLocalizedString("Resend", comment: "Resend")
    }

    public enum ChangePassword {
        public static let title = NSLocalizedString("Change my password", comment: "change password")
        public static let description = NSLocalizedString("Enter your current password. Then enter and confirm your new password.", comment: "Enter your current password. Then enter and confirm your new password.")
        public static let action = NSLocalizedString("Update Password", comment: "Update Password")
    }

    public enum SelectCurrency {
        public static let trading = NSLocalizedString(
            "Trading Currency",
            comment: "App Trading Currency Selection Screen: title"
        )
        public static let tradingDescription = NSLocalizedString(
            "This is the currency that you use to buy and sell crypto. ",
            comment: "App Trading Currency Selection Screen: description"
        )
        public static let title = NSLocalizedString(
            "Local Currency",
            comment: "App Currency Selection Screen: title"
        )
        public static let description = NSLocalizedString(
            "This is the currency in which your balance will be displayed.",
            comment: "App Currency Selection Screen: description"
        )
        public static let searchBarPlaceholder = NSLocalizedString(
            "Search Currency",
            comment: "App Currency Selection Screen: search bar placeholder"
        )
    }
}
