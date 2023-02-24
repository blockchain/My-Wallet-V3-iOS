// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct CustodialTransferFee {
    let fee: [CurrencyType: MoneyValue]
    let minimumAmount: [CurrencyType: MoneyValue]

    public init(
        fee: [CurrencyType: MoneyValue],
        minimumAmount: [CurrencyType: MoneyValue]
    ) {
        self.fee = fee
        self.minimumAmount = minimumAmount
    }

    public subscript(fee currency: CurrencyType) -> MoneyValue {
        fee[currency] ?? .zero(currency: currency)
    }

    public subscript(minimumAmount currency: CurrencyType) -> MoneyValue {
        minimumAmount[currency] ?? .zero(currency: currency)
    }
}

// MARK: - Withdrawal Fees

public struct WithdrawalFees: Equatable {
    public let minAmount: ExchangedAmount
    public let sendAmount: ExchangedAmount
    public let totalFees: ExchangedAmount

    public init(
        minAmount: WithdrawalFees.ExchangedAmount,
        sendAmount: WithdrawalFees.ExchangedAmount,
        totalFees: WithdrawalFees.ExchangedAmount
    ) {
        self.minAmount = minAmount
        self.sendAmount = sendAmount
        self.totalFees = totalFees
    }

    public struct ExchangedAmount: Equatable {
        public let amount: Amount
        public let fiat: Amount?

        public init(
            amount: WithdrawalFees.Amount,
            fiat: WithdrawalFees.Amount?
        ) {
            self.amount = amount
            self.fiat = fiat
        }
    }

    public struct Amount: Equatable {
        public let currency: CurrencyType
        public let value: MoneyValue

        public init(
            currency: CurrencyType,
            value: MoneyValue
        ) {
            self.currency = currency
            self.value = value
        }
    }
}
