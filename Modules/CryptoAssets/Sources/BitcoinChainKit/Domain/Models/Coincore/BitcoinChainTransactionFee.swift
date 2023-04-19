// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

public struct BitcoinChainTransactionFee<Token: BitcoinChainToken>: TransactionFee, Decodable {
    public static var cryptoType: HasPathComponent {
        Token.coin.cryptoCurrency
    }

    public static var `default`: BitcoinChainTransactionFee<Token> {
        BitcoinChainTransactionFee<Token>(
            regular: 5, priority: 11
        )
    }

    public let regular: CryptoValue
    public let priority: CryptoValue

    enum CodingKeys: String, CodingKey {
        case regular
        case priority
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let regularFee = try values.decode(Int.self, forKey: .regular)
        let priorityFee = try values.decode(Int.self, forKey: .priority)
        self.init(regular: regularFee, priority: priorityFee)
    }

    init(regular: Int, priority: Int) {
        self.regular = CryptoValue.create(
            minor: regular,
            currency: Token.coin.cryptoCurrency
        )
        self.priority = CryptoValue.create(
            minor: priority,
            currency: Token.coin.cryptoCurrency
        )
    }
}
