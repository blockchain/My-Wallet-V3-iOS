//
//  StellarCryptoAccount.swift
//  StellarKit
//
//  Created by Paulo on 10/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

class StellarCryptoAccount: CryptoNonCustodialAccount {
    let id: String
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    var balance: Single<MoneyValue> {
        horizonProxy
            .accountResponse(for: id)
            .map(\.totalBalance)
            .moneyValue
            .catchNonExistentAccount()
    }

    var actionableBalance: Single<MoneyValue> {
        horizonProxy
            .accountResponse(for: id)
            .map(weak: self) { (self, account) -> MoneyValue in
                let zero = CryptoValue.zero(currency: .stellar)
                let value = try account.totalBalance - self.horizonProxy.minimumBalance(subentryCount: Int(account.subentryCount))
                return try value < zero ? zero.moneyValue : value.moneyValue
            }
            .catchNonExistentAccount()
    }
    
    var pendingBalance: Single<MoneyValue> {
        balanceFetching
            .pendingBalanceMoney
    }

    var actions: Single<AvailableActions> {
        isFunded
            .map { isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send]
                if isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(StellarReceiveAddress(address: id, label: label))
    }

    private let hdAccountIndex: Int
    private let bridge: StellarWalletBridgeAPI
    private let balanceFetching: SingleAccountBalanceFetching
    private let horizonProxy: HorizonProxyAPI
    private let exchangeService: PairExchangeServiceAPI

    init(id: String,
         label: String? = nil,
         hdAccountIndex: Int,
         horizonProxy: HorizonProxyAPI = resolve(),
         bridge: StellarWalletBridgeAPI = resolve(),
         balanceProviding: BalanceProviding = resolve(),
         exchangeProviding: ExchangeProviding = resolve()) {
        let asset = CryptoCurrency.stellar
        self.asset = asset
        self.bridge = bridge
        self.id = id
        self.hdAccountIndex = hdAccountIndex
        self.label = label ?? asset.defaultWalletName
        self.horizonProxy = horizonProxy
        self.balanceFetching = balanceProviding[asset.currency].wallet
        self.exchangeService = exchangeProviding[asset]
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .send,
             .viewActivity:
            return .just(true)
        case .deposit,
             .sell,
             .withdraw:
            return .just(false)
        case .swap:
            return isFunded
        }
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

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == MoneyValue {
    fileprivate func catchNonExistentAccount() -> Single<MoneyValue> {
        catchError { error -> Single<MoneyValue> in
            switch error {
            case is StellarAccountError:
                return .just(CryptoValue.zero(currency: .stellar).moneyValue)
            default:
                throw error
            }
        }
    }
}
