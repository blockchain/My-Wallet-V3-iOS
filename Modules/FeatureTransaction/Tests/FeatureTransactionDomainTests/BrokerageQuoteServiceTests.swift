// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
@testable import FeatureTransactionDomain
import TestKit
import XCTest

final class BrokerageQuoteServiceTests: XCTestCase {

    class Repository: BrokerageQuoteRepositoryProtocol, LegacyCustodialQuoteRepositoryProtocol {

        var expirations: IndexingIterator<[Date]>

        init(expirations: [Date]) {
            self.expirations = expirations.makeIterator()
        }

        func get(
            base: Currency,
            quote: Currency,
            amount: String,
            paymentMethod: BrokerageQuote.PaymentMethod,
            profile: BrokerageQuote.Profile
        ) async throws -> BrokerageQuote.Price {
            try BrokerageQuote.Price(
                json: [
                    "currencyPair": "USD-BTC",
                    "amount": "5675",
                    "price": "10121",
                    "resultAmount": "28271",
                    "dynamicFee": "0",
                    "networkFee": "0"
                ]
            )
        }

        func create(
            base: Currency,
            quote: Currency,
            amount: String,
            paymentMethod: BrokerageQuote.PaymentMethod,
            paymentMethodId: String?,
            profile: BrokerageQuote.Profile
        ) async throws -> BrokerageQuote.Response {
            guard let next = expirations.next() else { throw "No more quotes" }
            return try .init(
                json: [
                    "quoteId": UUID().uuidString,
                    "quoteMarginPercent": 0.5,
                    "quoteCreatedAt": BrokerageQuote.Response.formatter.string(from: next),
                    "quoteExpiresAt": BrokerageQuote.Response.formatter.string(from: next),
                    "price": "5675",
                    "networkFee": "0",
                    "staticFee": "0",
                    "feeDetails": [
                        "feeWithoutPromo": "59",
                        "fee": "0",
                        "feeFlags": [
                            "NEW_USER_WAIVER"
                        ]
                    ],
                    "settlementDetails": [
                        "availability": "REGULAR"
                    ]
                ]
            )
        }
    }

    func x_test() async throws {

        let scheduler = DispatchQueue.immediate
        let repository = Repository(
            expirations: [
                Date.distantPast,
                Date.distantPast.addingTimeInterval(.seconds(30)),
                Date.distantPast.addingTimeInterval(.seconds(60)),
                Date.distantPast.addingTimeInterval(.seconds(90)),
                Date.distantPast.addingTimeInterval(.seconds(120))
            ]
        )
        let service = BrokerageQuoteService(
            app: App.test,
            legacy: repository,
            new: repository,
            scheduler: scheduler.eraseToAnyScheduler()
        )

        let stream = service.quotes(
            .init(
                amount: .create(minor: "1000", currency: .fiat(.USD)),
                base: .fiat(.USD),
                quote: .crypto(.bitcoin),
                paymentMethod: .funds,
                paymentMethodId: nil,
                profile: .buy
            )
        ).values

        var previous: BrokerageQuote?
        for await (i, quote) in zip((1...).async, stream) {
            defer { previous = quote.success }
            if let previous {
                try XCTAssertTrue(quote.success.unwrap().date.expiresAt.unwrap() > previous.date.expiresAt.unwrap())
            }
            if i == 5 { break }
        }
    }
}
