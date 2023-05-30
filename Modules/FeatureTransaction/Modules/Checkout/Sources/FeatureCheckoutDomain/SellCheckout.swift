import Blockchain

public struct SellCheckout: Hashable {

    public let value: CryptoValue
    public let quote: MoneyValue
    public let networkFee: MoneyValue?
    public let expiresAt: Date?

    public var exchangeRate: MoneyValuePair {
        MoneyValuePair(base: value.moneyValue, quote: quote).exchangeRate
    }

    public init(
        value: CryptoValue,
        quote: MoneyValue,
        networkFee: MoneyValue? = nil,
        expiresAt: Date? = nil
    ) {
        self.value = value
        self.quote = quote
        self.networkFee = networkFee
        self.expiresAt = expiresAt
    }
}

extension SellCheckout {

    public static let previewTrading: Self = SellCheckout(
        value: .create(major: 0.0231, currency: .bitcoin),
        quote: .create(major: 498.21, currency: .fiat(.GBP)),
        expiresAt: Date().addingTimeInterval(60)
    )

    public static let previewDeFi: Self = SellCheckout(
        value: .create(major: 0.0231, currency: .bitcoin),
        quote: .create(major: 498.21, currency: .fiat(.GBP)),
        networkFee: MoneyValue.create(major: 0.00023265, currency: .crypto(.bitcoin)),
        expiresAt: Date().addingTimeInterval(60)
    )
}
