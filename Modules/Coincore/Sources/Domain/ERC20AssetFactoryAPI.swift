// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public protocol ERC20AssetFactoryAPI {
    func erc20Asset(
        network: EVMNetwork,
        erc20Token: AssetModel
    ) -> CryptoAsset
}
