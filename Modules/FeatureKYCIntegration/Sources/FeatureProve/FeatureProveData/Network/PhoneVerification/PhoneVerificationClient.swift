// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public final class PhoneVerificationClient: PhoneVerificationClientAPI {

    private enum Path {
        static let kycProveAuthStart = ["kyc", "prove", "auth", "instant-link", "start"]
        static let kycProveAuthStatus = ["kyc", "prove", "auth", "status"]
    }

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
        phone: String
    ) -> AnyPublisher<StartPhoneVerificationResponse, NabuError> {
        startInstantLinkPossession(body: .init(phone: phone))
    }

    private func startInstantLinkPossession(
        body: PhoneVerificationRequest
    ) -> AnyPublisher<StartPhoneVerificationResponse, NabuError> {
        let encoder = JSONEncoder()
        let request = requestBuilder.post(
            path: Path.kycProveAuthStart,
            body: try? encoder.encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func fetchInstantLinkPossessionStatus()
    -> AnyPublisher<PhoneVerificationResponse, NabuError> {
        let request = requestBuilder.get(
            path: Path.kycProveAuthStatus,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
