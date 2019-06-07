//
//  EthereumQRMetadataFactory.swift
//  EthereumKit
//
//  Created by Chris Arriola on 5/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public class EthereumQRMetadataFactory: CryptoAssetQRMetadataFactory {
    public typealias Metadata = EthereumQRMetadata

    public typealias Account = EthereumWalletAccount

    public init() {
    }

    public func create(from account: EthereumWalletAccount) -> EthereumQRMetadata? {
        return EthereumQRMetadata(address: account.publicKey, amount: nil)
    }
}
