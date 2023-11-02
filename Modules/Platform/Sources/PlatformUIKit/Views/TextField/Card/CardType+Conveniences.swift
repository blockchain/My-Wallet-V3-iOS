// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCardPaymentDomain
import Localization
import PlatformKit

extension CardType {

    public var thumbnail: ImageLocation? {
        switch self {
        case .visa:
            .local(name: "logo-visa", bundle: .platformUIKit)
        case .mastercard:
            .local(name: "logo-mastercard", bundle: .platformUIKit)
        case .amex:
            .local(name: "logo-amex", bundle: .platformUIKit)
        case .diners:
            .local(name: "logo-diners", bundle: .platformUIKit)
        case .discover:
            .local(name: "logo-discover", bundle: .platformUIKit)
        case .jcb:
            .local(name: "logo-jcb", bundle: .platformUIKit)
        case .unknown:
            nil
        }
    }

    var parts: [Int] {
        switch self {
        case .visa, .mastercard, .jcb, .discover:
            [4, 4, 4, 4]
        case .amex:
            [4, 6, 5]
        case .diners:
            [4, 6, 4]
        case .unknown:
            [CardType.maxPossibleLength]
        }
    }
}
