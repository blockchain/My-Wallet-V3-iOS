// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import NetworkKit

protocol SubscriptionsClientAPI {
    func subscribe(
        guidHash: String,
        sharedKeyHash: String,
        subscriptions: [SubscriptionEntry]
    ) -> AnyPublisher<Void, NetworkError>
    func unsubscribe(
        guidHash: String,
        sharedKeyHash: String,
        currency: String
    ) -> AnyPublisher<Void, NetworkError>
    func subscriptions(
        guidHash: String,
        sharedKeyHash: String
    ) -> AnyPublisher<SubscriptionsResponse, NetworkError>
}

extension Client: SubscriptionsClientAPI {

    private struct SubscribeRequestPayload: Encodable {
        let auth: AuthDataPayload
        let data: [SubscriptionEntry]
    }

    private struct UnsubscribeRequestPayload: Encodable {
        let auth: AuthDataPayload
        let currency: String
    }

    private struct SubscriptionsRequestPayload: Encodable {
        let auth: AuthDataPayload
    }

    func subscribe(
        guidHash: String,
        sharedKeyHash: String,
        subscriptions: [SubscriptionEntry]
    ) -> AnyPublisher<Void, NetworkError> {
        let payload = SubscribeRequestPayload(
            auth: AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash),
            data: subscriptions
        )
        let request = requestBuilder
            .post(
                path: Endpoint.subscribe,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
            .mapToVoid()
    }

    func unsubscribe(
        guidHash: String,
        sharedKeyHash: String,
        currency: String
    ) -> AnyPublisher<Void, NetworkError> {
        let payload = UnsubscribeRequestPayload(
            auth: AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash),
            currency: currency
        )
        let request = requestBuilder
            .post(
                path: Endpoint.unsubscribe,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
            .mapToVoid()
    }

    func subscriptions(
        guidHash: String,
        sharedKeyHash: String
    ) -> AnyPublisher<SubscriptionsResponse, NetworkError> {
        let payload = SubscriptionsRequestPayload(
            auth: AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash)
        )
        let request = requestBuilder
            .post(
                path: Endpoint.subscriptions,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
    }
}
