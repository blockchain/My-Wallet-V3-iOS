//
//  EthereumTransactionFee.swift
//  EthereumKit
//
//  Created by Jack on 26/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import BigInt

public struct EthereumTransactionFee: TransactionFee, Decodable {
    public static var cryptoType: HasPathComponent = CryptoCurrency.ethereum
    public static let `default` = EthereumTransactionFee(
        limits: EthereumTransactionFee.defaultLimits,
        regular: 5,
        priority: 11,
        gasLimit: 21_000,
        gasLimitContract: 65_000
    )
    public static let defaultLimits = TransactionFeeLimits(min: 23, max: 23)
    
    public var limits: TransactionFeeLimits
    public var regular: CryptoValue
    public var priority: CryptoValue
    public var gasLimit: Int
    public var gasLimitContract: Int
    
    enum CodingKeys: String, CodingKey {
        case regular
        case priority
        case limits
        case gasLimit
        case gasLimitContract
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let regularFee = try values.decode(Int.self, forKey: .regular)
        let priorityFee = try values.decode(Int.self, forKey: .priority)
        guard let regularValue = CryptoValue.etherFromGwei(string: String(regularFee)) else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.regular],
                debugDescription: "Expected CryptoValue pair from \(regularFee)"
            )
            throw DecodingError.valueNotFound(Int.self, context)
        }
        guard let priorityValue = CryptoValue.etherFromGwei(string: String(priorityFee)) else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.priority],
                debugDescription: "Expected CryptoValue pair from \(priorityFee)"
            )
            throw DecodingError.valueNotFound(Int.self, context)
        }

        regular = regularValue
        priority = priorityValue
        limits = try values.decode(TransactionFeeLimits.self, forKey: .limits)
        gasLimit = try values.decode(Int.self, forKey: .gasLimit)
        gasLimitContract = try values.decode(Int.self, forKey: .gasLimitContract)
    }

    init(limits: TransactionFeeLimits, regular: Int, priority: Int, gasLimit: Int, gasLimitContract: Int) {
        self.limits = limits
        self.regular = CryptoValue.etherFromGwei(string: String(regular))!
        self.priority = CryptoValue.etherFromGwei(string: String(priority))!
        self.gasLimit = gasLimit
        self.gasLimitContract = gasLimitContract
    }
}

public extension EthereumTransactionFee {
    /// Fees must be provided in `gwei`.
    var priorityGweiValue: String {
        return priority.gwei
    }

    /// Fees must be provided in `gwei`.
    var regularGweiValue: String {
        return regular.gwei
    }
}

fileprivate extension CryptoValue {
    /// Fees must be provided in `gwei`.
    /// We don't want `CryptoValue` to handle conversions between anything other than
    /// minor to major values so, this extension is private.
    var gwei: String {
        let gweiValue = amount / BigInt(integerLiteral: 1_000_000_000)
        return gweiValue.description
    }
}
