import BigInt
import Blockchain
import FeaturePlaidDomain

@dynamicMemberLookup
public struct BrokerageQuote: Hashable {

    public let request: Request
    public let response: Response

    public subscript<Value>(dynamicMember keyPath: KeyPath<Request, Value>) -> Value {
        request[keyPath: keyPath]
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<Response, Value>) -> Value {
        response[keyPath: keyPath]
    }

    public var fee: (
        value: MoneyValue?,
        withoutPromotion: MoneyValue?,
        static: MoneyValue,
        network: MoneyValue
    ) {
            (
                value: response.fee.flatMap { fee in
                    MoneyValue.create(
                        minor: fee.value,
                        currency: request.amount.currency
                    )
                },
                withoutPromotion: response.fee.flatMap { fee in
                    MoneyValue.create(
                        minor: fee.withoutPromotion,
                        currency: request.amount.currency
                    )
                },
                static: response.staticFee
                    .flatMap { MoneyValue.create(minor: $0, currency: request.quote) } ?? .zero(currency: request.quote),
                network: response.networkFee
                    .flatMap { MoneyValue.create(minor: $0, currency: request.quote) } ?? .zero(currency: request.quote)
            )
        }

    public var result: MoneyValuePair? {
        do {
            return try MoneyValuePair(
                base: request.amount,
                quote: MoneyValue.create(minor: response.resultAmount, currency: request.quote)
                    .or(throw: "\(response.resultAmount) is not representable in \(request.quote)")
            )
        } catch {
            return nil
        }
    }

    public var source: CurrencyType {
        request.base
    }

    public var target: CurrencyType {
        request.quote
    }
}

extension BrokerageQuote {

    public struct Request: Hashable {

        public var amount: MoneyValue
        public var base: CurrencyType
        public var quote: CurrencyType
        public var paymentMethod: BrokerageQuote.PaymentMethod
        public var paymentMethodId: String?
        public var profile: BrokerageQuote.Profile

        public init(
            amount: MoneyValue,
            base: CurrencyType,
            quote: CurrencyType,
            paymentMethod: BrokerageQuote.PaymentMethod,
            paymentMethodId: String? = nil,
            profile: BrokerageQuote.Profile
        ) {
            self.amount = amount
            self.base = base
            self.quote = quote
            self.paymentMethod = paymentMethod
            self.paymentMethodId = paymentMethodId
            self.profile = profile
        }
    }

    public struct Response: Codable, Hashable {

        public init(
            id: String,
            marginPercent: Double,
            createdAt: String,
            expiresAt: String,
            price: String,
            resultAmount: String,
            networkFee: String? = nil,
            staticFee: String? = nil,
            fee: BrokerageQuote.Fee?,
            settlementDetails: BrokerageQuote.Settlement? = nil,
            depositTerms: PaymentsDepositTerms? = nil,
            sampleDepositAddress: String? = nil
        ) {
            self.id = id
            self.marginPercent = marginPercent
            self.createdAt = createdAt
            self.expiresAt = expiresAt
            self.price = price
            self.resultAmount = resultAmount
            self.networkFee = networkFee
            self.staticFee = staticFee
            self.fee = fee
            self.settlementDetails = settlementDetails
            self.depositTerms = depositTerms
            self.sampleDepositAddress = sampleDepositAddress
        }

        public var id: String
        public var marginPercent: Double
        public var createdAt, expiresAt: String
        public var price: String
        public var resultAmount: String
        public var networkFee, staticFee: String?
        public var fee: Fee?
        public var settlementDetails: Settlement?
        public var depositTerms: PaymentsDepositTerms?
        public var sampleDepositAddress: String?
    }
}

extension BrokerageQuote.Response {

    static let formatter: ISO8601DateFormatter = with(ISO8601DateFormatter()) { formatter in
        formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
    }

    public var date: (createdAt: Date?, expiresAt: Date?) {
        (
            My.formatter.date(from: createdAt),
            My.formatter.date(from: expiresAt)
        )
    }
}

extension BrokerageQuote {

    public struct PaymentMethod: NewTypeString {

        public var value: String
        public init(_ value: String) { self.value = value }

        public static let card: Self = "PAYMENT_CARD"
        public static let transfer: Self = "BANK_TRANSFER"
        public static let funds: Self = "FUNDS"
        public static let deposit: Self = "DEPOSIT"
    }

    public struct Profile: NewTypeString {

        public var value: String
        public init(_ value: String) { self.value = value }

        public static let buy: Self = "SIMPLEBUY"
        public static let swapTradingToTrading: Self = "SWAP_INTERNAL"
        public static let swapPKWToPKW: Self = "SWAP_ON_CHAIN"
        public static let swapPKWToTrading: Self = "SWAP_FROM_USERKEY"
    }

    public struct Price: Codable, Hashable {

