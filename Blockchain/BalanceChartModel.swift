//
//  BalanceChartModel.swift
//  Blockchain
//
//  Created by kevinwu on 7/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class BalanceChartModel: NSObject {
    @objc var balance: String = "0"
    @objc var fiatBalance: Double = 0
}

@objc class BalanceChartViewModel: BalanceChartModel {
    @objc var watchOnly: BalanceChartModel

    override init() {
        self.watchOnly = BalanceChartModel()
    }
}
