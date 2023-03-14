// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import MoneyKit
import PlatformKit

struct TradeLimitsResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case currency
        case minOrder
        case maxOrder
        case maxPossibleOrder
        case daily
        case weekly
        case annual
    }

    struct LimitResponse: Decodable {
        let limit: String
        let available: String
        let used: String
    }

    let currency: FiatCurrency
    let minOrder: FiatValue
    let maxOrder: FiatValue
    let maxPossibleOrder: FiatValue
    let daily: TradeLimit?
    let weekly: TradeLimit?
    let annual: TradeLimit?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.currency = try values.decode(FiatCurrency.self, forKey: .currency)
        let zero: FiatValue = .zero(currency: currency)

        self.minOrder = try FiatValue.create(
            minor: values.decode(String.self, forKey: .minOrder),
            currency: currency
        ) ?? zero
        self.maxPossibleOrder = try FiatValue.create(
            minor: values.decode(String.self, forKey: .maxPossibleOrder),
            currency: currency
        ) ?? zero
        self.maxOrder = try FiatValue.create(
            minor: values.decode(String.self, forKey: .maxOrder),
            currency: currency
        ) ?? zero

        if let daily = try values.decodeIfPresent(LimitResponse.self, forKey: .daily) {
            self.daily = .init(fiatCurrency: currency, limit: daily)
        } else {
            self.daily = nil
        }
        if let weekly = try values.decodeIfPresent(LimitResponse.self, forKey: .weekly) {
            self.weekly = .init(fiatCurrency: currency, limit: weekly)
        } else {
            self.weekly = nil
        }
        if let annual = try values.decodeIfPresent(LimitResponse.self, forKey: .annual) {
            self.annual = .init(fiatCurrency: currency, limit: annual)
        } else {
            self.annual = nil
        }
    }
}

extension FeatureTransactionDomain.TradeLimits {

    init(response: TradeLimitsResponse) {
        self.init(
            currency: response.currency.currencyType,
            minOrder: response.minOrder.moneyValue,
            maxOrder: response.maxOrder.moneyValue,
            maxPossibleOrder: response.maxPossibleOrder.moneyValue,
            daily: response.daily,
            weekly: response.weekly,
            annual: response.annual
        )
    }
}

extension TradeLimit {

    fileprivate init(
        fiatCurrency: FiatCurrency,
        limit: TradeLimitsResponse.LimitResponse
    ) {
        self.init(
            limit: MoneyValue
                .create(
                    minor: limit.limit,
                    currency: fiatCurrency.currencyType
                ) ?? .zero(currency: fiatCurrency),
            available: MoneyValue
                .create(
                    minor: limit.available,
                    currency: fiatCurrency.currencyType
                ) ?? .zero(currency: fiatCurrency),
            used: MoneyValue
                .create(
                    minor: limit.used,
                    currency: fiatCurrency.currencyType
                ) ?? .zero(currency: fiatCurrency)
        )
    }
}
