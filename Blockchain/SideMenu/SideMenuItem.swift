//
//  SideMenuItem.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import ToolKit

/// Model definition for an item that is presented in the side menu of the app.
enum SideMenuItem {
    case accountsAndAddresses
    case backup
    case buy
    case sell
    case logout
    case airdrops
    case settings
    case support
    /// Legacy QR code connection flow
    case webLogin
    /// Secure Channel QR code connection flow
    case secureChannel
    case lockbox
    case exchange
}

extension SideMenuItem {
    
    var analyticsEvent: AnalyticsEvents.SideMenu {
        switch self {
        case .accountsAndAddresses:
            return .sideNavAccountsAndAddresses
        case .backup:
            return .sideNavBackup
        case .buy:
            return .sideNavSimpleBuy
        case .sell:
            // TODO: Analytics Event
            return .sideNavSimpleBuy
        case .logout:
            return .sideNavLogout
        case .settings:
            return .sideNavSettings
        case .airdrops:
            return .sideNavAirdropCenter
        case .support:
            return .sideNavSupport
        case .webLogin:
            return .sideNavWebLogin
        case .lockbox:
            return .sideNavLockbox
        case .exchange:
            return .sideNavExchange
        case .secureChannel:
            return .sideNavSecureChannel
        }
    }
    
    var title: String {
        switch self {
        case .accountsAndAddresses:
            return LocalizationConstants.SideMenu.addresses
        case .backup:
            return LocalizationConstants.SideMenu.backupFunds
        case .buy:
            return LocalizationConstants.SideMenu.buyCrypto
        case .sell:
            return LocalizationConstants.SideMenu.sellCrypto
        case .logout:
            return LocalizationConstants.SideMenu.logout
        case .settings:
            return LocalizationConstants.SideMenu.settings
        case .airdrops:
            return LocalizationConstants.SideMenu.airdrops
        case .support:
            return LocalizationConstants.SideMenu.support
        case .webLogin:
            return LocalizationConstants.SideMenu.loginToWebWallet
        case .lockbox:
            return LocalizationConstants.SideMenu.lockbox
        case .exchange:
            return LocalizationConstants.SideMenu.exchange
        case .secureChannel:
            return LocalizationConstants.SideMenu.secureChannel
        }
    }

    private var imageName: String {
        switch self {
        case .accountsAndAddresses:
            return "menu-icon-addresses"
        case .backup:
            return "menu-icon-backup"
        case .buy:
            return "menu-icon-buy"
        case .sell:
            return "menu-icon-sell"
        case .logout:
            return "menu-icon-logout"
        case .airdrops:
            return "menu-icon-airdrop"
        case .settings:
            return "menu-icon-settings"
        case .support:
            return "menu-icon-help"
        case .webLogin:
            return "menu-icon-pair-web-wallet"
        case .lockbox:
            return "menu-icon-lockbox"
        case .exchange:
            return "menu-icon-exchange"
        case .secureChannel:
            return "menu-icon-laptop"
        }
    }

    var image: UIImage {
        UIImage(named: imageName)!
    }
    
    var isNew: Bool {
        switch self {
        case .accountsAndAddresses,
             .backup,
             .buy,
             .sell,
             .logout,
             .settings,
             .support,
             .airdrops,
             .lockbox,
             .webLogin,
             .secureChannel:
            return false
        case .exchange:
            return true
        }
    }
}
