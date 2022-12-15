// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct PaymentsDepositTermsRequest: Encodable {

    public let amount: MoneyValueRequest
    public let paymentMethodId: String
    public let product = "WALLET"
    public let purpose = "DEPOSIT"

    public init(
        amount: MoneyValueRequest,
        paymentMethodId: String
    ) {
        self.amount = amount
        self.paymentMethodId = paymentMethodId
    }
}

extension PaymentsDepositTermsRequest {
    public struct MoneyValueRequest: Encodable {

        enum CodingKeys: String, CodingKey {
            case value
            case symbol
        }

        let moneyValue: MoneyValue

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(moneyValue.minorString, forKey: .value)
            try container.encode(moneyValue.code, forKey: .symbol)
        }
    }
}
