// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureWithdrawalLocksDomain
import Foundation
import PlatformKit

final class FiatCurrencyCodeProviderAdapter: FiatCurrencyCodeProviderAPI {

    lazy var defaultFiatCurrencyCode: AnyPublisher<String, Never> = fiatCurrencyPublisher.displayCurrencyPublisher
        .map(\.code)
        .eraseToAnyPublisher()

    private let fiatCurrencyPublisher: FiatCurrencyServiceAPI

    init(fiatCurrencyPublisher: FiatCurrencyServiceAPI = resolve()) {
        self.fiatCurrencyPublisher = fiatCurrencyPublisher
    }
}
