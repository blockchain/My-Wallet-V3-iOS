import Blockchain
import Localization

public struct BuyCheckout: Equatable {

    public enum BuyType {
        case simpleBuy
        case recurringBuy
    }

    public let buyType: BuyType
    public var input: MoneyValue
    public var purchase: MoneyValuePair
    public var fee: Fee?
    public var total: FiatValue
    public var paymentMethod: PaymentMethod
    public var recurringBuyDetails: RecurringBuyDetails?
    public var quoteExpiration: Date?
    public var depositTerms: DepositTerms?
    public var displaysInvestWeekly: Bool

    public init(
        buyType: BuyType,
        input: MoneyValue,
        purchase: MoneyValuePair,
        fee: Fee?,
        total: FiatValue,
        paymentMethod: BuyCheckout.PaymentMethod,
        quoteExpiration: Date?,
        recurringBuyDetails: RecurringBuyDetails? = nil,
        depositTerms: DepositTerms? = nil,
        displaysInvestWeekly: Bool = false
    ) {
        self.buyType = buyType
        self.input = input
        self.purchase = purchase
        self.fee = fee
        self.total = total
        self.recurringBuyDetails = recurringBuyDetails
        self.paymentMethod = paymentMethod
        self.quoteExpiration = quoteExpiration
        self.depositTerms = depositTerms
        self.displaysInvestWeekly = displaysInvestWeekly
    }
}

extension BuyCheckout {

    public struct DepositTerms: Equatable {

        public var availableToTrade: String?
        public var availableToWithdraw: String?
        public var withdrawalLockInDays: String?

        public init(
            availableToTrade: String?,
            availableToWithdraw: String?,
            withdrawalLockInDays: String?
        ) {
            self.availableToTrade = availableToTrade
            self.availableToWithdraw = availableToWithdraw
            self.withdrawalLockInDays = withdrawalLockInDays
        }
    }
}

extension BuyCheckout {
    public struct RecurringBuyDetails: Equatable {
        public let frequency: String
        public let description: String?

        public init(
            frequency: String,
            description: String? = nil
        ) {
            self.frequency = frequency
            self.description = description
        }
    }
}

extension BuyCheckout {

    public var exchangeRate: MoneyValue { purchase.inverseExchangeRate.quote }

    public var crypto: MoneyValue { purchase.quote }
    public var fiat: MoneyValue { purchase.base }

    public struct PaymentMethod: Equatable {

        public var name: String
        public var detail: String?
        public var isApplePay: Bool
        public var isACH: Bool

        public init(
            name: String,
            detail: String?,
            isApplePay: Bool,
            isACH: Bool
        ) {
            self.name = name
            self.detail = detail
            self.isApplePay = isApplePay
            self.isACH = isACH
        }
    }

    public struct Fee: Equatable {

        public var value: FiatValue
        public var promotion: FiatValue?

        public init(value: FiatValue, promotion: FiatValue? = nil) {
            self.value = value
            self.promotion = promotion
        }
    }
}

extension BuyCheckout {

    public static var preview: BuyCheckout {
        .init(
            buyType: .recurringBuy,
            input: .create(major: 0.0021037, currency: .crypto(.bitcoin)),
            purchase: MoneyValuePair(
                fiatValue: .create(major: 98.00, currency: .USD),
                exchangeRate: .create(major: 47410.61, currency: .USD),
                cryptoCurrency: .bitcoin,
                usesFiatAsBase: true
            ),
            fee: .init(
                value: .create(major: 2.00, currency: .USD)
            ),
            total: .create(
                major: 100.00,
                currency: .USD
            ),
            paymentMethod: .init(
                name: "Chase Sapphire",
                detail: "Visa 0392",
                isApplePay: false,
                isACH: false
            ),
            quoteExpiration: Date()
                .addingTimeInterval(30),
            recurringBuyDetails: .init(frequency: "Weekly"),
            depositTerms: nil
        )
    }
}
