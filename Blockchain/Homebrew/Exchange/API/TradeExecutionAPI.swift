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
    func submitOrder(with conversion: Conversion, success: @escaping ((OrderTransaction, Conversion) -> Void), error: @escaping ((String) -> Void))
    func sendTransaction(assetType: AssetType, success: @escaping (() -> Void), error: @escaping ((String) -> Void))
}
