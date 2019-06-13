//
//  EthereumAddress.swift
//  EthereumKit
//
//  Created by Jack on 20/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift

typealias EthereumAddressProtocols = Hashable & ExpressibleByStringLiteral & RawRepresentable

public struct EthereumAddress: EthereumAddressProtocols {
    
    public let rawValue: String
    
    public init(stringLiteral value: String) {
        self.rawValue = Address.toChecksumAddress(value)!
    }
    
    public init?(rawValue value: String) {
        guard let eip55Address = Address.toChecksumAddress(value) else {
            return nil
        }
        self.rawValue = eip55Address
    }
    
    public var isValid: Bool {
        return web3swiftAddress.isValid
    }
}

extension EthereumAddress {
    var web3swiftAddress: web3swift.Address {
        return web3swift.Address(rawValue)
    }
}

public struct EthereumAccountAddress: EthereumAddressProtocols {
    
    public var ethereumAddress: EthereumAddress {
        return EthereumAddress(rawValue: rawValue)!
    }
    
    public let rawValue: String
    
    public init(stringLiteral value: String) {
        self.rawValue = Address.toChecksumAddress(value)!
    }
    
    public init?(rawValue value: String) {
        let accountAddress = web3swift.Address(value, type: .normal)
        guard accountAddress.isValid, let eip55Address = Address.toChecksumAddress(value) else {
            return nil
        }
        self.rawValue = eip55Address
    }
}

public struct EthereumContractAddress: EthereumAddressProtocols {
    
    public var ethereumAddress: EthereumAddress {
        return EthereumAddress(rawValue: rawValue)!
    }
    
    public let rawValue: String
    
    public init(stringLiteral value: String) {
        self.rawValue = Address.toChecksumAddress(value)!
    }
    
    public init?(rawValue value: String) {
        guard let eip55Address = Address.toChecksumAddress(value) else {
            return nil
        }
        self.rawValue = eip55Address
    }
}
