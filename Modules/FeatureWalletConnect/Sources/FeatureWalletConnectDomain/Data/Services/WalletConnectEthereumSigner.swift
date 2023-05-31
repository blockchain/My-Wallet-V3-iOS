// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import Foundation
import Web3Wallet

struct WalletConnectEthereumSigner: EthereumSigner {
    func sign(message: Data, with key: Data) throws -> EthereumSignature {
        let signature = try EthereumKit.ethereumPersonalSign(message: message, privateKey: key)
        return EthereumSignature(serialized: signature)
    }
}

struct EthereumSignerFactory: SignerFactory {
    func createEthereumSigner() -> EthereumSigner {
        WalletConnectEthereumSigner()
    }
}
