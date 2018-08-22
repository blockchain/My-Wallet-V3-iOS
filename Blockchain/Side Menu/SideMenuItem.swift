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
    case kyc = "kyc"
    case logout = "logout"
    case settings = "settings"
    case support = "support"
    case upgrade = "upgrade"
    case webLogin = "web_login"
}

extension SideMenuItem {
    var title: String {
        switch self {
        case .accountsAndAddresses: return LocalizationConstants.SideMenu.addresses
        case .backup: return LocalizationConstants.SideMenu.backupFunds
        case .buyBitcoin: return LocalizationConstants.SideMenu.buySellBitcoin
        case .exchange: return LocalizationConstants.SideMenu.exchange
        case .kyc: return "Debug KYC"
        case .logout: return LocalizationConstants.SideMenu.logout
        case .settings: return LocalizationConstants.SideMenu.settings
        case .support: return LocalizationConstants.SideMenu.support
        case .upgrade: return LocalizationConstants.LegacyUpgrade.upgrade
        case .webLogin: return LocalizationConstants.SideMenu.loginToWebWallet
        }
    }

    var image: UIImage {
        switch self {
        case .accountsAndAddresses: return #imageLiteral(resourceName: "wallet")
        case .backup: return #imageLiteral(resourceName: "lock")
        case .buyBitcoin: return #imageLiteral(resourceName: "buy")
        case .exchange: return #imageLiteral(resourceName: "exchange_menu")
        case .kyc: return #imageLiteral(resourceName: "web")
        case .logout: return #imageLiteral(resourceName: "logout")
        case .settings: return #imageLiteral(resourceName: "settings")
        case .support: return #imageLiteral(resourceName: "help")
        case .upgrade: return #imageLiteral(resourceName: "icon_upgrade")
        case .webLogin: return #imageLiteral(resourceName: "web")
        }
    }
}
