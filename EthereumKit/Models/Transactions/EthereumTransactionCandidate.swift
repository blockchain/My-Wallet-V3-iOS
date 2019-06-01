//
//  EthereumTransactionCandidate.swift
//  EthereumKit
//
//  Created by Jack on 26/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import BigInt

public struct EthereumTransactionCandidate {
    public let to: EthereumAddress
    public let gasPrice: BigUInt
    public let gasLimit: BigUInt
    public let value: BigUInt
    public let data: Data?
    
    public init(to: EthereumAddress,
                gasPrice: BigUInt,
                gasLimit: BigUInt,
                value: BigUInt,
                data: Data?) {
        self.to = to
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
        self.data = data
    }
}

extension EthereumTransactionCandidate: Equatable {
    public static func == (lhs: EthereumTransactionCandidate, rhs: EthereumTransactionCandidate) -> Bool {
        return lhs.gasLimit == rhs.gasLimit
            && lhs.gasPrice == rhs.gasPrice
            && lhs.to == rhs.to
            && lhs.value == rhs.value
            && lhs.data == rhs.data
    }
}
