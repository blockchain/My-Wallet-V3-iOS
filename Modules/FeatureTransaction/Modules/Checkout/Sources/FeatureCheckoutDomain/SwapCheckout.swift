import Blockchain

public struct SwapCheckout: Equatable {

    public var from: Target
    public var to: Target
    public var quoteExpiration: Date?

    public var exchangeRate: MoneyValuePair {
        MoneyValuePair(base: from.cryptoValue.moneyValue, quote: to.cryptoValue.moneyValue).exchangeRate
    }

    public var totalFeesInFiat: FiatValue? {
        switch (from.feeFiatValue, to.feeFiatValue) {
        case (let x?, let y?) where !(from.fee.isZero && to.fee.isZero):
            return try? x + y
        case (let x?, nil) where from.fee.isNotZero:
            return x
        case (nil, let y?) where to.fee.isNotZero:
            return y
        default:
            return nil
        }
    }

    public init(
        from: Target,
        to: Target,
        quoteExpiration: Date? = nil
    ) {
        self.from = from
        self.to = to
        self.quoteExpiration = quoteExpiration
    }
}

extension SwapCheckout {

    public struct Target: Equatable {
        public var name: String
        public var isPrivateKey: Bool
        public var cryptoValue: CryptoValue
        public var fee: CryptoValue
        public var exchangeRateToFiat: MoneyValuePair?
        public var feeExchangeRateToFiat: MoneyValuePair?

        public var fiatValue: FiatValue? {
            exchangeRateToFiat.flatMap { exchangeRate in
                try? cryptoValue.moneyValue.convert(using: exchangeRate)
            }?.fiatValue
        }

        public var feeFiatValue: FiatValue? {
            feeExchangeRateToFiat.flatMap { exchangeRate in
                try? fee.moneyValue.convert(using: exchangeRate)
            }?.fiatValue
        }

        public var code: String {
            cryptoValue.code
        }

        public init(
            name: String,
            isPrivateKey: Bool,
            cryptoValue: CryptoValue,
            fee: CryptoValue,
            exchangeRateToFiat: MoneyValuePair?,
            feeExchangeRateToFiat: MoneyValuePair?
        ) {
            self.name = name
            self.isPrivateKey = isPrivateKey
            self.cryptoValue = cryptoValue
            self.fee = fee
            self.exchangeRateToFiat = exchangeRateToFiat
            self.feeExchangeRateToFiat = feeExchangeRateToFiat
        }
    }
}

extension SwapCheckout {

    public static let preview = SwapCheckout(
        from: Target(
            name: "Private Key Wallet",
            isPrivateKey: true,
            cryptoValue: .create(minor: 12315135, currency: .bitcoin),
            fee: .create(minor: 1351312, currency: .bitcoin),
            exchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .bitcoin),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            ),
            feeExchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .bitcoin),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            )
        ),
        to: Target(
            name: "Private Key Wallet",
            isPrivateKey: true,
            cryptoValue: .create(minor: 1221412442357135135, currency: .ethereum),
            fee: .create(minor: 12321422414515, currency: .ethereum),
            exchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .ethereum),
                quote: FiatValue.create(minor: 10000000000, currency: .USD).moneyValue
            ),
            feeExchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .ethereum),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            )
        ),
        quoteExpiration: Date().addingTimeInterval(60)
    )

    public static let previewPrivateKeyToTrading = SwapCheckout(
        from: Target(
            name: "Private Key Wallet",
            isPrivateKey: true,
            cryptoValue: .create(minor: 12315135, currency: .bitcoin),
            fee: .create(minor: 1351312, currency: .bitcoin),
            exchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .bitcoin),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            ),
            feeExchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .bitcoin),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            )
        ),
        to: Target(
            name: "Trading Wallet",
            isPrivateKey: false,
            cryptoValue: .create(minor: 1221412442357135135, currency: .ethereum),
            fee: .create(minor: 12321422414515, currency: .ethereum),
            exchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .ethereum),
                quote: FiatValue.create(minor: 10000000000, currency: .USD).moneyValue
            ),
            feeExchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .ethereum),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            )
        ),
        quoteExpiration: Date().addingTimeInterval(60)
    )

    public static let previewTradingToTrading = SwapCheckout(
        from: Target(
            name: "Trading Wallet",
            isPrivateKey: false,
            cryptoValue: .create(minor: 12315135, currency: .bitcoin),
            fee: .create(minor: 1351312, currency: .bitcoin),
            exchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .bitcoin),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            ),
            feeExchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .bitcoin),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            )
        ),
        to: Target(
            name: "Trading Wallet",
            isPrivateKey: false,
            cryptoValue: .create(minor: 1221412442357135135, currency: .ethereum),
            fee: .create(minor: 12321422414515, currency: .ethereum),
            exchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .ethereum),
                quote: FiatValue.create(minor: 10000000000, currency: .USD).moneyValue
            ),
            feeExchangeRateToFiat: MoneyValuePair(
                base: .one(currency: .ethereum),
                quote: FiatValue.create(minor: 20000000000, currency: .USD).moneyValue
            )
        ),
        quoteExpiration: Date().addingTimeInterval(60)
    )
}
