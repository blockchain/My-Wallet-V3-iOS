import Blockchain

public struct WithdrawCheckout: Codable, Hashable {

    public let from: String
    public let to: String
    public let fee: MoneyValue
    public let settlementDate: Date?
    public let total: MoneyValue

    public init(
        from: String,
        to: String,
        fee: MoneyValue,
        settlementDate: Date? = nil,
        total: MoneyValue
    ) {
        self.from = from
        self.to = to
        self.fee = fee
        self.settlementDate = settlementDate
        self.total = total
    }
}

extension WithdrawCheckout {

    public static let preview = WithdrawCheckout(
        from: "US Dollar",
        to: "Bank of America",
        fee: .zero(currency: .USD),
        settlementDate: Date().addingTimeInterval(.days(5)),
        total: .create(major: 100.0, currency: .fiat(.USD))
    )
}
