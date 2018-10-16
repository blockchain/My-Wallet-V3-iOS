//
//  SideMenuItem.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model definition for an item that is presented in the side menu of the app.
enum SideMenuItem: String, RawValued {
    case accountsAndAddresses = "accounts_and_addresses"
    case backup = "backup"
    case buyBitcoin = "buy_bitcoin"
    case exchange = "exchange"
    case logout = "logout"
    case settings = "settings"
    case support = "support"
    case upgrade = "upgrade"
    case webLogin = "web_login"
    case lockbox = "lockbox"
}

extension SideMenuItem {
    var title: String {
        switch self {
        case .accountsAndAddresses: return LocalizationConstants.SideMenu.addresses
        case .backup: return LocalizationConstants.SideMenu.backupFunds
        case .buyBitcoin: return LocalizationConstants.SideMenu.buySellBitcoin
        case .exchange: return LocalizationConstants.SideMenu.exchange
        case .logout: return LocalizationConstants.SideMenu.logout
        case .settings: return LocalizationConstants.SideMenu.settings
        case .support: return LocalizationConstants.SideMenu.support
        case .upgrade: return LocalizationConstants.LegacyUpgrade.upgrade
        case .webLogin: return LocalizationConstants.SideMenu.loginToWebWallet
        case .lockbox: return LocalizationConstants.SideMenu.lockbox
        }
    }

    var image: UIImage {
        switch self {
        case .accountsAndAddresses: return #imageLiteral(resourceName: "Icon-Address")
        case .backup: return #imageLiteral(resourceName: "Icon-Backup")
        case .buyBitcoin: return #imageLiteral(resourceName: "Icon-Buy")
        case .exchange: return #imageLiteral(resourceName: "Icon-Exchange-1")
        case .logout: return #imageLiteral(resourceName: "Icon-Logout")
        case .settings: return #imageLiteral(resourceName: "Icon-Settings")
        case .support: return #imageLiteral(resourceName: "Icon-Question")
        case .upgrade: return #imageLiteral(resourceName: "icon_upgrade")
        case .webLogin: return #imageLiteral(resourceName: "Icon-Web")
        case .lockbox: return #imageLiteral(resourceName: "Icon-Lockbox")
        }
    }
    
    var isNew: Bool {
        switch self {
        case .lockbox:
            return true
        case .accountsAndAddresses,
             .backup,
             .buyBitcoin,
             .exchange,
             .logout,
             .settings,
             .support,
             .upgrade,
             .webLogin:
            return false
        }
    }
}
