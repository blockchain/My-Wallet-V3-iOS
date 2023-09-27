// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureExternalTradingMigrationDomain
import Foundation
import NetworkKit

public struct ExternalTradingMigrationClient: ExternalTradingMigrationClientAPI {
    // MARK: - Private Properties

    private enum Path {
        static let externalBrokerageMigration = ["user", "migrate", "external_brokerage"]
    }

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchMigrationInfo() -> AnyPublisher<ExternalTradingMigrationInfo, NetworkError> {
        let request = requestBuilder.get(
            path: Path.externalBrokerageMigration,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}
