import Foundation

public struct RecurringBuy: Identifiable, Equatable, Codable, Hashable {

    public typealias ID = String

    public let id: String
    public let recurringBuyFrequency: String
    public let nextPaymentDate: String
    public let paymentMethodType: String
    public let amount: String
    public let asset: String

    public init(
        id: String,
        recurringBuyFrequency: String,
        nextPaymentDate: String,
        paymentMethodType: String,
        amount: String,
        asset: String
    ) {
        self.id = id
        self.recurringBuyFrequency = recurringBuyFrequency
        self.nextPaymentDate = nextPaymentDate
        self.paymentMethodType = paymentMethodType
        self.amount = amount
        self.asset = asset
    }
}

extension RecurringBuy {
    public static func == (lhs: RecurringBuy, rhs: RecurringBuy) -> Bool {
        lhs.id == rhs.id
    }
}
