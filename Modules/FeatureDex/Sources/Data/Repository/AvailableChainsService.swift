// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureDexDomain
import NetworkKit

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
