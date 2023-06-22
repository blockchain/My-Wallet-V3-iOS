// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain
import Foundation
import ToolKit

class CardListRepository: CardListRepositoryAPI {

    private struct Key: Hashable {}

    private let cachedValue: CachedValueNew<
        Key,
        [CardData],
        NabuNetworkError
    >
    var cards: AnyPublisher<[CardData], Never> {
        cachedValue
            .stream(key: Key())
            .map {
                switch $0 {
                case .success(let value):
                    return value
                case .failure:
                    return []
                }
            }
            .eraseToAnyPublisher()
    }

    init(
        cardListClient: CardListClientAPI = resolve()
    ) {
        let cache: AnyCache<Key, [CardData]> = InMemoryCache(
            configuration: .on(blockchain.session.event.did.sign.in, blockchain.session.event.did.sign.out),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                cardListClient
                    .getCardList(enableProviders: true)
                    .compactMap { payloads in payloads.compactMap(CardData.init(response:)) }
                    .eraseToAnyPublisher()
            }
        )
    }

    func card(by identifier: String) -> AnyPublisher<CardData?, Never> {
        cards
            .map { cards -> CardData? in
                cards.first(where: { card in card.identifier == identifier })
            }
            .eraseToAnyPublisher()
    }

    func fetchCardList() -> AnyPublisher<[CardData], Never> {
        cachedValue.get(key: Key(), forceFetch: true).replaceError(with: []).eraseToAnyPublisher()
    }
}
