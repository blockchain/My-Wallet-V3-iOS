// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct CurrencyPair: Hashable, Codable, CustomStringConvertible, Identifiable {

    public var string: String { "\(base.code)-\(quote.code)" }
    public var id: String { string }

    public let base: CurrencyType
    public let quote: CurrencyType

    public init(_ string: String) throws {
        let string = string.splitIfNotEmpty(separator: "-")
        guard string.count == 2 else { throw "Invalid currency" }
        self.base = try CurrencyType(code: string.at(0).or(throw: "No base currency").string)
        self.quote = try CurrencyType(code: string.at(1).or(throw: "No quote currency").string)
    }

    public init(base: some Currency, quote: some Currency) {
        self.base = base.currencyType
        self.quote = quote.currencyType
    }

    public init(from decoder: Decoder) throws {
        try self.init(decoder.singleValueContainer().decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(base.code)-\(quote.code)")
    }

    public var description: String { string }
}
