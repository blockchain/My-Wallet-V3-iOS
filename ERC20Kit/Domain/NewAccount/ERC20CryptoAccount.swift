//
//  ERC20CryptoAccount.swift
//  ERC20Kit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount<Token: ERC20Token>: CryptoNonCustodialAccount {
    let id: String
    let label: String
    let asset: CryptoCurrency = Token.assetType
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
                var base: AvailableActions = [.viewActivity, .receive]
                if Token.legacySendSupport {
                    base.insert(.send)
                }
                if Token.nonCustodialTransactionSupport.contains(.swap), isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(ERC20ReceiveAddress<Token>(asset: asset, address: id, label: label, onTxCompleted: onTxCompleted))
    }

    private let balanceFetching: SingleAccountBalanceFetching
    private let exchangeService: PairExchangeServiceAPI
    private let featureFetcher: FeatureConfiguring
    
    init(id: String,
         balanceProviding: BalanceProviding = resolve(),
         exchangeProviding: ExchangeProviding = resolve(),
         featureFetcher: FeatureConfiguring = resolve()) {
        self.id = id
        self.label = Token.assetType.defaultWalletName
        self.exchangeService = exchangeProviding[Token.assetType]
        self.balanceFetching = balanceProviding[Token.assetType.currency].wallet
        self.featureFetcher = featureFetcher
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .viewActivity:
            return .just(true)
        case .send:
            return .just(Token.legacySendSupport)
        case .deposit,
             .sell,
             .withdraw:
            return .just(false)
        case .swap:
            guard Token.nonCustodialTransactionSupport.contains(.swap) else {
                return .just(false)
            }
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
}
