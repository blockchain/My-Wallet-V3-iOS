import Blockchain

public struct SellCheckout: Equatable {

    public let value: CryptoValue
    public let quote: MoneyValue
    public let expiresAt: Date?
    public var networkFee: MoneyValue?
    public var networkFeeExchangeRateToFiat: MoneyValuePair?

    public var feeFiatValue: FiatValue? {
        networkFeeExchangeRateToFiat.flatMap { exchangeRate in
            try? networkFee?.convert(using: exchangeRate)
        }?
            .fiatValue
    }

    public var exchangeRate: MoneyValuePair {
        MoneyValuePair(base: value.moneyValue, quote: quote).exchangeRate
    }

    public init(
        value: CryptoValue,
        quote: MoneyValue,
        networkFee: MoneyValue? = nil,
        networkFeeExchangeRateToFiat: MoneyValuePair?,
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
        networkFeeExchangeRateToFiat: MoneyValuePair(
            base: .one(currency: .bitcoin),
            quote: FiatValue.create(major: 1987.2, currency: .GBP).moneyValue),
        expiresAt: Date().addingTimeInterval(60)
    )

    public static let previewDeFi: Self = SellCheckout(
        value: .create(major: 0.0231, currency: .bitcoin),
        quote: .create(major: 498.21, currency: .fiat(.GBP)),
        networkFee: MoneyValue.create(major: 0.00023265, currency: .crypto(.bitcoin)),
        networkFeeExchangeRateToFiat: MoneyValuePair(
            base: .one(currency: .bitcoin),
            quote: FiatValue.create(major: 1987.2, currency: .GBP).moneyValue),
        expiresAt: Date().addingTimeInterval(60)
    )
}
