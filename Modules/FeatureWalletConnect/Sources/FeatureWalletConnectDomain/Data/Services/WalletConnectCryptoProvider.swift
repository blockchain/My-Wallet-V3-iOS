// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CryptoSwift
import EthereumKit
import Foundation
import ToolKit
import Web3Wallet

final class WalletConnectCryptoProvider: CryptoProvider {
    func recoverPubKey(signature: EthereumSignature, message: Data) throws -> Data {
        try EthereumKit.recoverPubKey(from: signature.serialized, message: message)
    }

    func keccak256(_ data: Data) -> Data {
        let digest = SHA3(variant: .keccak256)
        let hash = digest.calculate(for: [UInt8](data))
        return Data(hash)
    }
}
