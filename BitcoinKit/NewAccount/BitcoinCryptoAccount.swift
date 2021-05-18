//
//  BitcoinCryptoAccount.swift
//  BitcoinKit
//
//  Created by Paulo on 12/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

class BitcoinCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .bitcoin
    let isDefault: Bool
    
    var pendingBalance: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .bitcoin))
    }
    
    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: id)
            .moneyValue
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
        bridge.receiveAddress(forXPub: id)
            .flatMap(weak: self) { (self, address) -> Single<(Int32, String)> in
                Single.zip(self.bridge.walletIndex(for: address), Single.just(address))
            }
            .map(weak: self) { (self, values) -> ReceiveAddress in
                let (index, address) = values
                return BitcoinChainReceiveAddress<BitcoinToken>(
                    address: address,
                    label: self.label,
                    onTxCompleted: self.onTxCompleted,
                    index: index
                )
            }
    }

    private let exchangeService: PairExchangeServiceAPI
    private let balanceService: BalanceServiceAPI
    private let bridge: BitcoinWalletBridgeAPI
    private let hdAccountIndex: Int

    init(id: String,
         label: String?,
         isDefault: Bool,
         hdAccountIndex: Int,
         exchangeProviding: ExchangeProviding = resolve(),
         balanceService: BalanceServiceAPI = resolve(tag: BitcoinChainKit.BitcoinChainCoin.bitcoin),
         bridge: BitcoinWalletBridgeAPI = resolve()) {
        self.id = id
        self.hdAccountIndex = hdAccountIndex
        self.label = label ?? CryptoCurrency.bitcoin.defaultWalletName
        self.isDefault = isDefault
        self.exchangeService = exchangeProviding[.bitcoin]
        self.balanceService = balanceService
        self.bridge = bridge
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
