//
//  BalanceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

/// Provider of balance services and total balance in `FiatValue`
public protocol BalanceProviding: class {
    
    subscript(currency: CurrencyType) -> AssetBalanceFetching { get }
    
    /// Streams the total fiat balance in the wallet
    var fiatBalance: Observable<FiatValueCalculationState> { get }
    
    /// Streams the fiat balances
    var fiatBalances: Observable<MoneyBalancePairsCalculationStates> { get }
    
    /// Streams the balances of the fiat based currencies
    var fiatFundsBalances: Observable<MoneyBalancePairsCalculationStates> { get }

    /// Single wrapper for `fiatFundsBalances` the balances of the fiat based currencies
    var fiatFundsBalancesSingle: Single<MoneyBalancePairsCalculationStates> { get }
    
    /// Triggers a refresh on the balances
    func refresh()
}

/// A cross-asset balance provider
public final class BalanceProvider: BalanceProviding {

    // MARK: - Balance
    
    /// Reduce cross asset fiat balance values into a single fiat value
    public var fiatBalance: Observable<FiatValueCalculationState> {
        fiatBalances
            .map { $0.totalFiat }
            .share()
    }

    /// Calculates all balances in `WalletBalance`
    public var fiatBalances: Observable<MoneyBalancePairsCalculationStates> {
        // Array of `calculationState` observables from all currencies we want to fetch.
        let observables = services
            .reduce(into: [Observable<[CurrencyType : MoneyBalancePairsCalculationState]>]()) { (result, element) in
                let observable = element.value.calculationState
                    // Map the `MoneyBalancePairsCalculationState` so it remains attached to its currency.
                    .map { calculationState -> [CurrencyType : MoneyBalancePairsCalculationState] in
                        [element.key: calculationState]
                    }
                result.append(observable)
            }
        return Observable
            .combineLatest(observables)
            .map { data -> [CurrencyType : MoneyBalancePairsCalculationState] in
                // Reduce our `[Dictionary]` into a single `Dictionary`.
                data.reduce(into: [CurrencyType : MoneyBalancePairsCalculationState]()) { (result, this) in
                    result.merge(this)
                }
            }
            .map { statePerCurrency in
                MoneyBalancePairsCalculationStates(
                    identifier: "total-balance",
                    statePerCurrency: statePerCurrency
                )
            }
            .share()
    }
    
    public var fiatFundsBalances: Observable<MoneyBalancePairsCalculationStates> {
        fiatBalances.map { $0.fiatBaseStates }
    }

    public var fiatFundsBalancesSingle: Single<MoneyBalancePairsCalculationStates> {
        fiatFundsBalances.take(1).asSingle()
    }

    public subscript(currency: Currency) -> AssetBalanceFetching {
        services[currency.currency]!
    }
    
    public subscript(currencyType: CurrencyType) -> AssetBalanceFetching {
        services[currencyType]!
    }
    
    // MARK: - Services
    
    private var services: [CurrencyType: AssetBalanceFetching] = [:]
    
    // MARK: - Setup
    
    public init(fiats: [FiatCurrency: AssetBalanceFetching],
                cryptos: [CryptoCurrency: AssetBalanceFetching]) {
        for (currency, service) in fiats {
            services[currency.currency] = service
        }
        for (currency, service) in cryptos {
            services[currency.currency] = service
        }
    }
    
    public func refresh() {
        services.values.forEach { $0.refresh() }
    }
}