        public init(
            pair: String,
            amount: String,
            price: String,
            result: String,
            dynamicFee: String,
            networkFee: String? = nil
        ) {
            self.pair = pair
            self.amount = amount
            self.price = price
            self.result = result
            self.dynamicFee = dynamicFee
            self.networkFee = networkFee
        }

        public var pair: String
        public var amount, price, result: String
        public var dynamicFee: String, networkFee: String?
    }
}

extension BrokerageQuote.Price {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        pair = try container.decodeIfPresent(String.self, forKey: "pair") ?? container.decode(String.self, forKey: "currencyPair")
        amount = try container.decode(String.self, forKey: "amount")
        price = try container.decode(String.self, forKey: "price")
        self.result = try container.decodeIfPresent(String.self, forKey: "result") ?? container.decode(String.self, forKey: "resultAmount")
        do {
            let fee = try container.decode([String: String].self, forKey: "fee")
            dynamicFee = try fee["dynamic"].or(throw: "Expected dynamic")
            networkFee = fee["network"]
        } catch {
            dynamicFee = try container.decode(String.self, forKey: "dynamicFee")
            networkFee = try container.decodeIfPresent(String.self, forKey: "networkFee")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        try container.encode(pair, forKey: "pair")
        try container.encode(amount, forKey: "amount")
        try container.encode(price, forKey: "price")
        try container.encode(result, forKey: "result")
        try container.encode(["dynamic": dynamicFee, "network": networkFee], forKey: "fee")
    }

    public var exchangeRate: MoneyValuePair {
        MoneyValuePair(
            base: MoneyValue.create(minor: amount, currency: source)!,
            quote: MoneyValue.create(minor: result, currency: target)!
        )
    }

    public var inverse: BrokerageQuote.Price {
        BrokerageQuote.Price(
            pair: pair.splitIfNotEmpty(separator: "-").reversed().joined(separator: "-"),
            amount: exchangeRate.quote.minorString,
            price: try! MoneyValue.create(minor: price, currency: target)!.convert(using: exchangeRate).minorString,
            result: exchangeRate.base.minorString,
            dynamicFee: try! MoneyValue.create(minor: dynamicFee, currency: source).or(throw: "No dynamicFee").convert(using: exchangeRate).minorString,
            networkFee: try! networkFee.flatMap { MoneyValue.create(minor: $0, currency: target) }?.convert(using: exchangeRate).minorString
        )
    }

    public var source: CurrencyType { try! CurrencyType(code: pair.split(separator: "-").map(\.string).tuple().0) }

    public var target: CurrencyType { try! CurrencyType(code: pair.split(separator: "-").map(\.string).tuple().1) }

    public var fee: (
        dynamic: MoneyValue,
        network: MoneyValue
    ) {
            (
                dynamic: MoneyValue.create(minor: dynamicFee, currency: source) ?? .zero(currency: target),
                network: networkFee.flatMap { MoneyValue.create(minor: $0, currency: target) } ?? .zero(currency: target)
            )
        }
}

extension BrokerageQuote {

    public struct Fee: Codable, Hashable {

        public init(withoutPromotion: String, value: String, flags: [String]) {
            self.withoutPromotion = withoutPromotion
            self.value = value
            self.flags = flags
        }

        public let withoutPromotion: String
        public let value: String
        public let flags: [String]
    }

    public struct Settlement: Codable, Hashable {

        public init(availability: String) {
            self.availability = availability
        }

        public let availability: String
    }
}

extension BrokerageQuote.Fee {
    public static var free: Self { .init(withoutPromotion: "0", value: "0", flags: []) }
}

extension BrokerageQuote.Response {

    public enum CodingKeys: String, CodingKey {
        case id = "quoteId"
        case marginPercent = "quoteMarginPercent"
        case createdAt = "quoteCreatedAt"
        case expiresAt = "quoteExpiresAt"
        case price
        case networkFee
        case resultAmount
        case staticFee
        case fee = "feeDetails"
        case settlementDetails
        case depositTerms
    }
}

extension BrokerageQuote.Fee {

    public enum CodingKeys: String, CodingKey {
        case withoutPromotion = "feeWithoutPromo", value = "fee", flags = "feeFlags"
    }
}

extension BrokerageQuote: CustomStringConvertible {

    public var description: String {
        "Quote \(self.id), price \(self.price), expires \(self.expiresAt)"
    }
}

extension BrokerageQuote.Price: CustomStringConvertible {

    public var description: String {
        "Price \(result)"
    }
}

extension BrokerageQuote.Price {

    public static func zero(_ source: String, _ target: String) -> Self {
        BrokerageQuote.Price(pair: "\(source)-\(target)", amount: "0", price: "0", result: "0", dynamicFee: "0")
    }
}

extension RangeReplaceableCollection {

    fileprivate func tuple() throws -> (Element, Element) {
        guard count >= 2 else { throw "\(count) < 2 - not a tuple" }
        return (self[startIndex], self[index(after: startIndex)])
    }
}
