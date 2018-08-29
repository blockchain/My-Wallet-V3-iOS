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
    
    private let authentication: KYCAuthenticationService
    private var disposable: Disposable?
    
    init(service: KYCAuthenticationService = KYCAuthenticationService.shared) {
        self.authentication = service
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
    
    func submit(order: Order, withCompletion: @escaping ((Result<Trade>) -> Void)) {
        disposable = process(order: order)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (payload) in
                withCompletion(.success(payload))
            }, onError: { error in
                withCompletion(.error(error))
            })
    }
    
    // MARK: Private
    
    fileprivate func process(order: Order) -> Single<Trade> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["trades"],
            queryParameters: nil) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        return authentication.getKycSessionToken().flatMap { token in
            return NetworkRequest.POST(
                url: endpoint,
                body: try? JSONEncoder().encode(order),
                token: token.token,
                type: Trade.self
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
            pathComponents: ["trades", "limits"],
            queryParameters: nil) else {
                return .error(TradeExecutionAPIError.generic)
        }
        
        return authentication.getKycSessionToken().flatMap { token in
            return NetworkRequest.GET(
                url: endpoint,
                body: nil,
                token: token.token,
                type: TradeLimits.self
            )
        }
    }
}
