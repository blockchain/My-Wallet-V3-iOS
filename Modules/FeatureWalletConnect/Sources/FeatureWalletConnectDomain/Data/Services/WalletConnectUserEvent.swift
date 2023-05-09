// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import Web3Wallet

public enum WalletConnectUserEvent {
    case signMessage(SingleAccount, TransactionTarget)
    case signTransaction(SingleAccount, TransactionTarget)
    case sendTransaction(SingleAccount, TransactionTarget)
    case failure(message: String, metadata: AppMetadata?)
}
