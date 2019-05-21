//
//  ERC20TokenValue.swift
//  ERC20Kit
//
//  Created by Jack on 19/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import web3swift
import PlatformKit
import EthereumKit

public enum ERC20TokenValueError: Error {
    case invalidCryptoValue
}

public struct ERC20TokenValue<Token: ERC20Token>: Crypto {
    public var value: CryptoValue {
        return crypto.value
    }
    
    private let crypto: Crypto
    
    public init(crypto: Crypto) throws {
        guard crypto.currencyType == Token.assetType else {
            throw ERC20TokenValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }
}
