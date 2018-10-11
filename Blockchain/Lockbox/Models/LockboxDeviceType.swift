//
//  LockboxDeviceType.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates the different supported types of hardware wallets on Blockchain.
enum LockboxDeviceType: String, Codable {
    case blockchain
    case ledger
}
