import Blockchain
import DIKit
import FeatureTransactionDomain
import NetworkKit

public protocol BrokerageQuoteClientProtocol {

    func get(
        base: Currency,
        quote: Currency,
        amount: String,
        paymentMethod: BrokerageQuote.PaymentMethod,
        profile: BrokerageQuote.Profile
    ) async throws -> BrokerageQuote.Price

    func create(
        base: Currency,
        quote: Currency,
        amount: String,
        paymentMethod: BrokerageQuote.PaymentMethod,
        paymentMethodId: String?,
        profile: BrokerageQuote.Profile
    ) async throws -> BrokerageQuote.Response
}

public typealias BrokerageQuoteRepository = BrokerageQuoteClient
extension BrokerageQuoteRepository: BrokerageQuoteRepositoryProtocol {}

public final class BrokerageQuoteClient: BrokerageQuoteClientProtocol {

    private let requestBuilder: RequestBuilder
    private let network: NetworkAdapterAPI

    public init(
        requestBuilder: RequestBuilder = resolve(),
        network: NetworkAdapterAPI = resolve()
    ) {
        self.requestBuilder = requestBuilder
        self.network = network
    }

    public func get(
        base: Currency,
        quote: Currency,
        amount: String,
        paymentMethod: BrokerageQuote.PaymentMethod,
        profile: BrokerageQuote.Profile
    ) async throws -> BrokerageQuote.Price {
        let request = requestBuilder.get(
            path: "/brokerage/quote/price",
            parameters: [
                URLQueryItem(name: "currencyPair", value: "\(base.code)-\(quote.code)"),
                URLQueryItem(name: "amount", value: amount),
                URLQueryItem(name: "paymentMethod", value: paymentMethod.value),
                URLQueryItem(name: "orderProfileName", value: profile.value)
            ]
            .compacted()
            .array,
            authenticated: true
        )!
        return try await network.perform(request: request).await()
    }

    public func create(
        base: Currency,
        quote: Currency,
        amount: String,
        paymentMethod: BrokerageQuote.PaymentMethod,
        paymentMethodId: String?,
        profile: BrokerageQuote.Profile
    ) async throws -> BrokerageQuote.Response {

        var body: AnyJSON = [
            "inputValue": amount,
            "pair": "\(base.code)-\(quote.code)",
            "paymentMethod": paymentMethod.value,
            "profile": profile.value
        ]

        if let paymentMethodId {
            body["paymentMethodId"] = paymentMethodId
        }

        let request = try requestBuilder.post(
            path: "/brokerage/quote",
            body: body.data(),
            authenticated: true
        )!
        return try await network.perform(request: request).await()
    }
}
