//
//  RatesService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class RatesService: RatesAPI {
    
    enum RatesAPIError: Error {
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
    
    func getRates(withCompletion: @escaping ((Result<Rates>) -> Void)) {
        disposable = rates()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (payload) in
                withCompletion(.success(payload))
        }, onError: { error in
            withCompletion(.error(error))
        })
    }
    
    func getConfigurationForPair(_ tradingPair: TradingPair, withCompletion: @escaping ((Result<TradingPairConfiguration>) -> Void)) {
        disposable = configuration(forPair: tradingPair)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { payload in
                withCompletion(.success(payload))
            }, onError: { error in
                withCompletion(.error(error))
            })
    }
    
    fileprivate func configuration(forPair: TradingPair) -> Single<TradingPairConfiguration> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(RatesAPIError.generic)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["markets", "quotes", forPair.stringRepresentation, "config"],
            queryParameters: nil) else {
                return .error(RatesAPIError.generic)
        }
        
        return authentication.getKycSessionToken().flatMap { token in
            return NetworkRequest.GET(
                url: endpoint,
                body: nil,
                token: token.token,
                type: TradingPairConfiguration.self
            )
        }
    }
    
    fileprivate func rates() -> Single<Rates> {
        
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(RatesAPIError.generic)
        }
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["markets", "quotes", "pairs"],
            queryParameters: nil) else {
                return .error(RatesAPIError.generic)
        }
        
        return authentication.getKycSessionToken().flatMap { token in
            return NetworkRequest.GET(
                url: endpoint,
                body: nil,
                token: token.token,
                type: Rates.self
            )
        }
    }
}
