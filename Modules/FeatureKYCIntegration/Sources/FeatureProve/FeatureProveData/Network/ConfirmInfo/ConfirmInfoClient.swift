// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain
import Foundation
import NetworkKit

public final class ConfirmInfoClient: ConfirmInfoClientAPI {

    private enum Path {
        static let kycProvePii = ["kyc", "prove", "pii"]
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

    public func confirmInfo(
        firstName: String,
        lastName: String,
        address: Address,
        dateOfBirth: Date,
        phone: String
    ) -> AnyPublisher<Void, NabuError> {
        confirmInfo(
            body: .init(
                firstName: firstName,
                lastName: lastName,
                address: address,
                dateOfBirth: dateOfBirth,
                phone: phone
            )
        )
    }

    private func confirmInfo(
        body: ConfirmInfoRequest
    ) -> AnyPublisher<Void, NabuError> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)
        let request = requestBuilder.post(
            path: Path.kycProvePii,
            body: try? encoder.encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
