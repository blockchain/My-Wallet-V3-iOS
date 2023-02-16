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

    public var fee: (value: FiatValue, withoutPromotion: FiatValue) {
        get throws {
            try (
                value: MoneyValue.create(
                    minor: response.fee.value,
                    currency: request.amount.currency
                )
                .or(default: .zero(currency: request.amount.currency))
                .fiatValue.or(throw: "Fee is expected to be fiat"),
                withoutPromotion: MoneyValue.create(
                    minor: response.fee.withoutPromotion,
                    currency: request.amount.currency
                )
                .or(default: .zero(currency: request.amount.currency))
                .fiatValue.or(throw: "Fee is expected to be fiat")
            )
        }
    }

    public var result: MoneyValuePair? {
        do {
            let exchangeRate = try MoneyValuePair(
                base: .one(currency: request.amount.currency),
                quote: .create(minor: response.price, currency: request.quote).or(throw: "Bad quote price")
            )

            let purchase = try request.amount - MoneyValue.create(
                minor: response.fee.value,
                currency: request.amount.currency
            ).or(.zero(currency: request.amount.currency))

            return try MoneyValuePair(
                base: purchase,
                quote: purchase.convert(using: exchangeRate)
            )
        } catch {
            return nil
        }
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
        public var id: String
        public var marginPercent: Double
        public var createdAt, expiresAt: String
        public var price: String
        public var networkFee, staticFee: String?
        public var fee: Fee
        public var settlementDetails: Settlement
        public var depositTerms: PaymentsDepositTerms?
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
        public static let bank: Self = "BANK_ACCOUNT"
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
        public let pair: String
        public let amount, price, result: String
        public let dynamicFee: String, networkFee: String?
    }
}

extension BrokerageQuote {

    public struct Fee: Codable, Hashable {
        public let withoutPromotion: String
        public let value: String
        public let flags: [String]
    }

    public struct Settlement: Codable, Hashable {
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

extension BrokerageQuote.Price {

    public enum CodingKeys: String, CodingKey {
        case pair = "currencyPair"
        case amount
        case price
        case result = "resultAmount"
        case dynamicFee
        case networkFee
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
