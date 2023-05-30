// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import ToolKit

struct OrderPairResponse: RawRepresentable {

    typealias RawValue = String

    enum OrderPairDecodingError: Error {
        case decodingError
    }

    let sourceCurrencyType: CurrencyType
    let destinationCurrencyType: CurrencyType

    var rawValue: String {
        "\(sourceCurrencyType.code)-\(destinationCurrencyType.code)"
    }

    init(sourceCurrencyType: CurrencyType, destinationCurrencyType: CurrencyType) {
        self.sourceCurrencyType = sourceCurrencyType
        self.destinationCurrencyType = destinationCurrencyType
    }

    init?(rawValue: String) {
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

    init(string: String, service: EnabledCurrenciesServiceAPI = resolve()) throws {
        var components: [String] = []
        for value in ["-", "_"] where string.contains(value) {
            components = string.components(separatedBy: value)
            break
        }

        guard let source = components.first else {
            throw OrderPairDecodingError.decodingError
        }
        guard let destination = components.last else {
            throw OrderPairDecodingError.decodingError
        }
        let sourceType = try CurrencyType(code: source, service: service)
        let destinationType = try CurrencyType(code: destination, service: service)

        self.init(
            sourceCurrencyType: sourceType,
            destinationCurrencyType: destinationType
        )
    }
}

extension OrderPair {

    init(response: OrderPairResponse) {
        self.init(
            sourceCurrencyType: response.sourceCurrencyType,
            destinationCurrencyType: response.destinationCurrencyType
        )
    }
}
