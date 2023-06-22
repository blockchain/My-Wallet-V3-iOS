// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import MoneyKit
import PlatformKit

final class ERC20AssetFactory: ERC20AssetFactoryAPI {
    func erc20Asset(
        network: EVMNetwork,
        erc20Token: AssetModel
    ) -> CryptoAsset {
        ERC20Asset(
            erc20Token: erc20Token,
            network: network,
            walletAccountRepository: DIKit.resolve(),
            errorRecorder: DIKit.resolve(),
            exchangeAccountProvider: DIKit.resolve(),
            kycTiersService: DIKit.resolve(),
            enabledCurrenciesService: DIKit.resolve()
        )
    }
}
