// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import Foundation
import Web3Wallet

public enum WalletConnectUserEvent {
    case signMessage(SingleAccount, TransactionTarget)
    case signTransaction(SingleAccount, TransactionTarget)
    case sendTransaction(SingleAccount, TransactionTarget)
    case authRequest(WalletConnectAuthRequest)
    case failure(message: String, metadata: AppMetadata?)
    case authFailure(error: Error, domain: String)
}
