// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public final class PrefillInfoClient: PrefillInfoClientAPI {

    private enum Path {
        static let kycProvePrefill = ["kyc", "prove", "pre-fill"]
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

    public func getPrefillInfo(
        phone: String,
        dateOfBirth: Date
    ) -> AnyPublisher<PrefillInfoResponse, NabuError> {
        getPrefillInfo(
            body: .init(
                phone: phone,
                dateOfBirth: dateOfBirth
            )
        )
    }

    private func getPrefillInfo(
        body: PrefillInfoRequest
    ) -> AnyPublisher<PrefillInfoResponse, NabuError> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)
        let request = requestBuilder.post(
            path: Path.kycProvePrefill,
            body: try? encoder.encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
