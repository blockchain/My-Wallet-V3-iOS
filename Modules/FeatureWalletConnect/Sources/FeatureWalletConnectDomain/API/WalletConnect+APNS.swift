// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Web3Wallet

/// Registers the underlying EchoClient for push notifications for WalletConnect v2
public func registerWalletConnectEchoClient(deviceToken: Data) async throws {
    try await Web3Wallet.instance.registerEchoClient(deviceToken: deviceToken)
}
