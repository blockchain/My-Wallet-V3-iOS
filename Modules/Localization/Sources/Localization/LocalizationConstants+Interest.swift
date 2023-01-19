// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

// MARK: Groups

extension LocalizationConstants {
    public enum Interest {
        public enum Screen {
            public enum EnterAmount {
                public enum Transfer {}
                public enum Withdraw {}
            }

            public enum Overview {
                public enum Action {}
            }

            public enum OverviewError {}

            public enum NoEligibleWallets {}
            public enum IdentityVerification {}
            public enum Announcement {}
            public enum AccountDetails {}
        }
    }
}

// MARK: - Screen.NoEligibleWallets

extension LocalizationConstants.Interest.Screen.NoEligibleWallets {

    public static let title = NSLocalizedString("Not Enough %@", comment: "Not Enough %@")
    public static let description = NSLocalizedString(
        "You’ll need buy or receive %@ to your %@ Blockchain.com Account before you can start earning %@ on %@.",
        comment: "You’ll need buy or receive %@ to your %@ Blockchain.com Account before you can start earning %@ on %@"
    )
    public static let action = NSLocalizedString("Buy %@ Now", comment: "Buy %@ Now")
}

// MARK: - Screen.Announcement

extension LocalizationConstants.Interest.Screen.Announcement {
    public static let title = NSLocalizedString("Earn Rewards on Your Crypto", comment: "Earn Rewards on Your Crypto")
    public static let description = NSLocalizedString("Start earning. Add BTC to your Rewards Account.", comment: "Start earning. Add BTC to your Rewards Account.")
    public enum Cells {
        public enum LineItem {
            public enum Rate {
                public static let title = NSLocalizedString("Current Rate", comment: "Current Rate")
            }

            public enum Interest {
                public static let title = NSLocalizedString("Rewards Paid", comment: "Rewards Paid")
                public static let description = NSLocalizedString("1st of Every Month", comment: "1st of Every Month")
            }

            public enum Currencies {
                public static let title = NSLocalizedString("Available Currencies", comment: "Available Currencies")
            }
        }

        public enum Footer {
            public static let title = NSLocalizedString("Please manage your BTC Rewards Account on the web at blockchain.com", comment: "Please manage your BTC Rewards Account on the web at blockchain.com")
        }

        public enum Button {
            public static let title = NSLocalizedString("Visit Blockchain.com", comment: "Visit Blockchain.com")
        }
    }
}

// MARK: - Screen.EnterAmount

extension LocalizationConstants.Interest.Screen.EnterAmount.Transfer {
    public static let title = NSLocalizedString("Add", comment: "Add")
    public static let useMin = NSLocalizedString("Minimum transfer of %@ required", comment: "Minimum transfer of %@ required")
    public static let useMax = NSLocalizedString("You can transfer up to %@", comment: "You can transfer up to %@")
}

extension LocalizationConstants.Interest.Screen.EnterAmount.Withdraw {
    public static let title = NSLocalizedString("Withdraw", comment: "Withdraw")
    public static let useMin = NSLocalizedString("Minimum withdraw of %@ required", comment: "Minimum withdraw of %@ required")
    public static let useMax = NSLocalizedString("You can withdraw up to %@", comment: "You can withdraw up to %@")
}

// MARK: - Screen.IdentityVerification

extension LocalizationConstants.Interest.Screen.IdentityVerification {
    public static let title = NSLocalizedString("Earn Rewards on Your Crypto", comment: "Earn Rewards on Your Crypto")
    public static let description = NSLocalizedString("Verify your identity and earn up to 9.0% annually.", comment: "Verify your identity and earn up to 9.0% annually.")
    public static let action = NSLocalizedString("Verify My Identity", comment: "Verify My Identity")
    public static let notNow = NSLocalizedString("Not Now", comment: "Not Now")
    public enum List {
        public enum First {
            public static let title = NSLocalizedString("Verify Your Identity", comment: "Verify Your Identity")
            public static let description = NSLocalizedString(
                "To prevent identity theft or fraud, we'll need to make sure it's really you by uploading an ID.",
                comment: "To prevent identity theft or fraud, we'll need to make sure it's really you by uploading an ID."
            )
        }

        public enum Second {
            public static let title = NSLocalizedString("Add BTC to Your Rewards Account", comment: "Add BTC to Your Rewards Account")
            public static let description = NSLocalizedString(
                "Send Bitcoin to your new Rewards Account. Deposit and withdraw at any time.",
                comment: "Send Bitcoin to your new Rewards Account. Deposit and withdraw at any time."
            )
        }

