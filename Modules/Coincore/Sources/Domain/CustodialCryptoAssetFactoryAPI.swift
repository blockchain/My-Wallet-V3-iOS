// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public protocol CustodialCryptoAssetFactoryAPI {
    func custodialCryptoAsset(cryptoCurrency: CryptoCurrency) -> CryptoAsset
}
