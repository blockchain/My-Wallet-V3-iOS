//
//  TradeExecutionAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import ERC20Kit
import RxSwift
import PlatformKit
import BitcoinKit
import EthereumKit
import StellarKit

enum TradeExecutionAPIError: Error {
    case generic
    
    /// Some assets (in this case XLM) have minimum
    /// balance requirements. If the user tries to send
    /// an amount more than their minimum balance, we will
    /// return this error. 
    case exceededMaxVolume(CryptoValue)

    /// Wraps an `ERC20ServiceError`
    case erc20Error(ERC20ServiceError)
}

protocol TradeExecutionAPI {
    
    typealias ErrorMessage = String
    typealias TransactionID = String

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
        error: @escaping ((ErrorMessage, TransactionID?, NabuNetworkError?) -> Void)
    )
    
    /// In the event that a transaction fails, we need to track the cause of failure.
    /// We PUT this result to Nabu including a reason and the transactionID. This allows
    /// us to show the cause of failure in the order details as well as filter out
    /// failed trades from the user's exchange history.
    func trackTransactionFailure(_ reason: String, transactionID: String, completion: @escaping (Error?) -> Void)

    /// Check if the service is currently executing a request prior to
    /// submitting an additional request.
    var isExecuting: Bool { get set }

    /// Currently the wallet is unable to support sending another ether
    /// transaction until the last one is confirmed.
    func canTradeAssetType(_ assetType: AssetType) -> Bool
    
    /// This differs from `canTradeAssetType` in that it takes a `volume` parameter.
    /// Initially a volume parameter was added to `canTradeAssetType` but not we
    /// don't always have a proposed exchange volume. In the instance of XLM,
    /// some volumes are invalid if should the transaction be executed the user
    /// would have less than the minimum balance required for an XLM account.
    /// At the time of this writing, any other asset type will
    /// return `nil` for this function.
    /// For more information on minimum balances, please refer to this:
    /// https://www.stellar.org/developers/guides/concepts/fees.html#minimum-account-balance
    func validateVolume(_ volume: Decimal, for assetAccount: AssetAccount) -> Single<TradeExecutionAPIError?>
}
