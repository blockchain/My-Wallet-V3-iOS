//
//  LocalizationConstants+Dashboard.swift
//  Localization
//
//  Created by Alex McGregor on 10/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

// swiftlint:disable all

extension LocalizationConstants {
    public struct DashboardDetails {
        public struct BalanceCell {
            public struct Title {
                public static let trading = NSLocalizedString("Trading", comment: "Trading")
                public static let savings = NSLocalizedString("Interest", comment: "Interest")
            }
            public struct Description {
                public static let savingsPrefix = NSLocalizedString("Earn", comment: "Earn 3% APY")
                public static let savingsSuffix = NSLocalizedString("% APY", comment: "Earn 3% APY")
            }
            public static let pending = NSLocalizedString("Pending", comment: "Pending")
        }
                
        public static let current = NSLocalizedString("Current", comment: "Current")
        public static let price = NSLocalizedString("Price", comment: "Price")
        
        public static let send = NSLocalizedString("Send", comment: "Send")
        public static let request = NSLocalizedString("Request", comment: "Request")
        
        public static let day = NSLocalizedString("Day", comment: "Day")
        public static let week = NSLocalizedString("Week", comment: "Week")
        public static let month = NSLocalizedString("Month", comment: "Month")
        public static let year = NSLocalizedString("Year", comment: "Year")
        public static let all = NSLocalizedString("All", comment: "All")
        public static let sendToWallet = NSLocalizedString("Send to My Wallet", comment: "Send to My Wallet")
        public static let swap = NSLocalizedString("Swap", comment: "Swap")
        public static let viewActivity = NSLocalizedString("View Activity", comment: "View Activity")
    }

}
