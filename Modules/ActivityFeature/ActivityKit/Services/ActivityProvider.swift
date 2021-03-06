// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import ToolKit

public protocol ActivityProviding: AnyObject {
    /// Returns the activity service
    subscript(currency: CurrencyType) -> ActivityItemEventServiceAPI { get }
    subscript(fiatCurrency: FiatCurrency) -> FiatItemEventServiceAPI { get }
    subscript(cryptoCurrency: CryptoCurrency) -> CryptoItemEventServiceAPI { get }

    var activityItems: Observable<ActivityItemEventsLoadingState> { get }

    func refresh()
}

final class ActivityProvider: ActivityProviding {

    // MARK: - Properties

    subscript(currency: CurrencyType) -> ActivityItemEventServiceAPI {
        services[currency]!
    }

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoItemEventServiceAPI {
        services[.crypto(cryptoCurrency)] as! CryptoItemEventServiceAPI
    }

    subscript(fiatCurrency: FiatCurrency) -> FiatItemEventServiceAPI {
        services[.fiat(fiatCurrency)] as! FiatItemEventServiceAPI
    }

    // MARK: - Services

    private var services: [CurrencyType: ActivityItemEventServiceAPI] = [:]

    // MARK: - Setup

    init(fiats: [FiatCurrency: ActivityItemEventServiceAPI],
         cryptos: [CryptoCurrency: ActivityItemEventServiceAPI]) {
        for (currency, service) in fiats {
            services[currency.currency] = service
        }
        for (currency, service) in cryptos {
            services[currency.currency] = service
        }
    }

    var activityItems: Observable<ActivityItemEventsLoadingState> {
        activityItemsLoadingStates.map { $0.allActivity }
    }

    func refresh() {
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
