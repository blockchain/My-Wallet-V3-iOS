import BigInt
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
public typealias LegacyCustodialQuoteRepository = LegacyCustodialQuoteClient

extension BrokerageQuoteRepository: BrokerageQuoteRepositoryProtocol {}
extension LegacyCustodialQuoteRepository: LegacyCustodialQuoteRepositoryProtocol {}

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

public final class LegacyCustodialQuoteClient: BrokerageQuoteClientProtocol {

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

        let create = try await create(
            base: base,
            quote: quote,
            amount: amount,
            paymentMethod: paymentMethod,
            paymentMethodId: nil,
            profile: profile
        )

        return BrokerageQuote.Price(
            pair: "\(base.code)-\(quote.code)",
            amount: amount,
            price: create.price,
            result: create.resultAmount,
            dynamicFee: create.staticFee ?? "0",
            networkFee: create.networkFee
        )
    }

    public func create(
        base: Currency,
        quote: Currency,
        amount: String,
        paymentMethod: BrokerageQuote.PaymentMethod,
        paymentMethodId: String?,
        profile: BrokerageQuote.Profile
    ) async throws -> BrokerageQuote.Response {

        let body: AnyJSON = [
            "pair": "\(base.code)-\(quote.code)",
            "product": profile.legacyProduct,
            "direction": profile.legacyDirection
        ]

        let request = try requestBuilder.post(
            path: "/custodial/quote",
            body: body.data(),
            authenticated: true
        )!

        let response: CustodialQuote = try await network.perform(request: request).await()

        let (tier, _) = try response.quote.priceTiers.adjacentPairs().first(
            where: { _, next in
                try BigInt(amount).or(throw: "\(amount) is not BigInt")
                <= BigInt(next.volume).or(throw: "\(next.volume) is not BigInt")
            }
        ).or(throw: "No price tier matches \(amount)")

        // BTC f = (amount - dynamicFee) * price - networkFee
        let exchangeRate = MoneyValuePair(
            base: MoneyValue.one(currency: quote.currencyType),
            quote: .create(minor: PricesInterpolator(prices: response.quote.priceTiers).rate(amount: amount.bigInt), currency: base.currencyType)
        )

        let amount = try MoneyValue.create(minor: amount, currency: base.currencyType)
            .or(throw: "Error: amount")

        let staticFee = MoneyValue.create(minor: response.staticFee ?? "0", currency: base.currencyType)
            .or(default: .zero(currency: base.currencyType))

        let purchase = try amount - staticFee

        let result = try purchase.convert(using: exchangeRate.inverseExchangeRate)
            - MoneyValue.create(minor: response.networkFee ?? "0", currency: quote.currencyType)
                .or(default: .zero(currency: base.currencyType))

        return BrokerageQuote.Response(
            id: response.id,
            marginPercent: 0,
            createdAt: response.createdAt,
            expiresAt: response.expiresAt,
            price: tier.price,
            resultAmount: result.minorString,
            networkFee: response.networkFee,
            staticFee: response.staticFee,
            fee: nil
        )
    }
}

extension BrokerageQuote.Profile {

    fileprivate var legacyDirection: String {
        switch self {
        case .swapPKWToPKW:
            return "ON_CHAIN"
        case .swapPKWToTrading:
            return "FROM_USERKEY"
        case _:
            return "INTERNAL"
        }
    }

    fileprivate var legacyProduct: String {
        switch self {
        case .buy:
            return "SIMPLEBUY"
        case _:
            return "BROKERAGE"
        }
    }
}

struct CustodialQuote: Codable {
    let id, product, pair: String
    let quote: Quote
    let networkFee, staticFee, sampleDepositAddress: String?
    let expiresAt, createdAt, updatedAt: String
}

struct Quote: Codable {
    let currencyPair: String
    let priceTiers: [PriceTier]
}

struct PriceTier: Codable {
    let volume, price, marginPrice: String
}

struct PricesInterpolator {

    private let prices: [PriceTier]

    init(prices: [PriceTier]) {
        self.prices = prices
    }

    func rate(amount: BigInt) -> BigInt {
        if let base = prices.first?.data, amount < base.volume {
            return base.price
        }
        let tier = prices
            .lazy
            .map(\.data)
            .adjacentPairs()
            .filter { tier, next in
                tier.volume < amount && amount <= next.volume
            }
            .map { tier, next in
                linear(x: (tier.volume, next.volume), y: (tier.price, next.price), by: amount)
            }.first

        return tier ?? prices.last.flatMap(\.price.bigInt) ?? .zero
    }
}

private func linear(x: (BigInt, BigInt), y: (BigInt, BigInt), by: BigInt) -> BigInt {
    ((by - x.0) * (y.1 - y.0) / (x.1 - x.0)) + y.0
}

extension PriceTier {

    fileprivate var data: (volume: BigInt, price: BigInt, margin: (price: BigInt, ())) {
        (
            volume: volume.bigInt,
            price: price.bigInt,
            margin: (
                price: marginPrice.bigInt, ()
            )
        )
    }
}

extension String {

    fileprivate var bigInt: BigInt! { BigInt(self) }
}
