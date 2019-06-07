//
//  EthereumPrivateKey.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct EthereumPrivateKey: Equatable {
    public let mnemonic: String
    public let password: String
    public let data: Data
    
    init(mnemonic: String, password: String, data: Data) {
        self.mnemonic = mnemonic
        self.password = password
        self.data = data
    }
}

extension EthereumPrivateKey {
    public var base58Encoded: Data? {
        return data.string.base58DecodedData
    }
    
    public var base58EncodedString: String? {
        return data.string.base58EncodedString
    }
}
