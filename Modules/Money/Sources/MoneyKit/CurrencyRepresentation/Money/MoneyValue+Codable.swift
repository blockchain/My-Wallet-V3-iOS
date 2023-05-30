// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

extension MoneyValue: Codable {

    public enum MoneyValueCodingError: Error {
        case invalidMinorValue
    }

    enum CodingKeys: String, CodingKey {
        case value, amount
        case currency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let currencyCode = try container.decode(String.self, forKey: .currency)
        let currencyType = try CurrencyType(
            code: currencyCode,
            service: EnabledCurrenciesService.default
        )
        do {
            let storedAmount = try container.decode(BigInt.self, forKey: .amount)
            self = Self(storeAmount: storedAmount, currency: currencyType)
        } catch {
            let valueInMinors = try container.decodeIfPresent(String.self, forKey: .value) ?? container.decode(String.self, forKey: .amount)
            let value = MoneyValue.create(minor: valueInMinors, currency: currencyType)
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
