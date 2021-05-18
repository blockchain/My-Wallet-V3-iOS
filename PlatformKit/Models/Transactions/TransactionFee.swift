//
//  TransactionFee.swift
//  PlatformKit
//
//  Created by AlexM on 3/1/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import Foundation

public struct TransactionFeeLimits: Decodable {
    public let min: Int
    public let max: Int
    
    public init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }
}

public protocol HasPathComponent {
    var pathComponent: String { get }
}

extension CryptoCurrency: HasPathComponent {
    public var pathComponent: String {
        code.lowercased()
    }
}

public protocol TransactionFee {
    static var cryptoType: HasPathComponent { get }
    static var contractAddress: String? { get }
    static var `default`: Self { get }
    static var defaultLimits: TransactionFeeLimits { get }
    
    var limits: TransactionFeeLimits { get }
    var regular: CryptoValue { get }
    var priority: CryptoValue { get }
}

public extension TransactionFee {
    static var contractAddress: String? { nil }
}
