//
//  StellarQRMetadataFactory.swift
//  StellarKit
//
//  Created by Chris Arriola on 5/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public class StellarQRMetadataFactory: CryptoAssetQRMetadataFactory {
    public typealias Metadata = StellarQRMetadata

    public typealias Account = StellarWalletAccount

    public init() {
    }

    public func create(from account: StellarWalletAccount) -> StellarQRMetadata? {
        return StellarQRMetadata(address: account.publicKey, amount: nil)
    }
}
