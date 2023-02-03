// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Errors
import MoneyKit
import RxRelay
import RxSwift
import RxToolKit
import ToolKit
import WalletPayloadKit

final class EligibilityService: EligibilityServiceAPI {

    private struct Key: Hashable {}
    private let cache: CachedValueNew<Key, Eligibility, Nabu.Error>

    // MARK: - Properties

    var isEligiblePublisher: AnyPublisher<Bool, Never> {
        cache.stream(key: Key())
            .map { result in result.success?.eligible ?? false }
            .eraseToAnyPublisher()
    }

    var isEligible: Single<Bool> {
        cache.get(key: Key()).map(\.eligible).asSingle()
    }

    // MARK: - Setup

    init(
        client: EligibilityClientAPI = resolve(),
        app: AppProtocol = resolve(),
        reactiveWallet: ReactiveWalletAPI = resolve()
    ) {
        cache = CachedValueNew(
            cache: InMemoryCache(
                configuration: .on(blockchain.user.event.did.update),
                refreshControl: PeriodicCacheRefreshControl(refreshInterval: 180)
            )
            .eraseToAnyCache(),
            fetch: { [app] _ in
                app.publisher(for: blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self)
                    .combineLatest(reactiveWallet.waitUntilInitializedFirst.prefix(1))
                    .compactMap(\.0.value)
                    .flatMap { currency in
                        client.isEligible(
                            for: currency.code,
                            methods: [
                                PaymentMethodPayloadType.bankTransfer.rawValue,
                                PaymentMethodPayloadType.card.rawValue
                            ]
                        )
                        .map { response in
                            Eligibility(
                                eligible: response.eligible,
                                simpleBuyTradingEligible: response.simpleBuyTradingEligible,
                                simpleBuyPendingTradesEligible: response.simpleBuyPendingTradesEligible,
                                pendingDepositSimpleBuyTrades: response.pendingDepositSimpleBuyTrades,
                                pendingConfirmationSimpleBuyTrades: response.pendingConfirmationSimpleBuyTrades,
                                maxPendingDepositSimpleBuyTrades: response.maxPendingDepositSimpleBuyTrades,
                                maxPendingConfirmationSimpleBuyTrades: response.maxPendingConfirmationSimpleBuyTrades
                            )
                        }
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func fetch() -> Single<Bool> {
        cache.get(key: Key(), forceFetch: true).map(\.eligible).asSingle()
    }

    func eligibility() -> AnyPublisher<Eligibility, Error> {
        cache.get(key: Key()).eraseError()
    }
}
