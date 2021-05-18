//
//  BalanceChangeProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol BalanceChangeProviding: class {    
    var change: Observable<MoneyBalancePairsCalculationStates> { get }

    subscript(currency: CryptoCurrency) -> AssetBalanceChangeProviding { get }
    subscript(currency: CurrencyType) -> AssetBalanceChangeProviding { get }
}

/// A service that providers a balance change in crypto fiat and percentages
public final class BalanceChangeProvider: BalanceChangeProviding {
    
    // MARK: - Services

    private let currencies: [CurrencyType]
    private let services: [CurrencyType: AssetBalanceChangeProviding]
    
    public var change: Observable<MoneyBalancePairsCalculationStates> {
        let currencies = self.currencies.map { $0.currency }
        return Observable
            .combineLatest(currencies.compactMap { self[$0].calculationState })
            .map { Dictionary(uniqueKeysWithValues: zip(currencies, $0)) }
            .map { states -> MoneyBalancePairsCalculationStates in
                MoneyBalancePairsCalculationStates(
                    identifier: "total-balance-change",
                    statePerCurrency: states
                )
            }
    }
    
    // MARK: - Setup
    
    public init(
        currencies: [CryptoCurrency],
        aave: AssetBalanceChangeProviding,
        algorand: AssetBalanceChangeProviding,
        bitcoin: AssetBalanceChangeProviding,
        bitcoinCash: AssetBalanceChangeProviding,
        ether: AssetBalanceChangeProviding,
        pax: AssetBalanceChangeProviding,
        polkadot: AssetBalanceChangeProviding,
        stellar: AssetBalanceChangeProviding,
        tether: AssetBalanceChangeProviding,
        wDGLD: AssetBalanceChangeProviding,
        yearnFinance: AssetBalanceChangeProviding
    ) {
        self.currencies = currencies.map { $0.currency }
        services = [
            .crypto(.aave): aave,
            .crypto(.algorand): algorand,
            .crypto(.bitcoin): bitcoin,
            .crypto(.bitcoinCash): bitcoinCash,
            .crypto(.ethereum): ether,
            .crypto(.pax): pax,
            .crypto(.polkadot): polkadot,
            .crypto(.stellar): stellar,
            .crypto(.tether): tether,
            .crypto(.wDGLD): wDGLD,
            .crypto(.yearnFinance): yearnFinance
        ]
    }

    public subscript(currency: CryptoCurrency) -> AssetBalanceChangeProviding {
        services[currency.currency]!
    }
    
    public subscript(currency: CurrencyType) -> AssetBalanceChangeProviding {
        services[currency]!
    }
}
