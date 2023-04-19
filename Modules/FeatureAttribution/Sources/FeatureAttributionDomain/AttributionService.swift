// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import ToolKit

public class AttributionService: AttributionServiceAPI {
    private var skAdNetworkService: SkAdNetworkServiceAPI
    private var featureFlagService: FeatureFlagsServiceAPI
    private var attributionRepository: AttributionRepositoryAPI

    public init(
        skAdNetworkService: SkAdNetworkServiceAPI,
        attributionRepository: AttributionRepositoryAPI,
        featureFlagService: FeatureFlagsServiceAPI
    ) {
        self.skAdNetworkService = skAdNetworkService
        self.attributionRepository = attributionRepository
        self.featureFlagService = featureFlagService
    }

    public func registerForAttribution() {
        skAdNetworkService.firstTimeRegister()
    }

    public func startUpdatingConversionValues() -> AnyPublisher<Void, NetworkError> {
        featureFlagService
            .isEnabled(.skAdNetworkAttribution)
            .flatMap { [weak self] isEnabled -> AnyPublisher<Void, NetworkError> in
                guard let self else { return .just(()) }
                guard isEnabled else {
                    return .just(())
                }
                return startObservingValues()
            }
            .eraseToAnyPublisher()
    }

    private func startObservingValues() -> AnyPublisher<Void, NetworkError> {
        attributionRepository
            .fetchAttributionValues()
            .handleEvents(receiveOutput: { [skAdNetworkService] conversionValue in
                skAdNetworkService.update(with: conversionValue)
            })
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
