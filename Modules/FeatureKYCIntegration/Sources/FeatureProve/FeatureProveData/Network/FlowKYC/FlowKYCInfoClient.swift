// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public final class FlowKYCInfoClient: FlowKYCInfoClientAPI {

    private enum Path {
        static let flowsKyc = ["flows", "kyc"]
    }

    private enum Parameter {
        static let entryPoint = "entryPoint"
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

    public func getKYCFlowInfo() -> AnyPublisher<FlowKYCInfoClientResponse, Errors.NabuError> {
        getKYCFlowInfo(
            body: .init(
                entryPoint: .other
            )
        )
    }

    private func getKYCFlowInfo(
        body: FlowKYCInfoClientRequest
    ) -> AnyPublisher<FlowKYCInfoClientResponse, NabuError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.entryPoint,
                value: body.entryPoint.rawValue
            )
        ]
        let request = requestBuilder.get(
            path: Path.flowsKyc,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
