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
        success: @escaping ((OrderTransaction) -> Void),
        error: @escaping ((String) -> Void)
    )

    /// Check if the service is currently executing a request prior to
    /// submitting an additional request.
    var isExecuting: Bool { get set }

    /// Check if the user must wait for an ether transaction to confirm.
    /// Currently the wallet is unable to support sending another ether
    /// transaction until the last one is confirmed.
    var canSendEther: Bool { get }
}
