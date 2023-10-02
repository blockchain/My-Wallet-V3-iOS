import Blockchain

public struct DepositCheckout: Codable, Hashable {

    public let from: String
    public let to: String
    public let fee: MoneyValue
    public let settlementDate: Date?
    public let availableToWithdraw: String?
    public let total: MoneyValue

    public init(
        from: String,
        to: String,
        fee: MoneyValue,
        settlementDate: Date? = nil,
        availableToWithdraw: String? = nil,
        total: MoneyValue
    ) {
        self.from = from
        self.to = to
        self.fee = fee
        self.settlementDate = settlementDate
        self.availableToWithdraw = availableToWithdraw
        self.total = total
    }
}

extension DepositCheckout {

    public static let preview = DepositCheckout(
        from: "US Dollar",
        to: "Bank of America",
        fee: .zero(currency: .USD),
        settlementDate: Date().addingTimeInterval(.days(5)),
        availableToWithdraw: "July 15th",
        total: .create(major: 100.0, currency: .fiat(.USD))
    )
}
