import Foundation

private let formatter = DateFormatter()

public struct RecurringBuy: Identifiable, Equatable, Codable, Hashable {

    public typealias ID = String

    public let id: String
    public let recurringBuyFrequency: String
    public let nextPaymentDate: Date
    public let paymentMethodType: String
    public let amount: String
    public let asset: String

    public var nextPaymentDateDescription: String {
        nextPaymentDate.formatted(.dateTime.weekday().day().month(.wide))
    }

    public init(
        id: String,
        recurringBuyFrequency: String,
        nextPaymentDate: Date,
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
