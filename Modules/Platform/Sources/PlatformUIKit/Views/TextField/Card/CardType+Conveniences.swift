// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCardPaymentDomain
import Localization
import PlatformKit

extension CardType {

    public var thumbnail: ImageResource? {
        switch self {
        case .visa:
            return .local(name: "logo-visa", bundle: .platformUIKit)
        case .mastercard:
            return .local(name: "logo-mastercard", bundle: .platformUIKit)
        case .amex:
            return .local(name: "logo-amex", bundle: .platformUIKit)
        case .diners:
            return .local(name: "logo-diners", bundle: .platformUIKit)
        case .discover:
            return .local(name: "logo-discover", bundle: .platformUIKit)
        case .jcb:
            return .local(name: "logo-jcb", bundle: .platformUIKit)
        case .unknown:
            return nil
        }
    }

    var parts: [Int] {
        switch self {
        case .visa, .mastercard, .jcb, .discover:
            return [4, 4, 4, 4]
        case .amex:
            return [4, 6, 5]
        case .diners:
            return [4, 6, 4]
        case .unknown:
            return [CardType.maxPossibleLength]
        }
    }
}
