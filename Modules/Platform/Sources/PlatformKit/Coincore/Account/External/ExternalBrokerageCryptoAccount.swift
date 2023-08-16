// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Dependencies

public final class ExternalBrokerageCryptoAccount: CryptoAccount {

    public private(set) lazy var identifier: String = "ExternalBrokerageCryptoAccount." + asset.code

    public let isDefault: Bool = true
    public let label: String
    public let assetName: String
    public let asset: CryptoCurrency
    public let accountType: AccountType = .external

    private let balanceService: TradingBalanceServiceAPI = resolve()
    private let priceService: PriceServiceAPI = resolve()

    @Dependency(\.app) var app

    init(asset: CryptoCurrency) {
        self.label = asset.defaultTradingWalletName
        self.assetName = asset.name
        self.asset = asset
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(ReceiveAddressError.notSupported)
    }

    public var capabilities: Capabilities? { nil }

    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        balanceService.balance(for: asset.currencyType)
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
            .map { [asset] balance -> (available: MoneyValue, pending: MoneyValue) in
                guard let balance else { return (.zero(currency: asset), .zero(currency: asset)) }
                return (balance.available, balance.pending)
            }
            .eraseError()
            .tryMap { [asset] values -> MoneyValue in
                guard values.available.isPositive else {
                    return .zero(currency: asset)
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
        case .buy, .sell:
            return .just(true)
        case
                .deposit,
                .withdraw,
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
