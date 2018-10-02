//
//  TradeExecutionAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol TradeExecutionAPI {

    // Build a transaction to display on the confirm screen
    func prebuildOrder(
        with conversion: Conversion,
        from: AssetAccount,
        to: AssetAccount,
        success: @escaping ((OrderTransaction, Conversion) -> Void),
        error: @escaping ((String) -> Void)
    )

    // Build a transaction and send it
    func buildAndSend(
        with conversion: Conversion,
        from: AssetAccount,
        to: AssetAccount,
        success: @escaping (() -> Void),
        error: @escaping ((String) -> Void)
    )

    /// Check if the service is currently executing a request prior to
    /// submitting an additional request.
    var isExecuting: Bool { get set }
}
