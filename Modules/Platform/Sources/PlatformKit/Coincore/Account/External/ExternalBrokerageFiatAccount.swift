// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Dependencies

public final class ExternalBrokerageFiatAccount: FiatAccount, FiatAccountCapabilities {

    public private(set) lazy var identifier: String = "ExternalBrokerageFiatAccount." + fiatCurrency.code

    public let isDefault: Bool = true
    public let label: String
    public let assetName: String
    public let fiatCurrency: FiatCurrency
    public let accountType: AccountType = .external

    private let balanceService: TradingBalanceServiceAPI = resolve()
    private let priceService: PriceServiceAPI = resolve()

    @Dependency(\.app) var app

    init(currency: FiatCurrency) {
        self.label = currency.defaultWalletName
        self.assetName = currency.name
        self.fiatCurrency = currency
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(ReceiveAddressError.notSupported)
    }

    public var capabilities: Capabilities? { nil }

    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        balanceService.balance(for: currencyType)
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        balances.map(\.balance?.pending)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        balances.map(\.balance?.available)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var mainBalanceToDisplay: AnyPublisher<MoneyValue, Error> {
        balances.map(\.balance?.mainBalanceToDisplay)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balances.map(\.balance)
            .map { [fiatCurrency] balance -> (available: MoneyValue, pending: MoneyValue) in
                guard let balance else { return (.zero(currency: fiatCurrency), .zero(currency: fiatCurrency)) }
                return (balance.available, balance.pending)
            }
            .eraseError()
            .tryMap { [fiatCurrency] values -> MoneyValue in
                guard values.available.isPositive else {
                    return .zero(currency: fiatCurrency)
                }
                return try values.available - values.pending
            }
            .eraseToAnyPublisher()
    }

    public var withdrawableBalance: AnyPublisher<MoneyValue, Error> {
        balances.map(\.balance?.withdrawable)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .deposit, .withdraw:
            return .just(true) // TODO: Account for balance checks to pass on withdraw
        case
                .buy,
                .sell,
                .send,
                .sign,
                .swap,
                .viewActivity,
                .interestTransfer,
                .interestWithdraw,
                .stakingDeposit,
                .stakingWithdraw,
                .activeRewardsDeposit,
                .activeRewardsWithdraw,
                .receive:
            return .just(false)
        }
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func invalidateAccountBalance() {
        balanceService.invalidateTradingAccountBalances()
    }
}