        public enum Third {
            public static let title = NSLocalizedString("Get Paid", comment: "Get Paid")
            public static let description = NSLocalizedString(
                "See your crypto balance increase every day. Get paid on the 1st of every month.",
                comment: "See your crypto balance increase every day. Get paid on the 1st of every month."
            )
        }
    }
}

// MARK: - Screen.Overview

extension LocalizationConstants.Interest.Screen.Overview {
    public static let title = NSLocalizedString(
        "Rewards Account",
        comment: "Rewards Account"
    )
    public static let loading = NSLocalizedString("Loading...", comment: "Loading...")
    public static let fetchingAccountStatus = NSLocalizedString("Fetching Your Account Status...", comment: "Fetching Your Account Status...")
    public static let fetchingRewardsAccounts = NSLocalizedString("Fetching Rewards Accounts...", comment: "Fetching Rewards Accounts...")
    public static let earnUpTo = NSLocalizedString(
        "Earn up to %@ annually on your %@",
        comment: "Earn up to %@ annually on your %@"
    )
    public static let totalEarned = NSLocalizedString(
        "Total Rewards Earned",
        comment: "Total Rewards Earned"
    )
    public static let balance = NSLocalizedString("Balance", comment: "Balance")
    public static let annually = NSLocalizedString("annually", comment: "annually")
}

// MARK: - Screen.OverviewError

extension LocalizationConstants.Interest.Screen.OverviewError {
    public static let navigationTitle = NSLocalizedString("Rewards Account", comment: "Rewards Account")
    public static let title = NSLocalizedString("Can't load Rewards Details", comment: "Can't load Rewards Details")
    public static let description = NSLocalizedString("An error occured while loading Rewards Account details.", comment: "An error occured while loading Rewards Account details.")
    public static let body = NSLocalizedString("Please check your Internet connection and try again or Contact Support if the issue persists.", comment: "Please check your Internet connection and try again or Contact Support if the issue persists.")
    public static let action = NSLocalizedString("Tap to Refresh", comment: "Tap to Refresh")
}

// MARK: - Screen.Overview.Actions

extension LocalizationConstants.Interest.Screen.Overview.Action {
    public static let view = NSLocalizedString("View", comment: "View")
    public static let earnInterest = NSLocalizedString(
        "Earn Rewards",
        comment: "Earn Rewards"
    )
    public static let notAvailable = NSLocalizedString(
        "Not available in your region",
        comment: "Not available in your region"
    )
    public static let tierTooLow = NSLocalizedString(
        "You need to have Full Access to start Earning Rewards",
        comment: "You need to be Tier 2 to start Earning Rewards"
    )
    public static let unavailable = NSLocalizedString(
        "Currently unavailable, please check again later",
        comment: "Currently unavailable, please check again later"
    )
}

// MARK: - Screen.AccountDetails

extension LocalizationConstants.Interest.Screen.AccountDetails {
    public static let loading = NSLocalizedString("Loading..", comment: "Loading...")
    public static let annually = NSLocalizedString("Annually", comment: "Annually")
    public static let withdraw = NSLocalizedString("Withdraw", comment: "Withdraw")
    public static let deposit = NSLocalizedString("Deposit", comment: "Deposit")
    public static let add = NSLocalizedString("Add", comment: "Add")
    public static let rewardsSummary = NSLocalizedString("Rewards Summary", comment: "Rewards Summary")
    public static let rewardsAccount = NSLocalizedString("Rewards Account", comment: "Rewards Account")
    public enum Cell {
        public enum Balance {
            public static let title = NSLocalizedString("Rewards Account", comment: "Rewards Account")
        }

        public enum Default {
            public enum Total {
                public static let title = NSLocalizedString("Total Rewards Earned", comment: "Total Rewards Earned")
            }

            public enum Next {
                public static let title = NSLocalizedString("Next Rewards Payment", comment: "Next Rewards Payment")
            }

            public enum Accrued {
                public static let title = NSLocalizedString(
                    "Accrued Rewards This Month",
                    comment: "Accrued Rewards This Month"
                )
            }

            public enum Hold {
                public static let title = NSLocalizedString(
                    "Initial Hold Period",
                    comment: "Initial Hold Period"
                )
            }

            public enum Rate {
                public static let title = NSLocalizedString(
                    "Rewards Rate",
                    comment: "Rewards Rate"
                )
            }
        }

        public enum Footer {
            public static let title = NSLocalizedString(
                "Manage your %@ Rewards Account on the web at blockchain.com",
                comment: "Manage your %@ Rewards Account on the web at blockchain.com"
            )
        }
    }
}
