//
//  CryptoTradingAccount.swift
//  PlatformKit
//
//  Created by Paulo on 14/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

/// Named `CustodialTradingAccount` on Android
public class CryptoTradingAccount: CryptoAccount, TradingAccount {

    public lazy var id: String = "CryptoTradingAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public let accountType: SingleAccountType = .custodial(.trading)

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var receiveAddress: Single<ReceiveAddress> {
        custodialAddressService
            .receiveAddress(for: asset)
            .map(weak: self) { (self, address) in
                TradingCryptoReceiveAddress(
                    asset: self.asset,
                    label: self.label,
                    address: address,
                    onTxCompleted: self.onTxCompleted
                )
            }
    }

    public var isFunded: Single<Bool> {
        balanceFetching
            .isFunded
            .take(1)
            .asSingle()
    }

    public var pendingBalance: Single<MoneyValue> {
        balanceFetching
            .pendingBalanceMoney
    }

    public var actionableBalance: Single<MoneyValue> {
        Single.zip(balance, pendingBalance)
            .map { values -> MoneyValue in
                let (balance, pending) = values
                return try balance - pending
            }
    }

    public var withdrawableBalance: Single<MoneyValue> {
        balanceFetching
            .withdrawableMoney
    }

    // swiftlint:disable:next opening_brace
    public var onTxCompleted: (TransactionResult) -> Completable {
        { [weak self] result -> Completable in
            guard let self = self else {
                return .error(PlatformKitError.default)
            }
            guard case let .hashed(hash, amount) = result else {
                return .error(PlatformKitError.default)
            }
            guard amount.isCrypto else {
                return .error(PlatformKitError.default)
            }
            return self.receiveAddress
                .flatMapCompletable(weak: self) { (self, receiveAddress) -> Completable in
                    self.custodialPendingDepositService.createPendingDeposit(
                        value: amount,
                        destination: receiveAddress.address,
                        transactionHash: hash,
                        product: "SIMPLEBUY"
                    )
                }
        }
    }

    public var balance: Single<MoneyValue> {
        balanceFetching
            .balanceMoney
    }

    public var actions: Single<AvailableActions> {
        Single.zip(balance, eligibilityService.isEligible)
            .map { (balance, isEligible) -> AvailableActions in
                var base: AvailableActions = [.viewActivity]
                if balance.isPositive {
                    base.insert(.send)
                }
                if balance.isPositive && isEligible {
                    base.insert(.sell)
                    base.insert(.swap)
                }
                return base
            }
            .observeOn(MainScheduler.instance)
    }

    private let balanceFetching: CustodialAccountBalanceFetching
    private let exchangeService: PairExchangeServiceAPI
    private let custodialAddressService: CustodialAddressServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let custodialPendingDepositService: CustodialPendingDepositServiceAPI

    public init(asset: CryptoCurrency,
                balanceProviding: BalanceProviding = resolve(),
                custodialAddressService: CustodialAddressServiceAPI = resolve(),
                exchangeProviding: ExchangeProviding = resolve(),
                custodialPendingDepositService: CustodialPendingDepositServiceAPI = resolve(),
                eligibilityService: EligibilityServiceAPI = resolve()) {
        self.label = asset.defaultTradeWalletName
        self.asset = asset
        self.exchangeService = exchangeProviding[asset]
        self.balanceFetching = balanceProviding[asset.currency].trading
        self.eligibilityService = eligibilityService
        self.custodialAddressService = custodialAddressService
        self.custodialPendingDepositService = custodialPendingDepositService
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
