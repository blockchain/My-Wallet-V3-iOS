//
//  ERC20AssetAccountDetails.swift
//  ERC20KitTests
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct ERC20AssetAccountDetails: AssetAccountDetails {
    public typealias Account = ERC20AssetAccount
    
    public var account: Account
    public var balance: CryptoValue
}

