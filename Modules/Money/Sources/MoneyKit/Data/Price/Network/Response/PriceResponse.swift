// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// MARK: - PriceResponse

public enum PriceResponse {
    public enum IndexMulti {}
    public enum IndexMultiSeries {}
    public enum Symbols {}
}

// MARK: - IndexMulti

extension PriceResponse.IndexMulti {
    public struct Response: Decodable, Equatable {
        let entries: [String: Price?]

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.entries = try container.decode([String: Price?].self)
        }
    }
}

extension PriceResponse.IndexMultiSeries {
    public typealias Response = [CurrencyPair: [Price]]
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

public struct CurrencyPairAndTime: Codable, Hashable, CustomStringConvertible {

    public let base: CurrencyType
    public let quote: CurrencyType
    public let time: Date?

    var currencyPair: CurrencyPair { CurrencyPair(base: base, quote: quote) }

    public init(base: String, quote: String, time: Date? = nil) throws {
        self.base = try CurrencyType(code: base)
        self.quote = try CurrencyType(code: quote)
        self.time = time.map { Date(timeIntervalSince1970: $0.timeIntervalSince1970.i.d) }
    }

    public init(base: some Currency, quote: some Currency, time: Date? = nil) {
        self.base = base.currencyType
        self.quote = quote.currencyType
        self.time = time.map { Date(timeIntervalSince1970: $0.timeIntervalSince1970.i.d) }
    }

    public var description: String {
        if let time {
            return "\(base.code)-\(quote.code)@\(time.timeIntervalSince1970.i)"
        } else {
            return "\(base.code)-\(quote.code)"
        }
    }
}

public struct Price: Decodable, Equatable {
    public let price: Double?
    public let timestamp: Date
    public let volume24h: Double?
    public let marketCap: Double?
}
