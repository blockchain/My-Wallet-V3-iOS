//
//  WalletUpgradeError.swift
//  Blockchain
//
//  Created by Paulo on 17/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum WalletUpgradeError: Error {
    case errorUpgrading(version: String)
}
