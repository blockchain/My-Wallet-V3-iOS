// Copyright © Blockchain Luxembourg S.A. All rights reserved.

enum FileName: String {
    case localCoin = "local-currencies-coin.json"
    case localCustodial = "local-currencies-custodial.json"
    case localEthereumERC20 = "local-currencies-ethereum-erc20.json"
    case localOtherERC20 = "local-currencies-other-erc20.json"
    case localNetworkConfig = "local-network-config.json"

    case remoteCoin = "remote-currencies-coin.json"
    case remoteCustodial = "remote-currencies-custodial.json"
    case remoteEthereumERC20 = "remote-currencies-erc20.json"
    case remoteOtherERC20 = "remote-currencies-other-erc20.json"
    case remoteNetworkConfig = "remote-network-config.json"

    var origin: FileOrigin {
        switch self {
        case .localCoin, .localCustodial, .localEthereumERC20, .localOtherERC20, .localNetworkConfig:
            return .bundle
        case .remoteCoin, .remoteCustodial, .remoteEthereumERC20, .remoteOtherERC20, .remoteNetworkConfig:
            return .documentsDirectory
        }
    }
}
