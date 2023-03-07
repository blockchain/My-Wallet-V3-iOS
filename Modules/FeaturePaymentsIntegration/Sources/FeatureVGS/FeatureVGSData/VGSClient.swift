// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public protocol VGSClientAPI {

    func getCardTokenId() -> AnyPublisher<CardTokenIdResponse, NabuError>

    func postCVV(
        paymentId: String,
        cvv: String
    ) -> AnyPublisher<Void, NabuError>
}

public struct VGSClient: VGSClientAPI {
    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func getCardTokenId() -> AnyPublisher<CardTokenIdResponse, Errors.NabuError> {
        let request = requestBuilder.post(
            path: "/payments/cassy/tokenize",
            body: nil,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func getBeneficiaries() -> AnyPublisher<[BeneficiaryResponse], NabuNetworkError> {
        let request = requestBuilder.get(
            path: "/payments/beneficiaries",
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func postCVV(
        paymentId: String,
        cvv: String
    ) -> AnyPublisher<Void, NabuError> {
        let body = PostCVVRequest(paymentId: paymentId, cvv: cvv)
        let request = requestBuilder.post(
            path: "/payments/cassy/charge/cvv",
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}

struct PostCVVRequest: Encodable {
    let paymentId: String
    let cvv: String
}
