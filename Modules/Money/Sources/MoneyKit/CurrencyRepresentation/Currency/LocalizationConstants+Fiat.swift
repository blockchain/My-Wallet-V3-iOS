// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants {

    enum Fiat {
        static let usd = NSLocalizedString(
            "US Dollar",
            comment: "Name of the USD (US Dollar) fiat currency."
        )
        static let gbp = NSLocalizedString(
            "British Pound",
            comment: "Name of the GBP (British Pound) fiat currency."
        )
        static let eur = NSLocalizedString(
            "Euro",
            comment: "Name of the EUR (Euro) fiat currency."
        )
        static let ars = NSLocalizedString(
            "Argentinian Peso",
            comment: "Name of the ARS (Argentinian Peso) fiat currency."
        )
        static let brl = NSLocalizedString(
            "Brazilian Real",
            comment: "Name of the BRL (Brazilian Real) fiat currency."
        )
    }
}
