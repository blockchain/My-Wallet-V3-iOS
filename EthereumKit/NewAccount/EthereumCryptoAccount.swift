//
//  EthereumCryptoAccount.swift
//  EthereumKit
//
//  Created by Paulo on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class EthereumCryptoAccount: CryptoNonCustodialAccount {
    let id: String
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true
    
    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceFetching
            .balanceMoney
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
        .just(EthereumReceiveAddress(address: id, label: label, onTxCompleted: onTxCompleted))
    }

    private let hdAccountIndex: Int
    private let balanceFetching: SingleAccountBalanceFetching
    private let bridge: EthereumWalletBridgeAPI
    private let exchangeService: PairExchangeServiceAPI

    init(id: String,
         label: String? = nil,
         hdAccountIndex: Int,
         bridge: EthereumWalletBridgeAPI = resolve(),
         balanceProviding: BalanceProviding = resolve(),
         exchangeProviding: ExchangeProviding = resolve()) {
        let asset = CryptoCurrency.ethereum
        self.asset = asset
        self.id = id
        self.hdAccountIndex = hdAccountIndex
        self.exchangeService = exchangeProviding[asset]
        self.balanceFetching = balanceProviding[asset.currency].wallet
        self.bridge = bridge
        self.label = label ?? asset.defaultWalletName
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
