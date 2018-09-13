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
    
    private struct PathComponents {
        let components: [String]
        
        static let rates = PathComponents(
            components: ["markets", "quotes", "pairs"]
        )
        
        static func withPair(_ pair: TradingPair) -> PathComponents {
            let components = PathComponents(
                components: [
                    "markets",
                    "quotes",
                    pair.stringRepresentation,
                    "config"
                ]
            )
            return components
        }

        static let trades = PathComponents(
            components: ["trades"]
        )
    }
    
    enum RatesAPIError: Error {
        case generic
    }
    
    private let authentication: NabuAuthenticationService
    private var disposable: Disposable?
    
    init(service: NabuAuthenticationService = NabuAuthenticationService.shared) {
        self.authentication = service
    }
    
    deinit {
        disposable?.dispose()
        disposable = nil
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
        
        let components = PathComponents.withPair(forPair)
        
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: components.components,
            queryParameters: nil) else {
                return .error(RatesAPIError.generic)
        }
        
        return authentication.getSessionToken().flatMap { token in
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
            pathComponents: PathComponents.rates.components,
            queryParameters: nil) else {
                return .error(RatesAPIError.generic)
        }
        
        return authentication.getSessionToken().flatMap { token in
            return NetworkRequest.GET(
                url: endpoint,
                body: nil,
                token: token.token,
                type: Rates.self
            )
        }
    }
}


// MARK: - Trade Execution
struct TradeExecutionResult: Codable {
    let result: String
    private enum CodingKeys: CodingKey {
        case result
    }
}

extension RatesService {
    func executeTrade(conversion: Conversion, withCompletion: @escaping ((Result<TradeExecutionResult>) -> Void)) {
        do {
            let conversionString = try conversion.encodeToString(encoding: .utf8)
            guard let data = conversionString.data(using: .utf8) else {
                Logger.shared.error("Couldn't convert string to data")
                return
            }
            disposable = executeTrade(conversionData: data)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { payload in
                    withCompletion(.success(payload))
                }, onError: { error in
                    withCompletion(.error(error))
                })
        } catch {
            Logger.shared.error("Couldn't encode conversion to string: \(error)")
        }
    }

    fileprivate func executeTrade(conversionData: Data) -> Single<TradeExecutionResult> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl) else {
                return .error(RatesAPIError.generic)
        }

        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: PathComponents.trades.components,
            queryParameters: nil) else {
                return .error(RatesAPIError.generic)
        }

        return authentication.getSessionToken().flatMap { token in
            return NetworkRequest.POST(
                url: endpoint,
                body: conversionData,
                token: token.token,
                type: TradeExecutionResult.self
            )
        }
    }
}
