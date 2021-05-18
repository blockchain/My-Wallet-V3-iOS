//
//  PolkadotCryptoAccount.swift
//  PolkadotKit
//
//  Created by Paulo on 25/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

final class PolkadotCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .polkadot
    let isDefault: Bool = false

    var pendingBalance: Single<MoneyValue> {
        unimplemented()
    }

    var balance: Single<MoneyValue> {
        unimplemented()
    }

    var actions: Single<AvailableActions> { .just([]) }

    private let exchangeService: PairExchangeServiceAPI

    init(id: String,
         label: String?,
         exchangeProviding: ExchangeProviding = resolve()) {
        self.id = id
        self.label = label ?? CryptoCurrency.polkadot.defaultWalletName
        self.exchangeService = exchangeProviding[.polkadot]
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }

    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        Single
            .zip(
                exchangeService.fiatPrice.take(1).asSingle(),
                balance
            ) { (exchangeRate: $0, balance: $1) }
            .map { try MoneyValuePair(base: $0.balance, exchangeRate: $0.exchangeRate.moneyValue) }
            .map(\.quote)
    }
}
