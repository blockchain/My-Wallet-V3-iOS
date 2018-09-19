//
//  TradeLimitsAPI.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol TradeLimitsAPI {
    func initialize(withFiatCurrency currency: String)
    func getTradeLimits(withFiatCurrency currency: String, withCompletion: @escaping ((Result<TradeLimits>) -> Void))
}
