// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import SwiftUI

extension CurrencyType {

    public var image: Image {
        switch self {
        case .crypto(let currency):
            return currency.image
        case .fiat(let currency):
            return currency.image
        }
    }

    public var logoResource: ImageResource {
        switch self {
        case .crypto(let currency):
            return currency.logoResource
        case .fiat(let currency):
            return currency.logoResource
        }
    }

    public var brandColor: Color {
        Color(brandUIColor)
    }

    public var brandUIColor: UIColor {
        switch self {
        case .crypto(let currency):
            return currency.brandUIColor
        case .fiat(let currency):
            return currency.brandColor
        }
    }
}
