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
    case upgradeBackup = "upgrade_backup"
    case settings = "settings"
    case accountsAndAddresses = "accounts_and_addresses"
    case webLogin = "web_login"
    case support = "support"
    case logout = "logout"
    case buyBitcoin = "buy_bitcoin"
    case exchange = "exchange"
}
