//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Combine
import FeatureDexDomain
import NetworkKit
import DIKit
import ComposableArchitecture

public protocol AvailableChainsServiceAPI {
    func availableChains() -> AnyPublisher<[Chain], NetworkError>
}

public class AvailableChainsService: AvailableChainsServiceAPI {

    private var chainsClient: ChainsClientAPI
    public init(chainsClient: ChainsClientAPI) {
        self.chainsClient = chainsClient
    }
    public func availableChains() -> AnyPublisher<[Chain], NetworkError> {
        chainsClient.chains()
    }
}


public struct AvailableChainsServiceDependencyKey: DependencyKey {
    public static var liveValue: AvailableChainsServiceAPI = AvailableChainsService(
        chainsClient: Client(
            networkAdapter: DIKit.resolve(),
            requestBuilder: DIKit.resolve()
        )
    )

//    public static var previewValue: AvailableChainsServiceAPI = DexAllowanceRepositoryPreview(allowance: "1")
//
//    public static var testValue: AvailableChainsServiceAPI { previewValue }

}

extension DependencyValues {
    public var availableChainsService: AvailableChainsServiceAPI {
        get { self[AvailableChainsServiceDependencyKey.self] }
        set { self[AvailableChainsServiceDependencyKey.self] = newValue }
    }
}
