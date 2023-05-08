// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import Web3Wallet

private var metadata: AppMetadata {
    AppMetadata(
        name: "Blockchain.com",
        description: "",
        url: "https://blockchain.com",
        icons: ["https://www.blockchain.com/static/apple-touch-icon.png"]
    )
}

public func configureWalletConnectV2(projectId: String) {
    Networking.configure(
        projectId: projectId,
        socketFactory: SocketFactory()
    )
    Web3Wallet.configure(
        metadata: metadata,
        crypto: WalletConnectCryptoProvider()
    )
}
