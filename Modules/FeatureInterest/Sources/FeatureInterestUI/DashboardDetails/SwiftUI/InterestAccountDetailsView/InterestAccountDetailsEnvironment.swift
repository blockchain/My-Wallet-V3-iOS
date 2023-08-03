// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import FeatureInterestDomain
import MoneyKit
import PlatformKit

struct InterestAccountDetailsEnvironment {
    let fiatCurrencyService: FiatCurrencyServiceAPI
    let blockchainAccountRepository: BlockchainAccountRepositoryAPI
    let priceService: PriceServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

extension InterestAccountDetailsEnvironment {

    static let `default`: InterestAccountDetailsEnvironment = .init(
        fiatCurrencyService: resolve(),
        blockchainAccountRepository: resolve(),
        priceService: resolve(),
        mainQueue: .main
    )
}
