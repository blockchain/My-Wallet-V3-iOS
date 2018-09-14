//
//  TradeExecutionAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol TradeExecutionAPI {
    func getTradeLimits(withCompletion: @escaping ((Result<TradeLimits>) -> Void))
    func submit(order: Order, withCompletion: @escaping (() -> Void))
    func sendTx()
}
