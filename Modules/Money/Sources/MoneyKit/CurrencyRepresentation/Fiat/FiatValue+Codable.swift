// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

extension FiatValue: Codable {

    public enum MoneyValueCodingError: Error {
        case invalidMinorValue
        case invalidFiatCurrency
    }

    enum CodingKeys: String, CodingKey {
        case value, amount
        case currency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let currencyCode = try container.decode(String.self, forKey: .currency)
        guard let currency = FiatCurrency(code: currencyCode) else {
            throw MoneyValueCodingError.invalidFiatCurrency
        }

        do {
            let storedAmount = try container.decode(BigInt.self, forKey: .amount)
            self = Self(storeAmount: storedAmount, currency: currency)
        } catch {
            let valueInMinors = try container.decodeIfPresent(String.self, forKey: .value) ?? container.decode(String.self, forKey: .amount)
            let value = FiatValue.create(minor: valueInMinors, currency: currency)
            guard let moneyValue = value else {
                throw MoneyValueCodingError.invalidMinorValue
            }
            self = moneyValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minorString, forKey: .value)
        try container.encode(storeAmount, forKey: .amount)
        try container.encode(code, forKey: .currency)
    }
}
