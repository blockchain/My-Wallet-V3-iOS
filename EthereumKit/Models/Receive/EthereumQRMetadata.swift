//
//  EthereumQRMetadata.swift
//  EthereumKit
//
//  Created by Chris Arriola on 5/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import web3swift

public struct EthereumQRMetadata: CryptoAssetQRMetadata {
    public var address: String
    public var amount: String?
    public var absoluteString: String {
        // TODO: encode `amount`, too
        return EIP67Code(address: Address(address)).toString()
    }
    public static var scheme: String {
        return "ethereum"
    }

    public init(address: String, amount: String?) {
        self.address = address
        self.amount = amount
    }
}
