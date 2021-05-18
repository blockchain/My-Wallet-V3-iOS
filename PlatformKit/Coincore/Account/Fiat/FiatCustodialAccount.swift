//
//  FiatCustodialAccount.swift
//  PlatformKit
//
//  Created by Paulo on 19/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import RxSwift
import ToolKit

public class FiatCustodialAccount: FiatAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    public let id: String
    public let actions: Single<AvailableActions> = .just([.deposit, .viewActivity])
    public let isDefault: Bool = true
    public let label: String
    public let fiatCurrency: FiatCurrency
    public let accountType: SingleAccountType = .custodial(.trading)
    
    public var pendingBalance: Single<MoneyValue> {
        balanceProviding[currencyType]
            .trading
            .pendingBalanceMoney
    }
    
    public var isFunded: Single<Bool> {
        balanceProviding[currencyType]
            .trading
            .balanceMoney
            .map { $0.isPositive }
    }

    public var balance: Single<MoneyValue> {
        balanceProviding[currencyType]
            .trading
            .balanceMoney
    }

    private let balanceProviding: BalanceProviding
    private let exchange: PairExchangeServiceAPI

    init(fiatCurrency: FiatCurrency,
         exchangeProviding: ExchangeProviding = resolve(),
         balanceProviding: BalanceProviding = resolve()) {
        self.balanceProviding = balanceProviding
        self.exchange = exchangeProviding[fiatCurrency]
        self.fiatCurrency = fiatCurrency
        label = fiatCurrency.defaultWalletName
        id = "FiatCustodialAccount." + fiatCurrency.code
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }

    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        guard self.fiatCurrency != fiatCurrency else {
            return balance
        }
        return Single
            .zip(
                balance,
                exchange.fiatPrice.take(1).asSingle().moneyValue
            ) { (balance: $0, exchange: $1) }
            .map { data  in
                MoneyValueBalancePairs(trading: try MoneyValuePair(base: data.balance, exchangeRate: data.exchange))
            }
            .map(\.quote)
    }
}
