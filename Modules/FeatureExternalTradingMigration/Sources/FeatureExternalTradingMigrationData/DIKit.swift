// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureExternalTradingMigrationDomain
import Foundation
import NetworkKit

extension DependencyContainer {

    // MARK: - FeatureExternalTradingMigration Module

    public static var featureExternalTradingMigrationData = module {
        factory {
            ExternalTradingMigrationClient(
                networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
            )
            as ExternalTradingMigrationClientAPI
        }

        single { () -> ExternalTradingMigrationRepositoryAPI in
            ExternalTradingMigrationRepository(
                app: DIKit.resolve(),
                client: ExternalTradingMigrationClient(
                    networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
                )
            )
        }

        factory { () -> ExternalTradingMigrationServiceAPI in
            ExternalTradingMigrationService(
                app: DIKit.resolve(),
                repository: DIKit.resolve()
            )
        }
    }
}