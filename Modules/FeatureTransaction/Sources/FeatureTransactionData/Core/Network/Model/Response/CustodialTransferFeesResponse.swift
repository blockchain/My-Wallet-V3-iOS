// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

enum WithrdrawalFeesError: Error {
    case unableToCalculateMoneyValue
}

struct CustodialTransferFeesResponse: Decodable {
    private struct Value: Decodable {
        let symbol: String
        let minorValue: String
    }

    let minAmounts: [CurrencyType: MoneyValue]
    let fees: [CurrencyType: MoneyValue]

    enum CodingKeys: CodingKey {
        case minAmounts
        case fees
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let minAmounts = try container.decode([Value].self, forKey: .minAmounts)
        let fees = try container.decode([Value].self, forKey: .fees)
        self.minAmounts = minAmounts.reduce(into: [CurrencyType: MoneyValue]()) { result, value in
            guard let currency = try? CurrencyType(code: value.symbol) else {
                return
            }
            guard let amount = BigInt(value.minorValue) else {
                return
            }
            result[currency] = MoneyValue.create(minor: amount, currency: currency)
        }
        self.fees = fees.reduce(into: [CurrencyType: MoneyValue]()) { result, value in
            guard let currency = try? CurrencyType(code: value.symbol) else {
                return
            }
            guard let amount = BigInt(value.minorValue) else {
                return
            }
            result[currency] = MoneyValue.create(minor: amount, currency: currency)
        }
    }
}

struct WithdrawalFeesResponse: Decodable {
    let minAmount: ExchangedAmountResponse
    let sendAmount: ExchangedAmountResponse
    let totalFees: ExchangedAmountResponse

    struct ExchangedAmountResponse: Decodable {
        let amount: AmountResponse
        let fiat: AmountResponse?
    }
}

extension WithdrawalFeesResponse {
    struct AmountResponse: Decodable {
        let currency: CurrencyType
        let value: MoneyValue

        enum CodingKeys: CodingKey {
            case currency
            case value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let currencyString = try container.decode(String.self, forKey: .currency)
            let moneyValueMinor = try container.decode(String.self, forKey: .value)
            currency = try CurrencyType(code: currencyString)
            if let amount = BigInt(moneyValueMinor) {
                value = MoneyValue.create(minor: amount, currency: currency)
            } else {
                throw WithrdrawalFeesError.unableToCalculateMoneyValue
            }
        }
    }
}

extension WithdrawalFees {
    init(response: WithdrawalFeesResponse) {
        self.init(
            minAmount: .init(response: response.minAmount),
            sendAmount: .init(response: response.sendAmount),
            totalFees: .init(response: response.totalFees)
        )
    }
}

extension WithdrawalFees.ExchangedAmount {
    init(response: WithdrawalFeesResponse.ExchangedAmountResponse) {
        self.init(
            amount: .init(response: response.amount),
            fiat: response.fiat.map(WithdrawalFees.Amount.init(response:))
        )
    }
}

extension WithdrawalFees.Amount {
    init(response: WithdrawalFeesResponse.AmountResponse) {
        self.init(
            currency: response.currency,
            value: response.value
        )
    }
}
