// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

/// Filter option for simple buy
public enum SupportedPairsFilterOption: Hashable {

    /// Fetch all supported pairs
    case all

    /// Fetch all supported pairs
    case only(fiatCurrency: FiatCurrency)

    var fiatCurrency: FiatCurrency? {
        switch self {
        case .only(fiatCurrency: let currency):
            return currency
        case .all:
            return nil
        }
    }
}
