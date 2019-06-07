//
//  ERC20TransactionProposal.swift
//  ERC20Kit
//
//  Created by Jack on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import EthereumKit

public struct ERC20TransactionProposal<Token: ERC20Token> {
    
    public var aboveMinimumSpendable: Bool {
        return value.amount >= Token.smallestSpendableValue.amount
    }
    
    public let from: EthereumKit.EthereumAddress
    public let gasPrice: BigUInt
    public let gasLimit: BigUInt
    public let value: ERC20TokenValue<Token>
    
    public init(from: EthereumKit.EthereumAddress,
                gasPrice: BigUInt,
                gasLimit: BigUInt,
                value: ERC20TokenValue<Token>) {
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
    }
}

extension ERC20TransactionProposal: Equatable {
    public static func == (lhs: ERC20TransactionProposal, rhs: ERC20TransactionProposal) -> Bool {
        return lhs.from == rhs.from &&
            lhs.gasLimit == rhs.gasLimit
            && lhs.gasPrice == rhs.gasPrice
            && lhs.value.value == rhs.value.value
    }
}
