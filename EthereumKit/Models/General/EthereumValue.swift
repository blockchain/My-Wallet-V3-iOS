//
//  EthereumValue.swift
//  EthereumKit
//
//  Created by Jack on 19/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

enum EthereumValueError: Error {
    case invalidCryptoValue
}

public struct EthereumValue: Crypto {
    public var value: CryptoValue {
        return crypto.value
    }
    
    private let crypto: Crypto
    
    public init(crypto: Crypto) throws {
        guard crypto.currencyType == .ethereum else {
            throw EthereumValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }
}
