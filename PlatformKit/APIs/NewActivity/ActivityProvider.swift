//
//  ActivityProvider.swift
//  PlatformKit
//
//  Created by Alex McGregor on 5/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol ActivityProviding: class {
    /// Returns the activity service
    subscript(currency: CurrencyType) -> ActivityItemEventServiceAPI { get }
    subscript(fiatCurrency: FiatCurrency) -> FiatItemEventServiceAPI { get }
    subscript(cryptoCurrency: CryptoCurrency) -> CryptoItemEventServiceAPI { get }
    
    var activityItems: Observable<ActivityItemEventsLoadingState> { get }
    
    func refresh()
}

public final class ActivityProvider: ActivityProviding {
    
    // MARK: - Public Properties
    
    public subscript(currency: CurrencyType) -> ActivityItemEventServiceAPI {
        services[currency]!
    }
    
    public subscript(cryptoCurrency: CryptoCurrency) -> CryptoItemEventServiceAPI {
        services[.crypto(cryptoCurrency)] as! CryptoItemEventServiceAPI
    }
    
    public subscript(fiatCurrency: FiatCurrency) -> FiatItemEventServiceAPI {
        services[.fiat(fiatCurrency)] as! FiatItemEventServiceAPI
    }
    
    // MARK: - Services
    
    private var services: [CurrencyType: ActivityItemEventServiceAPI] = [:]
    
    // MARK: - Setup
    
    public init(fiats: [FiatCurrency: ActivityItemEventServiceAPI],
                cryptos: [CryptoCurrency: ActivityItemEventServiceAPI]) {
        for (currency, service) in fiats {
            services[currency.currency] = service
        }
        for (currency, service) in cryptos {
            services[currency.currency] = service
        }
    }
    
    public var activityItems: Observable<ActivityItemEventsLoadingState> {
        activityItemsLoadingStates.map { $0.allActivity }
    }
    
    public func refresh() {
        services.values.forEach { $0.refresh() }
    }

    private var activityItemsLoadingStates: Observable<ActivityItemEventsLoadingStates> {
        // Array of `activityLoadingStateObservable` observables from currencies we want to fetch.
        let observables = services
            .reduce(into: [Observable<[CurrencyType : ActivityItemEventsLoadingState]>]()) { (result, element) in
                let observable = element.value.activityLoadingStateObservable
                    // Map the `activityLoadingState` so it remains attached to its currency.
                    .map { activityLoadingState -> [CurrencyType : ActivityItemEventsLoadingState] in
                        [element.key: activityLoadingState]
                    }
                result.append(observable)
            }

        return Observable
            .combineLatest(observables)
            .map { data -> [CurrencyType : ActivityItemEventsLoadingState] in
                // Reduce our `[Dictionary]` into a single `Dictionary`.
                data.reduce(into: [CurrencyType : ActivityItemEventsLoadingState]()) { (result, this) in
                    result.merge(this)
                }
            }
            .map { statePerCurrency -> ActivityItemEventsLoadingStates in
                ActivityItemEventsLoadingStates(
                    statePerCurrency: statePerCurrency
                )
            }
            .share()
    }
}
