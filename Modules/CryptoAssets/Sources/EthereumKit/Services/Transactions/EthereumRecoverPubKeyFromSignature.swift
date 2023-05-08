// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import WalletCore

public enum EthRecoverKeyError: Error {
    case unableToRecover
}

public func recoverPubKey(from signature: Data, message: Data) throws -> Data {
    let pubkey = WalletCore.PublicKey.recover(signature: signature, message: message)
    guard let data = pubkey?.data else {
        throw EthRecoverKeyError.unableToRecover
    }
    return data
}
