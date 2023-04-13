import Blockchain

public struct SendCheckout: Equatable {
    public var amount: Amount
    public var from: Target
    public var to: Target
    public var fee: Fee
    public var total: Amount
    // For stellar transactions
    public var memo: Memo?

    public var currencyType: CurrencyType {
        amount.value.currencyType
    }

    public var isSourcePrivateKey: Bool {
        from.isPrivateKey
    }

    public init(
        amount: Amount,
        from: SendCheckout.Target,
        to: SendCheckout.Target,
        fee: Fee,
        total: Amount,
        memo: Memo? = nil
    ) {
        self.amount = amount
        self.from = from
        self.to = to
        self.fee = fee
        self.total = total
        self.memo = memo
    }
}

extension SendCheckout {
    public struct Amount: Equatable {
        public let value: MoneyValue
        public let fiatValue: MoneyValue?

        public init(value: MoneyValue, fiatValue: MoneyValue?) {
            self.value = value
            self.fiatValue = fiatValue
        }
    }

    public struct Fee: Equatable {
        public enum FeeType: Equatable {
            case processing
            case network(level: String)

            public var tagTitle: String {
                switch self {
                case .network(let level):
                    return level
                case .processing:
                    return ""
                }
            }
        }

        public let type: FeeType
        public let value: MoneyValue
        public let exchange: MoneyValue?

        public init(
            type: SendCheckout.Fee.FeeType,
            value: MoneyValue,
            exchange: MoneyValue? = nil
        ) {
            self.type = type
            self.value = value
            self.exchange = exchange
        }
    }

    public struct Target: Equatable {
        public var name: String
        public var isPrivateKey: Bool

        public init(
            name: String,
            isPrivateKey: Bool
        ) {
            self.name = name
            self.isPrivateKey = isPrivateKey
        }
    }

    public struct Memo: Equatable {
        public var value: String?
        public var required: Bool

        public var suffixIfRequired: String {
            required ? "*" : ""
        }

        public init(value: String?, required: Bool) {
            self.value = value
            self.required = required
        }
    }
}

extension SendCheckout {

    public static var preview: SendCheckout {
        .init(
            amount: .init(
                value: .create(major: 0.00608014, currency: .crypto(.ethereum)),
                fiatValue: .create(major: 100.0, currency: .fiat(.GBP))
            ),
            from: .init(
                name: "Blockchain.com Account",
                isPrivateKey: false
            ),
            to: .init(
                name: "DeFi Wallet",
                isPrivateKey: true
            ),
            fee: .init(
                type: .network(level: ""),
                value: .create(
                    major: 0.00028838,
                    currency: .crypto(.ethereum)
                ),
                exchange: .create(
                    major: 48.0,
                    currency: .fiat(.GBP)
                )
            ),
            total: .init(
                value: .create(
                    major: 0.00636852,
                    currency: .crypto(.ethereum)
                ),
                fiatValue: .create(
                    major: 100.0,
                    currency: .fiat(.GBP)
                )
            )
        )
    }
}
