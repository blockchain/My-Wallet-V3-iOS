// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain
import Foundation
import ToolKit

final class CardAcquirersRepository: CardAcquirersRepositoryAPI {

    private struct Key: Hashable {}

    var eligibleCardAcquirers: AnyPublisher<[PaymentCardAcquirer], NabuNetworkError> {
        cachedValue.get(key: Key()).eraseToAnyPublisher()
    }

    private let cachedValue: CachedValueNew<
        Key,
        [PaymentCardAcquirer],
        NabuNetworkError
    >

    init(
        eligibleCardAcquirersClient: EligibleCardAcquirersAPI = resolve()
    ) {
        let cache: AnyCache<Key, [PaymentCardAcquirer]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                eligibleCardAcquirersClient.paymentsCardAcquirers()
            }
        )
    }

    func tokenize(_ card: CardData) -> AnyPublisher<[String: String], Never> {
        cachedValue.get(key: Key(), forceFetch: true)
            .map { acquirers -> [AnyPublisher<Result<CardTokenizationResponse, CardAcquirerError>, Never>] in
                acquirers
                    .compactMap { acquirer -> AnyPublisher<CardTokenizationResponse, CardAcquirerError>? in
                        switch acquirer.cardAcquirerName {
                        case .checkout:
                            return CheckoutClient(acquirer.apiKey)
                                .tokenize(card, accounts: acquirer.cardAcquirerAccountCodes)
                        case .stripe:
                            return StripeClient(acquirer.apiKey)
                                .tokenize(card, accounts: acquirer.cardAcquirerAccountCodes)
                        case .unknown, .everyPay, .fake:
                            return nil
                        }
                    }
                    .map { token -> AnyPublisher<Result<CardTokenizationResponse, CardAcquirerError>, Never> in
                        token
                            .retry(3)
                            .timeout(.seconds(3), scheduler: DispatchQueue.global(qos: .background))
                            .result()
                    }
            }
            .flatMap { $0.zip() }
            .map { results -> [String: String] in
                results
                    .compactMap { result -> [String: String]? in
                        switch result {
                        case .success(let tokenResponse):
                            return tokenResponse.params
                        case .failure:
                            return nil
                        }
                    }
                    .reduce(into: [String: String]()) {
                        $0.merge($1)
                    }
            }
            .replaceError(with: [:])
            .eraseToAnyPublisher()
    }

    func authorizationState(
        for acquirer: ActivateCardResponse.CardAcquirer
    ) -> AnyPublisher<PartnerAuthorizationData.State, Error> {
        switch acquirer.cardAcquirerName {
        case .checkout, .fake:
            return .just(CheckoutClient.authorizationState(acquirer))
        case .stripe:
            return .just(StripeClient.authorizationState(acquirer))
        case .unknown, .everyPay:
            return .failure(CardAcquirerError.unknownAcquirer)
        }
    }
}
