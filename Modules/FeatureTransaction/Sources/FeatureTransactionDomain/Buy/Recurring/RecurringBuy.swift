// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit

public struct RecurringBuy {

    public enum State: String {
        case active = "ACTIVE"
        case inactive = "INACTIVE"
        case uninitialised = "UNINITIALISED"
    }

    public enum Frequency: String, CaseIterable, Identifiable, Decodable {
        case unknown
        case once = "ONE_TIME"
        case daily = "DAILY"
        case weekly = "WEEKLY"
        case biweekly = "BI_WEEKLY"
        case monthly = "MONTHLY"

        public var id: String {
            rawValue
        }

        /// The `RecurringBuy.Frequency` is valid for a recurring buy
        public var isValidRecurringBuyFrequency: Bool {
            self != .unknown && self != .once
        }
    }

    public let id: String
    public let state: State
    public let recurringBuyFrequency: Frequency
    public let nextPaymentDate: Date
    public let paymentMethodType: PaymentMethodPayloadType
    public let paymentMethodId: String?
    public let amount: MoneyValue
    public let asset: CurrencyType
    public let createDate: Date

    public init(
        id: String,
        state: State,
        recurringBuyFrequency: Frequency,
        nextPaymentDate: Date,
        paymentMethodType: PaymentMethodPayloadType,
        paymentMethodId: String?,
        amount: MoneyValue,
        asset: CurrencyType,
        createDate: Date
    ) {
        self.id = id
        self.state = state
        self.recurringBuyFrequency = recurringBuyFrequency
        self.nextPaymentDate = nextPaymentDate
        self.paymentMethodType = paymentMethodType
        self.paymentMethodId = paymentMethodId
        self.amount = amount
        self.asset = asset
        self.createDate = createDate
    }
}

extension RecurringBuy.Frequency {
    typealias LocalizationId = LocalizationConstants.Transaction.Buy.Recurring
    public var description: String {
        switch self {
        case .unknown:
            LocalizationConstants.unknown
        case .once:
            LocalizationId.oneTimeBuy
        case .daily:
            LocalizationId.daily
        case .weekly:
            LocalizationId.weekly
        case .biweekly:
            LocalizationId.twiceAMonth
        case .monthly:
            LocalizationId.monthly
        }
    }
}

extension RecurringBuy {
    typealias LocalizationId = LocalizationConstants.Transaction.Buy.Recurring

    public var nextPaymentDateDescription: String? {
        switch recurringBuyFrequency {
        case .unknown,
                .once:
            return nil
        case .daily:
            return LocalizationId.daily
        case .weekly:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return LocalizationId.on + " \(formatter.string(from: nextPaymentDate))"
        case .monthly:
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            let day = formatter.string(from: nextPaymentDate)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .ordinal
            guard let next = numberFormatter.string(from: NSNumber(value: Int(day) ?? 0)) else { return nil }
            return LocalizationId.onThe + " " + next
        case .biweekly:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return LocalizationId.everyOther + " \(formatter.string(from: nextPaymentDate))"
        }
    }
}
