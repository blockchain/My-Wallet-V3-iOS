//
//  BalanceDisplayModel.swift
//  Blockchain
//
//  Created by kevinwu on 7/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class BalanceModel: NSObject {
    @objc var balance: String?
    @objc var fiatBalance: Double = 0
}

@objc class BalanceDisplayModel: BalanceModel {

    @objc var watchOnly: WatchOnlyDisplayModel

    override init() {
        self.watchOnly = WatchOnlyDisplayModel()
    }
}

@objc class WatchOnlyDisplayModel: BalanceModel {
}
