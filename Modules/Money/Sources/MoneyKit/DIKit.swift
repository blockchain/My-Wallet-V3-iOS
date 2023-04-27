// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - MoneyKit Module

    public static var moneyDomainKit = module {

        factory { () -> PriceServiceAPI in
            PriceService(
                repository: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve()
            )
        }

        factory { () -> MarketCapServiceAPI in
            MarketCapService(
                priceRepository: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve()
            )
        }
    }
}
