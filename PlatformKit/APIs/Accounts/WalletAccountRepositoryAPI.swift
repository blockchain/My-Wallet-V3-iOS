//
//  WalletAccountRepositoryAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Each currency has a `WalletAccountRepositoryAPI`. According to
/// the metadata endpoint, there's a `default_account_idx`. This is
/// the purpose behind `defaultAccount`. Each currency has an array of
/// `WalletAccounts`.
public protocol WalletAccountRepositoryAPI {
    func accounts() -> [WalletAccount]
    var defaultAccount: WalletAccount? { get }
}
