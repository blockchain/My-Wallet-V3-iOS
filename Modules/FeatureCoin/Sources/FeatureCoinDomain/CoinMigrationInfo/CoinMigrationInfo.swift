// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct CoinMigrationInfo: Decodable, Equatable {
    enum CoingMigrationInfoCreationError: Error {
        case invalidCryptoCurrency
    }

    enum CodingKeys: CodingKey {
        case old
        case new
    }

    public let old: CryptoCurrency
    public let new: CryptoCurrency

    public init(old: CryptoCurrency, new: CryptoCurrency) {
        self.old = old
        self.new = new
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let old = try container.decode(String.self, forKey: .old)
        let new = try container.decode(String.self, forKey: .new)
        if let old = CryptoCurrency(code: old), let new = CryptoCurrency(code: new) {
            self.old = old
            self.new = new
        } else {
            throw CoingMigrationInfoCreationError.invalidCryptoCurrency
        }
    }
}
