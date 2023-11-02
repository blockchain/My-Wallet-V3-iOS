// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import MoneyKit

extension AssetModel {
    func contractAddress(network: EVMNetwork) -> EthereumAddress? {
        kind.contractAddress(network: network)
    }
}

extension AssetModelType {
    fileprivate func contractAddress(network: EVMNetwork) -> EthereumAddress? {
        switch self {
        case .erc20(let contractAddress, _):
            EthereumAddress(address: contractAddress, network: network)
        case .coin, .fiat, .celoToken:
            nil
        }
    }
}
