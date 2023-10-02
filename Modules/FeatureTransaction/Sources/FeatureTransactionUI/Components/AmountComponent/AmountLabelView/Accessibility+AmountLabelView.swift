// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

extension Accessibility.Identifier {
    enum AmountLabelView {
        private static let prefix = "AmountLabelView."
        static let fiatCurrencyCodeLabel = "\(prefix)currencyCodeLabel.fiat"
        static let cryptoCurrencyCodeLabel = "\(prefix)currencyCodeLabel.crypto"
        static let amountLabel = "\(prefix)amountLabel.%@"
    }
}
