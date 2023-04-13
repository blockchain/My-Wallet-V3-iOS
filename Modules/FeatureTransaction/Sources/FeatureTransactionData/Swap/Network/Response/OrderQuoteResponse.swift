// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import MoneyKit
import PlatformKit

struct OrderQuoteResponse: Decodable {

    struct OrderQuote: Decodable {
        let pair: OrderPairResponse
        let priceTiers: [OrderPriceTierResponse]

        enum CodingKeys: String, CodingKey {
            case pair = "currencyPair"
            case priceTiers
        }

        init(
            pair: OrderPairResponse,
            priceTiers: [OrderPriceTierResponse]
        ) {
            self.pair = pair
            self.priceTiers = priceTiers
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.priceTiers = try values.decode([OrderPriceTierResponse].self, forKey: .priceTiers)
            self.pair = try OrderPairResponse(string: values.decode(String.self, forKey: .pair))
        }
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case pair
        case product
        case expiresAt
        case createdAt
        case updatedAt
        case sampleDepositAddress
        case networkFee
        case staticFee
        case quote
    }

    let identifier: String
    let product: ProductResponse
    let pair: OrderPairResponse
    let quote: Self.OrderQuote

    /// `MoneyValue` in the `pair.destinationCurrencyType`
    let networkFee: MoneyValue
    let staticFee: MoneyValue
    let sampleDepositAddress: String
    let expiresAt: Date
    let createdAt: Date
    let updatedAt: Date

    init(
        identifier: String,
        product: ProductResponse = .brokerage,
        pair: OrderPairResponse,
        quote: Self.OrderQuote,
        networkFee: MoneyValue,
        staticFee: MoneyValue,
        sampleDepositAddress: String,
        expiresAt: Date,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.identifier = identifier
        self.product = product
        self.pair = pair
        self.quote = quote
        self.networkFee = networkFee
        self.staticFee = staticFee
        self.sampleDepositAddress = sampleDepositAddress
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let createdAt = try values.decode(String.self, forKey: .createdAt)
        let expiresAt = try values.decode(String.self, forKey: .expiresAt)
        let updatedAt = try values.decode(String.self, forKey: .updatedAt)

        self.identifier = try values.decode(String.self, forKey: .identifier)
        self.pair = try OrderPairResponse(string: values.decode(String.self, forKey: .pair))
        self.product = try values.decode(ProductResponse.self, forKey: .product)
        self.createdAt = try OrderQuoteResponse.date(
            from: createdAt,
            container: values
        )
        self.expiresAt = try OrderQuoteResponse.date(
            from: expiresAt,
            container: values
        )
        self.updatedAt = try OrderQuoteResponse.date(
            from: updatedAt,
            container: values
        )
        self.sampleDepositAddress = try values.decode(String.self, forKey: .sampleDepositAddress)
        let networkFeeValue = try values.decode(String.self, forKey: .networkFee)
        let staticFeeValue = try values.decode(String.self, forKey: .staticFee)
        let zeroDestination: MoneyValue = .zero(currency: pair.destinationCurrencyType)
        self.networkFee = MoneyValue.create(minor: networkFeeValue, currency: pair.destinationCurrencyType) ?? zeroDestination
        self.staticFee = MoneyValue.create(minor: staticFeeValue, currency: pair.destinationCurrencyType) ?? zeroDestination
        self.quote = try values.decode(OrderQuoteResponse.OrderQuote.self, forKey: .quote)
    }
}

extension OrderQuoteResponse {

    fileprivate static func date(
        from stringValue: String,
        container: KeyedDecodingContainer<CodingKeys>
    ) throws -> Date {
        let formatter = DateFormatter.sessionDateFormat
        if let value = formatter.date(from: stringValue) {
            return value
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
    }
}

extension OrderQuotePayload {

    init(response: OrderQuoteResponse) {
        self.init(
            identifier: response.identifier,
            product: .init(response: response.product),
            pair: .init(response: response.pair),
            quote: .init(response: response.quote),
            networkFee: response.networkFee,
            staticFee: response.staticFee,
            sampleDepositAddress: response.sampleDepositAddress,
            expiresAt: response.expiresAt,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt
        )
    }
}

extension OrderQuote {

    init(response: OrderQuoteResponse.OrderQuote) {
        self.init(
            pair: .init(response: response.pair),
            priceTiers: response.priceTiers.map(OrderPriceTier.init)
        )
    }
}
