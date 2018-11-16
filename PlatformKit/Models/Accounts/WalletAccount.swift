//
//  WalletAccount.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol WalletAccount {
    /// TODO: Its possible that this should be renamed to `xPub`.
    /// However you can have addresses for an account that are technically
    /// `publicKeys` derived from the `xPub`.
    var publicKey: String { get }
    var label: String? { get }
    var archived: Bool { get }
}
