// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import DIKit
import FeatureStakingDomain
import NetworkKit
import ToolKit

final class EarnRepository: EarnRepositoryAPI {

    var product: String { client.product }

    private let client: EarnClient

    private lazy var cache = (
        balances: cache(
            client.balances,
            reset: .on(
                blockchain.session.event.did.sign.in,
                blockchain.session.event.did.sign.out,
                blockchain.ux.transaction.event.did.finish,
                blockchain.ux.home.event.did.pull.to.refresh
            ),
            refreshControl: PerpetualCacheRefreshControl()
        ),
        eligibility: cache(client.eligibility, reset: .onLoginLogoutKYCChanged()),
        userRates: cache(client.userRates),
        limits: cache(client.limits),
        address: cache(client.address(currency:)),
        activity: cache(client.activity(currency:), reset: .onLoginLogoutTransaction())
    )

    init(client: EarnClient) {
        self.client = client
    }

    func balances() -> AnyPublisher<EarnAccounts, Nabu.Error> {
        cache.balances.get(key: #line)
    }

    func invalidateBalances() {
        cache.balances.invalidateCache()
    }

    func eligibility() -> AnyPublisher<EarnEligibility, Nabu.Error> {
        cache.eligibility.get(key: #line)
    }

    func userRates() -> AnyPublisher<EarnUserRates, Nabu.Error> {
        cache.userRates.get(key: #line)
    }

    func limits(currency: FiatCurrency) -> AnyPublisher<EarnLimits, Nabu.Error> {
        cache.limits.get(key: currency)
    }

    func address(currency: CryptoCurrency) -> AnyPublisher<EarnAddress, Nabu.Error> {
        cache.address.get(key: currency)
    }

    func activity(currency: CryptoCurrency?) -> AnyPublisher<[EarnActivity], Nabu.Error> {
        cache.activity.get(key: currency)
    }

    func deposit(amount: MoneyValue) -> AnyPublisher<Void, Nabu.Error> {
        client.deposit(amount: amount)
    }

    func withdraw(amount: MoneyValue) -> AnyPublisher<Void, Nabu.Error> {
        client.withdraw(amount: amount)
    }

    func pendingWithdrawalRequests(
        currencyCode: String
    ) -> AnyPublisher<[EarnWithdrawalPendingRequest], Nabu.Error> {
        client.pendingWithdrawalRequests(currencyCode: currencyCode)
    }

    func bondingStakingTxs(
        currencyCode: String
    ) -> AnyPublisher<EarnBondingTxsRequest, Nabu.Error> {
        client.bondingStakingTxs(currencyCode: currencyCode)
    }

    private func cache<Value>(
        _ publisher: @escaping () -> AnyPublisher<Value, Nabu.Error>,
        reset configuration: CacheConfiguration = .onLoginLogout(),
        refreshControl: CacheRefreshControl = PerpetualCacheRefreshControl()
    ) -> CachedValueNew<Int, Value, Nabu.Error> {
        cache({ _ in publisher() }, refreshControl: refreshControl)
    }

    private func cache<Key, Value>(
        _ publisher: @escaping (Key) -> AnyPublisher<Value, Nabu.Error>,
        reset configuration: CacheConfiguration = .onLoginLogout(),
        refreshControl: CacheRefreshControl = PerpetualCacheRefreshControl()
    ) -> CachedValueNew<Key, Value, Nabu.Error> {
        CachedValueNew(
            cache: InMemoryCache(configuration: configuration, refreshControl: refreshControl).eraseToAnyCache(),
            fetch: publisher
        )
    }
}
