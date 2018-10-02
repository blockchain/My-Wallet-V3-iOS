//
//  TradeExecutionAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum TradeExecutionError: Int, Error {
    case insufficientBalance = 43
}

protocol TradeExecutionAPI {

    // Build a transaction
    func submitOrder(with conversion: Conversion, success: @escaping ((OrderTransaction, Conversion) -> Void), error: @escaping ((String) -> Void))

    // Send the transaction that was last built
    func sendTransaction(assetType: AssetType, success: @escaping (() -> Void), error: @escaping ((String) -> Void))

    // Build a transaction and send it
    func submitAndSend(with conversion: Conversion, success: @escaping (() -> Void), error: @escaping ((String) -> Void))
    
    /// Check if the service is currently executing a request prior to
    /// submitting an additional request.
    var isExecuting: Bool { get set }
}
