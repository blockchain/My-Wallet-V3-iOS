// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct TradingPair: RawRepresentable, Equatable, Decodable {

    public typealias RawValue = String

    enum OrderPairDecodingError: Error {
        case decodingError
    }

    public let sourceCurrencyType: CurrencyType
    public let destinationCurrencyType: CurrencyType

    public var rawValue: String {
        "\(sourceCurrencyType.code)-\(destinationCurrencyType.code)"
    }

    public init(sourceCurrencyType: CurrencyType, destinationCurrencyType: CurrencyType) {
        self.sourceCurrencyType = sourceCurrencyType
        self.destinationCurrencyType = destinationCurrencyType
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self).splitIfNotEmpty(separator: "-")
        let (source, destination) = try (
            string.first.or(throw: DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Expected X-Y"))).string,
            string.last.or(throw: DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Expected X-Y"))).string
        )
        self.sourceCurrencyType = try CurrencyType(code: source)
        self.destinationCurrencyType = try CurrencyType(code: destination)
    }

    public init?(rawValue: String) {
        var components: [String] = []
        for value in ["-", "_"] where rawValue.contains(value) {
            components = rawValue.components(separatedBy: value)
            break
        }
        guard let source = components.first else { return nil }
        guard let destination = components.last else { return nil }
        do {
            let sourceType = try CurrencyType(code: source)
            let destionationType = try CurrencyType(code: destination)
            self.init(
                sourceCurrencyType: sourceType,
                destinationCurrencyType: destionationType
            )
        } catch {
            return nil
        }
    }
}
