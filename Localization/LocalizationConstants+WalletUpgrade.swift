//
//  LocalizationConstants+WalletUpgrade.swift
//  Localization
//
//  Created by Paulo on 18/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    
    public enum WalletUpgrade {
        
        // MARK: Public Strings
        
        public static let doNotClose: String = NSLocalizedString(
            "Please do not close the app.",
            comment: ""
        )
        
        public static let upgrading: String = NSLocalizedString(
            "Upgrading wallet.",
            comment: ""
        )
        
        public static func upgradingVersion(version: String) -> String {
            String(format: upgradingVersionFormat, version)
        }
        
        public static func error(version: String) -> String {
            String(format: errorFormat, version)
        }
        
        // MARK: Formats
        
        private static let errorFormat = NSLocalizedString(
            "There was an error upgrading your Wallet to version %@. Please restart the app to retry.",
            comment: ""
        )
        
        private static let upgradingVersionFormat = NSLocalizedString(
            "Upgrading wallet to %@.",
            comment: ""
        )
    }
}
