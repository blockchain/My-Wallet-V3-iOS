// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Blockchain
import Combine
import DIKit
import Errors
import ToolKit

public enum OrdersServiceError: Error {
    case mappingError
    case network(NabuNetworkError)
}

public protocol OrdersServiceAPI: AnyObject {

    var hasUserMadeAnyPurchases: AnyPublisher<Bool, OrdersServiceError> { get }

    /// Streams all cached Simple Buy orders from cache, or fetch from
    /// remote if they are not cached
    var orders: AnyPublisher<[OrderDetails], OrdersServiceError> { get }

    /// Fetches the orders from remote
    func fetchOrders() -> AnyPublisher<[OrderDetails], OrdersServiceError>

    /// Fetches the order for a given identifier
    func fetchOrder(with identifier: String) -> AnyPublisher<OrderDetails, OrdersServiceError>
}

final class OrdersService: OrdersServiceAPI {

    // MARK: - Service Error

    private struct CacheKey: Hashable {}

    // MARK: - Exposed

    var hasUserMadeAnyPurchases: AnyPublisher<Bool, OrdersServiceError> {
        cachedAccumulatedTrades
            .stream(key: CacheKey())
            .compactMap { result -> [AccumulatedTradeDetails]? in
                guard case .success(let values) = result else {
                    return nil
                }
                return values
            }
            .map { accumulatedTradeAmounts -> Bool in
                guard let tradedAmountOfAllTime = accumulatedTradeAmounts.first(where: { $0.period == .all }) else {
                    return false
                }
                return !tradedAmountOfAllTime.amount.isZero
            }
            .setFailureType(to: OrdersServiceError.self)
            .eraseToAnyPublisher()
    }

    var orders: AnyPublisher<[OrderDetails], OrdersServiceError> {
        cachedOrders.get(key: CacheKey())
    }

    private let cachedOrders: CachedValueNew<
        CacheKey,
        [OrderDetails],
        OrdersServiceError
    >

    private let cachedAccumulatedTrades: CachedValueNew<
        CacheKey,
        [AccumulatedTradeDetails],
        OrdersServiceError
    >

    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let client: OrderDetailsClientAPI

    // MARK: - Setup

    init(
        app: AppProtocol = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        client: OrderDetailsClientAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client

        let cacheOrders: AnyCache<CacheKey, [OrderDetails]> = InMemoryCache(
            configuration: .onLoginLogoutTransactionAndDashboardRefresh(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        )
        .eraseToAnyCache()
        self.cachedOrders = CachedValueNew(
            cache: cacheOrders,
            fetch: { _ in
                client
                    .orderDetails(pendingOnly: false)
                    .map { [analyticsRecorder] response in
                        response.compactMap { order in
                            OrderDetails(recorder: analyticsRecorder, response: order)
                        }
                    }
                    .mapError(OrdersServiceError.network)
                    .eraseToAnyPublisher()
            }
        )

        let cacheAccumulatedTrades: AnyCache<CacheKey, [AccumulatedTradeDetails]> = InMemoryCache(
            configuration: .onLoginLogoutTransactionAndDashboardRefresh(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()
        self.cachedAccumulatedTrades = CachedValueNew(
            cache: cacheAccumulatedTrades,
            fetch: { _ in
                app.publisher(
                    for: blockchain.app.is.external.brokerage,
                    as: Bool.self
                )
                .replaceError(with: false)
                .flatMap { isEligible in
                    client
                        .fetchAccumulatedTradeAmounts(products: isEligible ? "EXTERNAL_BROKERAGE" : "SIMPLEBUY")
                        .mapError(OrdersServiceError.network)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
        )
    }

    func fetchOrders() -> AnyPublisher<[OrderDetails], OrdersServiceError> {
        cachedOrders.get(key: CacheKey(), forceFetch: true)
    }

    func fetchOrder(with identifier: String) -> AnyPublisher<OrderDetails, OrdersServiceError> {
        client.orderDetails(with: identifier)
            .mapError(OrdersServiceError.network)
            .map { [analyticsRecorder] response in
                OrderDetails(recorder: analyticsRecorder, response: response)
            }
            .onNil(OrdersServiceError.mappingError)
            .eraseToAnyPublisher()
    }
}
