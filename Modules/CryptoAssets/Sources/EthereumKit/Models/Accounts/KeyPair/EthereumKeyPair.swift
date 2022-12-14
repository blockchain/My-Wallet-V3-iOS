// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct EthereumKeyPair: Equatable {
    public let address: String
    public let publicKey: String
    public let privateKey: EthereumPrivateKey

    public init(address: String, publicKey: String, privateKey: EthereumPrivateKey) {
        self.address = address
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
}
