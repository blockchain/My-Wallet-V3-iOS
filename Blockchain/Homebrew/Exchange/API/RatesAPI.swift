//
//  RatesAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol RatesAPI {
    func getRates(withCompletion: @escaping ((Result<Rates>) -> Void))
    func getConfigurationForPair(_ tradingPair: TradingPair, withCompletion: @escaping ((Result<TradingPairConfiguration>) -> Void))
}
