// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import MetadataKit
import ToolKit

final class MetadataRepository: MetadataRepositoryAPI {

    // MARK: - Private properties

    private let client: MetadataClientAPI
    private var randomNumberGenerator = SystemRandomNumberGenerator()

    // MARK: - Setup

    init(client: MetadataClientAPI) {
        self.client = client
    }

    // MARK: - MetadataRepositoryAPI

    func fetch(
        at address: String
    ) -> AnyPublisher<MetadataPayload, NetworkError> {
        client.get(address: address)
            .retry(
                max: 5,
                delay: .exponential(using: &randomNumberGenerator),
                if: \.code == 502 || \.code == 504,
                scheduler: DispatchQueue.main
            )
            .map(MetadataPayload.init(from:))
            .eraseToAnyPublisher()
    }

    func put(
        at address: String,
        with body: MetadataBody
    ) -> AnyPublisher<Void, NetworkError> {
        client.put(payload: body, at: address)
    }
}
