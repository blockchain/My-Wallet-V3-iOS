// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineSchedulers
import DIKit
import Foundation
import NetworkKit

extension DependencyContainer {

    // MARK: - MoneyKit Module

    public static var moneyDomainKit = module {

        factory { () -> PriceServiceAPI in
            PriceService(
                app: DIKit.resolve(),
                multiSeries: DIKit.resolve(),
                repository: DIKit.resolve(),
                currenciesService: DIKit.resolve()
            )
        }

        single {
            IndexMutiSeriesPriceService(
                app: DIKit.resolve(),
                logger: DIKit.resolve() as NetworkDebugLogger,
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                refreshInterval: .seconds(60),
                cancellingGracePeriod: .seconds(30)
            )
        }
    }
}
