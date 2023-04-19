// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCardPaymentDomain
import MoneyKit
@testable import PlatformKit

extension APIClient {

    static func mockPaymentAccountResponse(for currency: FiatCurrency = .GBP) -> PaymentAccountResponse {
        let mockAgent = PaymentAccountResponse.Agent(
            account: "123456987",
            address: "4250 Executive Square, La Jolla, California, 92037",
            code: "LHVBEE22",
            country: "Estonia",
            name: "LHV",
            recipient: "Fred Wilson",
            routingNumber: "123456987"
        )
        return PaymentAccountResponse(
            id: "12-34-56-78",
            address: "4250 Executive Square, La Jolla, California, 92037",
            agent: mockAgent,
            currency: .fiat(currency),
            state: .pending
        )
    }

    static var paymentMethods: PaymentMethodsResponse {
        PaymentMethodsResponse(
            currency: "GBP",
            methods: [
                .init(
                    type: "BANK_TRANSFER",
                    limits: .init(min: "5000", max: "200000"),
                    subTypes: [],
                    currency: "GBP",
                    eligible: true,
                    visible: true,
                    mobilePayment: [.applePay],
                    capabilities: nil
                ),
                .init(
                    type: "CARD",
                    limits: .init(min: "5000", max: "500000"),
                    subTypes: [],
                    currency: "GBP",
                    eligible: true,
                    visible: true,
                    mobilePayment: [.applePay],
                    capabilities: nil
                )
            ]
        )
    }

    private static var cardList: [CardPayload] {
        [
            CardPayload(
                identifier: "a4e4c08d-b9e4-443d-b54e-47a3d2886dcf",
                partner: "EVERYPAY",
                address: nil,
                currency: "GBP",
                state: .active,
                card: nil,
                additionDate: "2020-04-07T23:23:26.761Z"
            )
        ]
    }

    static func mockQuote(
        for action: Order.Action,
        to cryptoCurrency: CryptoCurrency,
        amount: FiatValue
    ) -> QuoteResponse {
        QuoteResponse(
            quoteId: "00000000-0000-0000-0000-000000000000",
            quoteMarginPercent: 0.5,
            quoteCreatedAt: "2021-12-31T01:00:02.030000000Z",
            quoteExpiresAt: "2021-12-31T01:00:04.030000000Z",
            price: "5830206",
            networkFee: nil,
            staticFee: nil,
            feeDetails: .init(
                feeWithoutPromo: "10",
                fee: "10",
                feeFlags: []
            ),
            settlementDetails: .init(
                availability: .instant,
                reason: nil,
                ux: nil
            ),
            sampleDepositAddress: nil
        )
    }

    static func mockOrderCreation(order: OrderPayload.Request) -> OrderPayload.Response {
        .init(
            state: "PENDING_DEPOSIT",
            id: UUID().uuidString,
            inputCurrency: order.input.symbol,
            inputQuantity: order.input.amount,
            outputCurrency: order.output.symbol,
            outputQuantity: "100000",
            updatedAt: "2020-01-01T12:20:42.849Z",
            expiresAt: "2020-01-01T12:20:42.849Z",
            price: "0",
            fee: "0",
            recurringBuyId: nil,
            paymentType: "BANK",
            paymentError: nil,
            paymentMethodId: nil,
            side: order.action == .buy ? .buy : .sell,
            attributes: nil,
            ux: nil,
            processingErrorType: nil
        )
    }

    static var mockOrdersDetails: [OrderPayload.Response] {
        [
            OrderPayload.Response(
                state: OrderDetails.State.pendingDeposit.rawValue,
                id: "111111-aaaaaaaa-111111",
                inputCurrency: "GBP",
                inputQuantity: "10000",
                outputCurrency: "ETH",
                outputQuantity: "100000",
                updatedAt: "2020-01-01T12:20:42.849Z",
                expiresAt: "2020-01-01T12:20:42.849Z",
                price: "0",
                fee: "0",
                recurringBuyId: nil,
                paymentType: "BANK",
                paymentError: nil,
                paymentMethodId: nil,
                side: .buy,
                attributes: nil,
                ux: nil,
                processingErrorType: nil
            )
        ]
    }

    static func mockSupportedPairs(currency: FiatCurrency) -> SupportedPairsResponse {
        SupportedPairsResponse(
            pairs: [
                SupportedPairsResponse.Pair(
                    pair: "BTC-\(currency.code)",
                    buyMin: "1000",
                    buyMax: "100000"
                ),
                SupportedPairsResponse.Pair(
                    pair: "BTC-\(currency.code)",
                    buyMin: "1000",
                    buyMax: "100000"
                ),
                SupportedPairsResponse.Pair(
                    pair: "BCH-\(currency.code)",
                    buyMin: "1000",
                    buyMax: "100000"
                ),
                SupportedPairsResponse.Pair(
                    pair: "ETH-\(currency.code)",
                    buyMin: "100",
                    buyMax: "10000"
                )
            ]
        )
    }
}
