// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// MARK: - PriceResponse

enum PriceResponse {
    enum IndexMulti {}
    enum Symbols {}
}

extension PriceResponse {

    /// Model for a quoted price by the Service-Price endpoint in given base currency.
    struct Item: Decodable, Equatable {
        let price: Double?
        let timestamp: Date
        let volume24h: Double?
        let marketCap: Double?
    }
}

// MARK: - IndexMulti

extension PriceResponse.IndexMulti {
    struct Response: Decodable, Equatable {
        let entries: [String: PriceResponse.Item?]

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.entries = try container.decode([String: PriceResponse.Item?].self)
        }
    }
}

// MARK: - Symbols

extension PriceResponse.Symbols {
    struct Response: Decodable, Equatable {
        struct Item: Decodable, Equatable {
            let code: String
        }

        enum CodingKeys: String, CodingKey {
            case base = "Base"
            case quote = "Quote"
        }

        let base: [String: Item]
        let quote: [String: Item]
    }
}
