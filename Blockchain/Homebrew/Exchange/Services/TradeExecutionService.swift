//
//  TradeExecutionService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class TradeExecutionService: TradeExecutionAPI {
    
    enum TradeExecutionAPIError: Error {
        case generic
    }
    
    private struct PathComponents {
        let components: [String]
        
        static let trades = PathComponents(
            components: ["trades"]
        )
        
        static let limits = PathComponents(
            components: ["trades", "limits"]
        )
    }
    
    private let authentication: NabuAuthenticationService
    private let wallet: Wallet
    private var disposable: Disposable?
    
    init(service: NabuAuthenticationService = NabuAuthenticationService.shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.authentication = service
        self.wallet = wallet
    }
    
    deinit {
        disposable?.dispose()
    }
    
    // MARK: TradeExecutionAPI
    
    func getTradeLimits(withCompletion: @escaping ((Result<TradeLimits>) -> Void)) {
        disposable = limits()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (payload) in
                withCompletion(.success(payload))
            }, onError: { error in
                withCompletion(.error(error))
            })
    }
    
    func submit(order: Order, withCompletion: @escaping (() -> Void)) {
        disposable = process(order: order)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] payload in
                guard let this = self else { return }
                this.sendTransaction(result: payload, completion: withCompletion)
        })
//            }, onError: { error in
//                withCompletion(.error(error))
//            })
    }
    
    // MARK: Private
    
    fileprivate func process(order: Order) -> Single<OrderResult> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: PathComponents.trades.components,
            queryParameters: nil) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        return authentication.getSessionToken().flatMap { token in
            return NetworkRequest.POST(
                url: endpoint,
                body: try? JSONEncoder().encode(order),
                token: token.token,
                type: OrderResult.self
            )
        }
    }
    
    fileprivate func limits() -> Single<TradeLimits> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: PathComponents.limits.components,
            queryParameters: nil) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        return authentication.getSessionToken().flatMap { token in
            return NetworkRequest.GET(
                url: endpoint,
                body: nil,
                token: token.token,
                type: TradeLimits.self
            )
        }
    }

    func sendTx() {
        let assetType = AssetType.bitcoin
        let legacyAssetType = assetType.legacy
        let orderTransaction = OrderTransaction(
            legacyAssetType: legacyAssetType,
            from: "from",
            to: "to",
            amount: "amount"
        )
        wallet.send(orderTransaction, success: {}, error: {})
    }

    private func sendTransaction(result: OrderResult, completion: @escaping (() -> Void)) {
        let assetType = AssetType.bitcoin
        let legacyAssetType = assetType.legacy
        guard let to = result.depositAddress,
            let amount = result.depositQuantity else {
                Logger.shared.error("Missing to address or amount")
                return
        }
        let orderTransaction = OrderTransaction(
            legacyAssetType: legacyAssetType,
            from: "from",
            to: to,
            amount: amount
        )
        wallet.send(orderTransaction, success: completion, error: {})
    }
}
