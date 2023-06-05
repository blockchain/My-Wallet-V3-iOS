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
