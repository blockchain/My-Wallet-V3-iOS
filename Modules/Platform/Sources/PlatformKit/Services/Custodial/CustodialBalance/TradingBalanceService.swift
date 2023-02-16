// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit

public protocol TradingBalanceServiceAPI: AnyObject {
    var balances: AnyPublisher<CustodialAccountBalanceStates, Never> { get }

    func invalidateTradingAccountBalances()
    func balance(for currencyType: CurrencyType) -> AnyPublisher<CustodialAccountBalanceState, Never>
    func fetchBalances() -> AnyPublisher<CustodialAccountBalanceStates, Never>
}

class TradingBalanceService: TradingBalanceServiceAPI {

    private struct Key: Hashable {}

    // MARK: - Properties

    var balances: AnyPublisher<CustodialAccountBalanceStates, Never> {
        cachedValue.stream(key: Key())
            .map { result -> CustodialAccountBalanceStates in
                do {
                    return try result.get()
                } catch {
                    return .absent
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let app: AppProtocol
    private let client: TradingBalanceClientAPI
    private let cachedValue: CachedValueNew<
        Key,
        CustodialAccountBalanceStates,
        Error
    >

    // MARK: - Setup

    init(app: AppProtocol = resolve(), client: TradingBalanceClientAPI = resolve()) {
        self.app = app
        self.client = client

        let cache: AnyCache<Key, CustodialAccountBalanceStates> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] _ in
                client
                    .balance
                    .map { response in
                        guard let response else {
                            return .absent
                        }
                        return CustodialAccountBalanceStates(response: response)
                    }
                    .handleEvents(receiveOutput: { [app] states in
                        Task {
                            for (currency, state) in states.balances {
                                switch state {
                                case .absent:
                                    try await app.set(blockchain.user.trading[currency.code].account.balance, to: nil)
                                case .present(let value):
                                    try await app.batch(
                                        updates: [
                                            (blockchain.user.trading[currency.code].account.balance.available.amount, value.available.minorString),
                                            (blockchain.user.trading[currency.code].account.balance.available.currency, value.available.currency.code),

                                            (blockchain.user.trading[currency.code].account.balance.pending.amount, value.pending.minorString),
                                            (blockchain.user.trading[currency.code].account.balance.pending.currency, value.pending.currency.code),

                                            (blockchain.user.trading[currency.code].account.balance.withdrawable.amount, value.withdrawable.minorString),
                                            (blockchain.user.trading[currency.code].account.balance.withdrawable.currency, value.available.currency.code),

                                            (blockchain.user.trading[currency.code].account.balance.display.amount, value.mainBalanceToDisplay.minorString),
                                            (blockchain.user.trading[currency.code].account.balance.display.currency, value.mainBalanceToDisplay.currency.code)
                                        ]
                                    )
                                }
                            }
                        }
                    })
                    .eraseError()
            }
        )
    }

    // MARK: - Methods

    func invalidateTradingAccountBalances() {
        cachedValue
            .invalidateCacheWithKey(Key())
    }

    func balance(for currencyType: CurrencyType) -> AnyPublisher<CustodialAccountBalanceState, Never> {
        balances
            .map { response -> CustodialAccountBalanceState in
                response[currencyType]
            }
            .eraseToAnyPublisher()
    }

    func fetchBalances() -> AnyPublisher<CustodialAccountBalanceStates, Never> {
        cachedValue
            .get(key: Key(), forceFetch: true)
            .replaceError(with: .absent)
            .eraseToAnyPublisher()
    }
}
