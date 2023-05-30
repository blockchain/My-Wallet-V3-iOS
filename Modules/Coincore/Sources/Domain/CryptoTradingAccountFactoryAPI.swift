// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public protocol CryptoTradingAccountFactoryAPI {
    func cryptoTradingAccount(
        cryptoCurrency: CryptoCurrency,
        addressFactory: ExternalAssetAddressFactory
    ) -> CryptoAccount
}
