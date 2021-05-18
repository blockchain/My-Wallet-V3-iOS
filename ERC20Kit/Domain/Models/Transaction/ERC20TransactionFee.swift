//
//  ERC20TransactionFee.swift
//  ERC20Kit
//
//  Created by Paulo on 31/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import PlatformKit

struct ERC20TransactionFee<Token: ERC20Token>: TransactionFee, Decodable {
    static var contractAddress: String? {
        Token.contractAddress.publicKey
    }
    static var cryptoType: HasPathComponent {
        EthereumTransactionFee.cryptoType
    }
    static var `default`: ERC20TransactionFee {
        ERC20TransactionFee(ethereumFee: .default)
    }
    static var defaultLimits: TransactionFeeLimits {
        EthereumTransactionFee.defaultLimits
    }
    var limits: TransactionFeeLimits {
        ethereumFee.limits
    }
    var regular: CryptoValue {
        ethereumFee.regular
    }
    var priority: CryptoValue {
        ethereumFee.priority
    }
    let ethereumFee: EthereumTransactionFee

    init(from decoder: Decoder) throws {
        ethereumFee = try EthereumTransactionFee(from: decoder)
    }

    init(ethereumFee: EthereumTransactionFee) {
        self.ethereumFee = ethereumFee
    }
}
