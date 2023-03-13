// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import MoneyKit

public struct EarnProduct: NewTypeString {
    public var value: String
    public init(_ value: String) { self.value = value }
}

extension EarnProduct {
    public static let staking: Self = "staking"
    public static let savings: Self = "savings"
    public static let active: Self = "earn_cc1w"
}

private let id = blockchain.user.earn.product.asset

public final class EarnObserver: Client.Observer {

    private let app: AppProtocol
    private var signIn, signOut, subscription, total: AnyCancellable?

    public init(_ app: AppProtocol) {
        self.app = app
    }

    public func start() {

        signIn = app.on(blockchain.session.event.did.sign.in)
            .flatMap { [app] _ in
                app.publisher(for: blockchain.ux.earn.supported.products, as: [EarnProduct].self)
            }
            .replaceError(with: [.staking, .savings])
            .sink(to: My.fetched, on: self)

        signOut = app.on(blockchain.session.event.did.sign.out)
            .sink { [weak self] _ in self?.subscription = nil }
    }

    public func stop() {
        (signIn, subscription) = (nil, nil)
    }

    func fetched(_ products: [EarnProduct]) {
        subscription = products.map { product in resolve(tag: product) as EarnAccountService } // TODO: Do not rely on DIKit
            .map { service in
                [
                    service.limits()
                        .ignoreFailure()
                        .mapToVoid(),
                    service.eligibility()
                        .ignoreFailure()
                        .mapToVoid(),
                    service.userRates()
                        .ignoreFailure()
                        .mapToVoid(),
                    service.balances()
                        .ignoreFailure()
                        .mapToVoid(),
                    service.total()
                        .mapToVoid()
                ].merge()
            }
            .merge()
            .subscribe()

        total = products.map { _ in
            app.publisher(for: blockchain.user.earn.product.balance, as: MoneyValue.self).compactMap(\.value)
        }
        .combineLatest()
        .map { balances in balances.sum() }
        .sink { [app] total in
            Task {
                try await app.batch(
                    updates: [(blockchain.user.earn.balance, total?.data)]
                )
            }
        }
    }
}

public final class EarnAccountService {

    private let app: AppProtocol
    private let repository: EarnRepositoryAPI

    public var product: EarnProduct {
        EarnProduct(repository.product)
    }

    var context: Tag.Context {
        [blockchain.user.earn.product.id: repository.product]
    }

    public init(
        app: AppProtocol,
        repository: EarnRepositoryAPI
    ) {
        self.app = app
        self.repository = repository
    }

    public func balance(for currency: CryptoCurrency) -> AnyPublisher<EarnAccount?, UX.Error> {
        guard app.state.yes(if: blockchain.user.is.tier.gold) else { return .just(nil) }
        return balances().map(\.[currency.code]).eraseToAnyPublisher()
    }

