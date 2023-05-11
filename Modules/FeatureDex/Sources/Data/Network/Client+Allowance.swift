// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureDexDomain
import Foundation
import NetworkKit

protocol AllowanceClientAPI {
    func allowance(
        request: DexAllowanceRequest
    ) -> AnyPublisher<DexAllowanceResponse, NetworkError>
}

extension Client: AllowanceClientAPI {
    func allowance(
        request: DexAllowanceRequest
    ) -> AnyPublisher<DexAllowanceResponse, NetworkError> {
        guard
            let body = try? JSONEncoder().encode(request),
            let request = requestBuilder.post(path: Endpoint.allowance, body: body)
        else {
            return .failure(.unknown)
        }
        return networkAdapter.perform(request: request)
    }
}

public struct DexAllowanceRequest: Encodable, Equatable {
    let addressOwner: String
    let spender: String = Constants.spender
    let currency: String
    let network: String
}

public struct DexAllowanceResponse: Decodable, Equatable {
    public struct Result: Decodable, Equatable {
        let allowance: String
    }

    let result: Result
}
