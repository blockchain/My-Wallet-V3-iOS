//
//  TradeLimitsService.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

class TradeLimitsService: TradeLimitsAPI {

    private var disposable: Disposable?

    private let authenticationService: NabuAuthenticationService
    private let socketManager: SocketManager

    init(
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        socketManager: SocketManager = SocketManager.shared
    ) {
        self.authenticationService = authenticationService
        self.socketManager = socketManager
    }

    enum TradeLimitsAPIError: Error {
        case generic
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func getTradeLimits(withCompletion: @escaping ((Result<TradeLimits>) -> Void)) {
        disposable = getTradeLimits()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (payload) in
                withCompletion(.success(payload))
            }, onError: { error in
                withCompletion(.error(error))
            })
    }

    func subscribeToAllExchangeRates() {

        // Send subscribe message
        let params = AllCurrencyPairsSubscribeParams()
        let subscriptionMessage = Subscription(channel: "exchange_rate", params: params)
        let socketMessage = SocketMessage(type: .exchange, JSONMessage: subscriptionMessage)
        socketManager.send(message: socketMessage)
    }

    func getTradeLimits() -> Single<TradeLimits> {
        // TODO: can be cached
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl
        ) else {
            return .error(TradeLimitsAPIError.generic)
        }

        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["trades", "limits"],
            queryParameters: nil
        ) else {
            return .error(TradeLimitsAPIError.generic)
        }

        return authenticationService.getSessionToken().flatMap { token in
            return NetworkRequest.GET(
                url: endpoint,
                body: nil,
                token: token.token,
                type: TradeLimits.self
            )
        }
    }
}