    public func balances() -> AnyPublisher<EarnAccounts, UX.Error> {
        repository.balances()
            .handleEvents(
                receiveOutput: { [app, context] balances in
                    Task {
                        try await app.batch(
                            updates: balances.reduce(into: [(Tag.Event, Any?)]()) { data, next in
                                data.append((id[next.key].account.balance, next.value.balance?.moneyValue.data))
                                data.append((id[next.key].account.earning, next.value.earningBalance?.moneyValue.data))
                                data.append((id[next.key].account.bonding.deposits, next.value.bondingDeposits?.moneyValue.data))
                                data.append((id[next.key].account.locked, next.value.locked?.moneyValue.data))
                                data.append((id[next.key].account.pending.deposit, next.value.pendingDeposit?.moneyValue.data))
                                data.append((id[next.key].account.pending.withdrawal, next.value.pendingWithdrawal?.moneyValue.data))
                                data.append((id[next.key].account.total.rewards, next.value.totalRewards?.moneyValue.data))
                                data.append((id[next.key].account.unbonding.withdrawals, next.value.unbondingWithdrawals?.moneyValue.data))
                            } + [
                                (blockchain.user.earn.product.has.balance, balances.isNotEmpty)
                            ],
                            in: context
                        )
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    func total() -> AnyPublisher<MoneyValue?, Never> {
        balances()
            .ignoreFailure()
            .map { balances in balances.compactMap(\.value.balance?.moneyValue).sum() }
            .handleEvents(
                receiveOutput: { [app, context] total in
                    Task {
                        try await app.batch(
                            updates: [(blockchain.user.earn.product.balance, total?.data)],
                            in: context
                        )
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    public func invalidateBalances() {
        repository.invalidateBalances()
    }

    public func eligibility() -> AnyPublisher<EarnEligibility, UX.Error> {
        repository.eligibility()
            .handleEvents(
                receiveOutput: { [app, context] eligibility in
                    Task {
                        try await app.batch(
                            updates: eligibility.reduce(into: [(Tag.Event, Any?)]()) { data, next in
                                data.append((id[next.key].is.eligible, next.value.eligible))
                            },
                            in: context
                        )
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func userRates() -> AnyPublisher<EarnUserRates, UX.Error> {
        let usdQuotePublisher: AnyPublisher<MoneyValue?, Nabu.Error> = app
            .publisher(for: blockchain.api.nabu.gateway.price.crypto["USD"].fiat.quote.value, as: MoneyValue.self)
            .map(\.value)
            .setFailureType(to: Nabu.Error.self)
            .eraseToAnyPublisher()

        return Publishers
            .CombineLatest(
                repository.userRates(),
                usdQuotePublisher
            )
            .handleEvents(
                receiveOutput: { [app, context] user, usdQuote in
                    Task {
                        try await app.batch(
                            updates: user.rates.reduce(into: [(Tag.Event, Any?)]()) { data, next in
                                let triggerPrice: [String: Any]? = next.value.triggerPrice
                                    .flatMap { price -> FiatValue? in
                                        let value = FiatValue.create(minor: price, currency: .USD)
                                        guard let usdQuote else {
                                            return value
                                        }
                                        return value?.convert(using: usdQuote).fiatValue
                                    }?
                                    .moneyValue
                                    .data
                                data.append((id[next.key].rates.commission, next.value.commission.map { $0 / 100 }))
                                data.append((id[next.key].rates.rate, next.value.rate / 100))
                                data.append((id[next.key].rates.trigger.price, triggerPrice))
                            } + [
                                (blockchain.user.earn.product.all.assets, Array(user.rates.keys))
                            ],
                            in: context
                        )
                    }
                }
            )
            .map(\.0)
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func limits() -> AnyPublisher<EarnLimits, UX.Error> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .flatMap { [app, context, repository] currency -> AnyPublisher<EarnLimits, UX.Error> in
                repository.limits(currency: currency)
                    .handleEvents(
                        receiveOutput: { [app, context] limits in
                            Task {
                                try await app.batch(
                                    updates: limits.reduce(into: [(Tag.Event, Any?)]()) { data, next in
                                        data.append((id[next.key].limit.days.bonding, next.value.bondingDays ?? 0))
                                        data.append((id[next.key].limit.days.unbonding, next.value.unbondingDays ?? 0))
                                        data.append((id[next.key].limit.lock.up.duration, next.value.lockUpDuration))
                                        data.append((id[next.key].limit.minimum.deposit.value, ["currency": currency.code, "amount": next.value.minDepositValue ?? next.value.minDepositAmount]))
                                        data.append((id[next.key].limit.maximum.withdraw.value, ["currency": currency.code, "amount": next.value.maxWithdrawalAmount]))
                                        data.append((id[next.key].limit.withdraw.is.disabled, next.value.disabledWithdrawals ?? false))
                                        data.append((id[next.key].limit.reward.frequency, next.value.rewardFrequency.flatMap { id.limit.reward.frequency[$0.lowercased()] }))
                                    },
                                    in: context
                                )
                            }
                        }
                    )
                    .mapError(UX.Error.init)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func address(currency: CryptoCurrency) -> AnyPublisher<EarnAddress, UX.Error> {
        repository.address(currency: currency)
            .handleEvents(
                receiveOutput: { [app, context] address in
                    Task {
                        try await app.set(id[currency.code].address.key(to: context), to: address.accountRef)
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func activity(currency: CryptoCurrency) -> AnyPublisher<[EarnActivity], UX.Error> {
        repository.activity(currency: currency)
            .handleEvents(
                receiveOutput: { [app, context] activity in
                    Task {
                        try await app.set(id[currency.code].activity.key(to: context), to: activity.json())
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func deposit(amount: MoneyValue) -> AnyPublisher<Void, UX.Error> {
        repository.deposit(amount: amount).mapError(UX.Error.init).eraseToAnyPublisher()
    }

    public func withdraw(amount: MoneyValue) -> AnyPublisher<Void, UX.Error> {
        repository.withdraw(amount: amount).mapError(UX.Error.init).eraseToAnyPublisher()
    }

    public func pendingWithdrawalRequests(currency: CryptoCurrency) -> AnyPublisher<[EarnWithdrawalPendingRequest], UX.Error> {
        repository.pendingWithdrawalRequests(currencyCode: currency.code).mapError(UX.Error.init).eraseToAnyPublisher()
    }
}

extension MoneyValue {

    var data: [String: Any] {
        [
            "amount": storeAmount,
            "currency": code
        ]
    }
}

extension [MoneyValue] {

    func sum() -> MoneyValue? {
        do {
            return try reduce(into: MoneyValue.zero(currency: first.or(throw: "No elements").currency)) { sum, next in
                try sum += next
            }
        } catch {
            return nil
        }
    }
}
