// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public protocol EVMAssetFactoryAPI {
    func evmAsset(
        network: EVMNetwork
    ) -> CryptoAsset
}
