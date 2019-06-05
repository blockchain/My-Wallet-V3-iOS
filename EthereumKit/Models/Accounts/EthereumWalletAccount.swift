//
//  EthereumWalletAccount.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct EthereumWalletAccount: WalletAccount, Codable {
    public let index: Int
    public let publicKey: String
    public var label: String?
    public var archived: Bool
    
    public init(index: Int,
                publicKey: String,
                label: String?,
                archived: Bool) {
        self.index = index
        self.publicKey = publicKey
        self.label = label
        self.archived = archived
    }
}

public struct LegacyEthereumWalletAccount: Codable {
    public let addr: String
    public let label: String
    
    public init(addr: String, label: String) {
        self.addr = addr
        self.label = label
    }
}
