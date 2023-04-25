// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureStakingDomain
import Localization
import MoneyKit
import ToolKit

public final class CryptoActiveRewardsWithdrawTarget: StaticTransactionTarget, CryptoAccount, TradingAccount, BlockchainAccountActivity {

    public let amount: MoneyValue

    private let wrapped: CryptoTradingAccount

    public init(
        _ cryptoTradingAccount: CryptoTradingAccount,
        amount: MoneyValue
    ) {
        self.wrapped = cryptoTradingAccount
        self.amount = amount
    }

    public func mainBalanceToDisplayPair(fiatCurrency: MoneyDomainKit.FiatCurrency, at time: MoneyDomainKit.PriceTime) -> AnyPublisher<MoneyDomainKit.MoneyValuePair, Error> {
        wrapped.mainBalanceToDisplayPair(fiatCurrency: fiatCurrency, at: time)
    }

    public func balancePair(fiatCurrency: MoneyDomainKit.FiatCurrency, at time: MoneyDomainKit.PriceTime) -> AnyPublisher<MoneyDomainKit.MoneyValuePair, Error> {
        wrapped.balancePair(fiatCurrency: fiatCurrency, at: time)
    }

    public var asset: MoneyDomainKit.CryptoCurrency {
        wrapped.asset
    }

    public var isDefault: Bool {
        wrapped.isDefault
    }

    public var identifier: AnyHashable {
        wrapped.identifier
    }

    public var activity: AnyPublisher<[ActivityItemEvent], Error> {
        wrapped.activity
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        wrapped.can(perform: action)
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        wrapped.receiveAddress
    }

    public var balance: AnyPublisher<MoneyDomainKit.MoneyValue, Error> {
        wrapped.balance
    }

    public var pendingBalance: AnyPublisher<MoneyDomainKit.MoneyValue, Error> {
        wrapped.pendingBalance
    }

    public var actionableBalance: AnyPublisher<MoneyDomainKit.MoneyValue, Error> {
        wrapped.actionableBalance
    }

    public func invalidateAccountBalance() {
        wrapped.invalidateAccountBalance()
    }

    public var label: String {
        wrapped.label
    }

    public var assetName: String {
        wrapped.assetName
    }

    public var accountType: AccountType {
        wrapped.accountType
    }

    public var currencyType: MoneyDomainKit.CurrencyType {
        wrapped.currencyType
    }
}
