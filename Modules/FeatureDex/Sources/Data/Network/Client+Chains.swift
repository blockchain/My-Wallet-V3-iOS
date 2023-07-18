// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Dependencies
import DIKit
import FeatureDexDomain
import NetworkKit

public protocol ChainsClientAPI {
    func chains() -> AnyPublisher<[Chain], NetworkError>
}

extension Client: ChainsClientAPI {
    func chains() -> AnyPublisher<[Chain], NetworkError> {
        guard let request = requestBuilder.get(path: Endpoint.chains) else {
            return .failure(.unknown)
        }
        return networkAdapter.perform(request: request)
    }
}

public struct ChainsClientAPIDependencyKey: DependencyKey {
    public static var previewValue: ChainsClientAPI = ChainsClientAPIPreview()
    public static var testValue: ChainsClientAPI = ChainsClientAPIPreview()
    public static var liveValue: ChainsClientAPI = Client(
        networkAdapter: DIKit.resolve(),
        requestBuilder: DIKit.resolve(tag: DIKitContext.dex)
    )
}

extension DependencyValues {
    public var chainsClient: ChainsClientAPI {
        get { self[ChainsClientAPIDependencyKey.self] }
        set { self[ChainsClientAPIDependencyKey.self] = newValue }
    }
}

final class ChainsClientAPIPreview: ChainsClientAPI {
    func chains() -> AnyPublisher<[Chain], Errors.NetworkError> {
        .just([Chain(chainId: 1), Chain(chainId: 137)])
    }
}
