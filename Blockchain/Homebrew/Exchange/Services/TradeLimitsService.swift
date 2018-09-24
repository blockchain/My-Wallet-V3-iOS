//
//  TradeLimitsService.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

class TradeLimitsService: TradeLimitsAPI {

    private let disposables = CompositeDisposable()

    private let authenticationService: NabuAuthenticationService
    private let socketManager: SocketManager
    private let cachedLimits = BehaviorRelay<TradeLimits?>(value: nil)

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
        disposables.dispose()
    }

    /// Initializes this TradeLimitsService so that the trade limits for the current
    /// user is pre-fetched and cached
    func initialize(withFiatCurrency currency: String) {
        let disposable = getTradeLimits(withFiatCurrency: currency)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                Logger.shared.debug("Successfully initialized TradeLimitsService.")
            }, onError: { error in
                Logger.shared.error("Failed to initialize TradeLimitsService: \(error)")
            })
        _ = disposables.insert(disposable)
    }

    func getTradeLimits(withFiatCurrency currency: String, withCompletion: @escaping ((Result<TradeLimits>) -> Void)) {
        let disposable = getTradeLimits(withFiatCurrency: currency)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (payload) in
                withCompletion(.success(payload))
            }, onError: { error in
                withCompletion(.error(error))
            })
        _ = disposables.insert(disposable)
    }

    func getTradeLimits(withFiatCurrency currency: String) -> Single<TradeLimits> {
        return Single.deferred { [unowned self] in
            guard let cachedLimits = self.cachedLimits.value, cachedLimits.currency == currency else {
                return self.getTradeLimitsNetwork(withFiatCurrency: currency)
            }
            return Single.just(cachedLimits)
        }.do(onSuccess: { [weak self] response in
            self?.cachedLimits.accept(response)
        })
    }

    // MARK: - Private

    private func getTradeLimitsNetwork(withFiatCurrency currency: String) -> Single<TradeLimits> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl
        ) else {
            return .error(TradeLimitsAPIError.generic)
        }

        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["trades", "limits"],
            queryParameters: ["currency": currency]
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
