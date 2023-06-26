// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Errors
import Foundation
import ToolKit

public class AttributionService: AttributionServiceAPI {

    private var app: AppProtocol
    private var skAdNetworkService: SkAdNetworkServiceAPI
    private var attributionRepository: AttributionRepositoryAPI

    public init(
        app: AppProtocol,
        skAdNetworkService: SkAdNetworkServiceAPI,
        attributionRepository: AttributionRepositoryAPI
    ) {
        self.app = app
        self.skAdNetworkService = skAdNetworkService
        self.attributionRepository = attributionRepository
    }

    public func registerForAttribution() {
        skAdNetworkService.firstTimeRegister()
    }

    public func startUpdatingConversionValues() -> AnyPublisher<Void, NetworkError> {
        app.remoteConfiguration.publisher(for: "ios_ff_skAdNetwork_attribution")
            .tryMap { result in try result.decode(Bool.self) }
            .replaceError(with: true)
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
