//
//  StellarAssetAccount.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct StellarAssetAccount: AssetAccount {
    public var index: Int32 = 0
    public var address: String
    public var balance: Decimal
    public var name: String
    public var description: String
    
    public init(index: Int32 = 0,
                address: String,
                balance: Decimal,
                name: String,
                description: String) {
            self.index = index
            self.address = address
            self.balance = balance
            self.name = name
            self.description = description
    }
}
