////Copyright © Blockchain Luxembourg S.A. All rights reserved.
//
//import Foundation
//import ToolKit
//import MoneyKit
//
//public protocol TopMoversRepositoryAPI {
//    func topMovers(with currency: FiatCurrency) -> StreamOf<[TopMoverInfo], Never>
//}
//
//final class TopMoversRepository: TopMoversRepositoryAPI {
//    private typealias ThisCachedValue = CachedValueNew<Key, [TopMoverInfo], Never>
//
//    struct Key: Hashable, CustomStringConvertible {
//        let currency: FiatCurrency
//        var description: String { "id-\(currency)" }
//    }
//
//    private let cachedValue: ThisCachedValue
//    private let client: PriceClientAPI
//
//    init(client: PriceClientAPI) {
//        self.client = client
//
//        let topMoversCache = InMemoryCache<Key, [TopMoverInfo]>(
//            configuration: .onLoginLogoutTransaction(),
//            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
//        )
//        .eraseToAnyCache()
//
//
//        self.cachedValue = ThisCachedValue(
//            cache: topMoversCache,
//            fetch: { [client] key in
//                client
//                    .topMovers(with: key.currency,
//                               topFirst: 5,
//                               custodialOnly: true)
//                    .map({ response in
//                        let topMoversDescending = response.topMoversDescending
//                        return topMoversDescending.map { topMover in
//                            TopMoverInfo(currency: topMover.currency,
//                                         lastPrice: .zero(currency: .ADP))
//                        }
//                    })
//            }
//        )
//    }
//
//    public func topMovers(with currency: FiatCurrency) -> StreamOf<[TopMoverInfo], Never> {
//        cachedValue
//            .stream(key: Key(currency: currency))
//    }
//}
