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

    enum Key {
        case custodial, external
    }

    // MARK: - Properties

    var balances: AnyPublisher<CustodialAccountBalanceStates, Never> {
        app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
            .map(\.value)
            .replaceNil(with: false)
            .replaceError(with: false)
            .logErrorIfNoOutput(id: blockchain.app.is.external.brokerage(\.id))
            .flatMap { [cachedValue] useExternalTradingAccount -> AnyPublisher<CustodialAccountBalanceStates, Never> in
                if useExternalTradingAccount {
                    Self.streamBalances(cachedValue, .external)
                } else {
                    Self.streamBalances(cachedValue, .custodial)
                }
            }
            .eraseToAnyPublisher()
    }

    static func streamBalances(
        _ cachedValue: CachedValueNew<Key, CustodialAccountBalanceStates, Error>,
        _ key: Key
    ) -> AnyPublisher<CustodialAccountBalanceStates, Never> {
        cachedValue.stream(key: key)
            .logErrorIfNoOutput(id: "streamBalances(\(key))")
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
            configuration: .on(
                blockchain.session.event.did.sign.in,
                blockchain.ux.transaction.event.did.finish,
                blockchain.ux.home.event.did.pull.to.refresh
            ),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 15)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] key in
                let publisher: AnyPublisher<CustodialBalanceResponse?, NabuNetworkError> = switch key {
                case .custodial: client.balance
                case .external: client.externalBrokerageBalance
                }
                return publisher.map { response in
                    guard let response else { return .absent }
                    return CustodialAccountBalanceStates(response: response)
                }
                .handleEvents(receiveOutput: { [app] states in
                    Task {
                        try await app.set(blockchain.user.trading.currencies, to: Array(states.balances.keys.map(\.code)))
                        for (currency, state) in states.balances {
                            switch state {
                            case .absent:
                                try await app.set(blockchain.user.trading.account[currency.code].balance, to: nil)
                            case .present(let value):
                                try await app.batch(
                                    updates: [
                                        (blockchain.user.trading.account[currency.code].balance.available.amount, value.available.storeAmount),
                                        (blockchain.user.trading.account[currency.code].balance.available.currency, value.available.currency.code),

                                        (blockchain.user.trading.account[currency.code].balance.pending.amount, value.pending.storeAmount),
                                        (blockchain.user.trading.account[currency.code].balance.pending.currency, value.pending.currency.code),

                                        (blockchain.user.trading.account[currency.code].balance.withdrawable.amount, value.withdrawable.storeAmount),
                                        (blockchain.user.trading.account[currency.code].balance.withdrawable.currency, value.available.currency.code),

                                        (blockchain.user.trading.account[currency.code].balance.display.amount, value.mainBalanceToDisplay.storeAmount),
                                        (blockchain.user.trading.account[currency.code].balance.display.currency, value.mainBalanceToDisplay.currency.code)
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
        cachedValue.invalidateCacheWithKey(.custodial)
        cachedValue.invalidateCacheWithKey(.external)
    }

    func balance(for currencyType: CurrencyType) -> AnyPublisher<CustodialAccountBalanceState, Never> {
        balances.map { response -> CustodialAccountBalanceState in
            response[currencyType]
        }
        .eraseToAnyPublisher()
    }

    func fetchBalances() -> AnyPublisher<CustodialAccountBalanceStates, Never> {
        cachedValue
            .get(key: .custodial, forceFetch: true)
            .replaceError(with: .absent)
            .eraseToAnyPublisher()
    }
}
