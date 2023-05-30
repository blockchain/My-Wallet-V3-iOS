// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct CurrencyPair: Hashable, Codable, CustomStringConvertible, Identifiable {

    public var string: String { "\(base.code)-\(quote.code)" }
    public var id: String { string }

    public let base: CurrencyType
    public let quote: CurrencyType

    public init(base: some Currency, quote: some Currency) {
        self.base = base.currencyType
        self.quote = quote.currencyType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self).splitIfNotEmpty(separator: "-")
        let (base, quote) = try (
            string.first.or(throw: DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Expected X-Y"))).string,
            string.last.or(throw: DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Expected X-Y"))).string
        )
        self.base = try CurrencyType(code: base)
        self.quote = try CurrencyType(code: quote)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(base.code)-\(quote.code)")
    }

    public var description: String { string }
}
