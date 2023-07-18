// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineSchedulers
import DIKit
import Foundation
import MoneyKit

struct PriceEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let priceService: PriceServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        priceService: PriceServiceAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.priceService = priceService
    }
}
