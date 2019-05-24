//
//  SideMenuItem.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model definition for an item that is presented in the side menu of the app.
enum SideMenuItem: String {
    case accountsAndAddresses = "accounts_and_addresses"
    case backup = "backup"
    case buyBitcoin = "buy_bitcoin"
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
        case .accountsAndAddresses: return #imageLiteral(resourceName: "icon_wallet")
        case .backup: return #imageLiteral(resourceName: "icon_backup")
        case .buyBitcoin: return #imageLiteral(resourceName: "Icon-Buy")
        case .logout: return #imageLiteral(resourceName: "Icon-Logout")
        case .settings: return #imageLiteral(resourceName: "icon_settings")
        case .support: return #imageLiteral(resourceName: "icon_help")
        case .upgrade: return #imageLiteral(resourceName: "icon_upgrade")
        case .webLogin: return #imageLiteral(resourceName: "Icon-Web")
        case .lockbox: return #imageLiteral(resourceName: "icon_lbx")
        }
    }
    
    var isNew: Bool {
        switch self {
        case .lockbox:
            return true
        case .accountsAndAddresses,
             .backup,
             .buyBitcoin,
             .logout,
             .settings,
             .support,
             .upgrade,
             .webLogin:
            return false
        }
    }
}
