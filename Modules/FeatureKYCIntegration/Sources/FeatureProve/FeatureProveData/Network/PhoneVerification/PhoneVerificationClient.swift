// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public final class PhoneVerificationClient: PhoneVerificationClientAPI {
    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func startInstantLinkPossession(
        phoneNumber: String
    ) -> AnyPublisher<Void, NabuError> {
        startInstantLinkPossession(body: .init(phoneNumber: phoneNumber))
    }

    private func startInstantLinkPossession(
        body: PhoneVerificationRequest
    ) -> AnyPublisher<Void, NabuError> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)
        let request = requestBuilder.post(
            path: "/start",
            body: try? encoder.encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func fetchInstantLinkPossessionStatus()
    -> AnyPublisher<PhoneVerificationResponse, NabuError> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)
        let request = requestBuilder.get(
            path: "/status",
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
