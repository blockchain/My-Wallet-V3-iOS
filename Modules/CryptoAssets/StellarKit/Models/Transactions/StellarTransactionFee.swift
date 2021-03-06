// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

public struct StellarTransactionFee: TransactionFee, Decodable {

    enum CodingKeys: String, CodingKey {
        case regular
        case priority
        case limits
    }

    public static var cryptoType: HasPathComponent = CryptoCurrency.stellar
    public static let `default` = StellarTransactionFee(
        limits: StellarTransactionFee.defaultLimits,
        regular: 100,
        priority: 10000
    )
    public static let defaultLimits = TransactionFeeLimits(min: 100, max: 10000)

    public var limits: TransactionFeeLimits
    public var regular: CryptoValue
    public var priority: CryptoValue

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let regularFee = try values.decode(Int.self, forKey: .regular)
        let priorityFee = try values.decode(Int.self, forKey: .priority)
        regular = CryptoValue(amount: BigInt(regularFee), currency: .stellar)
        priority = CryptoValue(amount: BigInt(priorityFee), currency: .stellar)
        limits = try values.decode(TransactionFeeLimits.self, forKey: .limits)
    }

    public init(limits: TransactionFeeLimits, regular: Int, priority: Int) {
        self.limits = limits
        self.regular = CryptoValue(amount: BigInt(regular), currency: .stellar)
        self.priority = CryptoValue(amount: BigInt(priority), currency: .stellar)
    }
}
