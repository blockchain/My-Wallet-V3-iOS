//
//  CryptoInterestAccount.swift
//  PlatformKit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import RxSwift
import ToolKit

public class CryptoInterestAccount: CryptoAccount {

    private typealias LocalizedString = LocalizationConstants.Account

    public lazy var id: String = "CryptoInterestAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public let accountType: SingleAccountType = .custodial(.savings)

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }
    
    public var pendingBalance: Single<MoneyValue> {
        balanceFetching
            .pendingBalanceMoney
    }
    
    public var balance: Single<MoneyValue> {
        balanceFetching
            .balanceMoney
    }
    
    public var isFunded: Single<Bool> {
        balanceFetching
            .isFunded
            .take(1)
            .asSingle()
    }

    public var actions: Single<AvailableActions> {
        .just([])
    }

    private let balanceFetching: CustodialAccountBalanceFetching
    private let exchangeService: PairExchangeServiceAPI

    public init(asset: CryptoCurrency,
                balanceProviding: BalanceProviding = resolve(),
                exchangeProviding: ExchangeProviding = resolve()) {
        self.label = asset.defaultInterestWalletName
        self.asset = asset
        self.exchangeService = exchangeProviding[asset]
        self.balanceFetching = balanceProviding[asset.currency].savings
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        .just(false)
    }

    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        Single
            .zip(
                exchangeService.fiatPrice.take(1).asSingle(),
                balance
            ) { (exchangeRate: $0, balance: $1) }
            .map { try MoneyValuePair(base: $0.balance, exchangeRate: $0.exchangeRate.moneyValue) }
            .map(\.quote)
    }
}
