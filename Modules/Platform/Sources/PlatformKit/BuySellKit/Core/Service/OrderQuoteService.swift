// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import RxSwift
import ToolKit

public enum Profile: String, Encodable {
    case simpleBuy = "SIMPLEBUY"
    case simpleTrade = "SIMPLETRADE"
    case swapFromUserKey = "SWAP_FROM_USERKEY"
    case swapInternal = "SWAP_INTERNAL"
    case swapOnChain = "SWAP_ON_CHAIN"
}

public struct QuoteQuery {

    /// The type of quote
    let profile: Profile

    /// The source currency, fiat or crypto
    let sourceCurrency: Currency

    /// The destination curency, fiat or crypto
    let destinationCurrency: Currency

    /// The source amount, fiat or crypto
    let amount: MoneyValue

    /// The payment method if relevant profile is chosen
    let paymentMethod: PaymentMethodPayloadType?

    /// The payment method Id if the method is bank transfer
    let paymentMethodId: String?

    public init(
        profile: Profile,
        sourceCurrency: Currency,
        destinationCurrency: Currency,
        amount: MoneyValue,
        paymentMethod: PaymentMethodPayloadType?,
        paymentMethodId: String?
    ) {
        self.profile = profile
        self.sourceCurrency = sourceCurrency
        self.destinationCurrency = destinationCurrency
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.paymentMethodId = paymentMethodId
    }
}

/// Used to convert the user input into an actual quote with fee (takes a fiat amount)
public protocol OrderQuoteServiceAPI: AnyObject {

    func getQuote(
        query: QuoteQuery
    ) -> AnyPublisher<Quote, Error>
}

final class OrderQuoteService: OrderQuoteServiceAPI {

    // MARK: - Properties

    private let client: QuoteClientAPI

    // MARK: - Setup

    init(
        client: QuoteClientAPI = resolve()
    ) {
        self.client = client
    }

    // MARK: - API

    func getQuote(
        query: QuoteQuery
    ) -> AnyPublisher<Quote, Error> {
        client
            .getQuote(queryRequest: QuoteQueryRequest(from: query))
            .eraseError()
            .tryMap { response in
                try Quote(
                    sourceCurrency: query.sourceCurrency,
                    destinationCurrency: query.destinationCurrency,
                    value: query.amount,
                    response: response
                )
            }
            .eraseToAnyPublisher()
    }
}
