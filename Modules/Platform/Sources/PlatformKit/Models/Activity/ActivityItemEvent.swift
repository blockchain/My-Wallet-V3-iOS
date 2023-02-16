// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureStakingDomain
import MoneyKit

public enum ActivityItemEvent: Equatable {

    case swap(SwapActivityItemEvent)
    // Send/Receive
    case transactional(TransactionalActivityItemEvent)
    // Send/Receive
    case simpleTransactional(SimpleTransactionalActivityItemEvent)
    // Buy Sell
    case buySell(BuySellActivityItemEvent)
    // Interest
    case interest(InterestActivityItemEvent)
    // Interest
    case earn(EarnProduct, EarnActivity)
    // Fiat
    case fiat(CustodialActivityEvent.Fiat)
    // Custodial Crypto Transfer
    case crypto(CustodialActivityEvent.Crypto)

    /// The `Status` of an activity item.
    public enum EventStatus {

        public struct Confirmations {
            /// How many confirmations have taken place
            public let current: Int
            /// The total number of confirmations required
            public let total: Int
        }

        public enum ProductEventStatus {
            case swap(SwapActivityItemEvent.EventStatus)
            case interest(InterestActivityItemEventState)
            case earn(EarnActivity.State)
            case buySell(BuySellActivityItemEvent.EventStatus)
            case custodial(CustodialActivityEvent.State)
        }

        /// The event is pending confirmation
        case pending(confirmations: Confirmations)
        /// The event has completed
        case complete
        /// The status of a product related event
        /// including `Swap`, `Buy`, and `Sell`.
        case product(ProductEventStatus)
    }

    public var creationDate: Date {
        switch self {
        case .buySell(let event):
            return event.creationDate
        case .interest(let event):
            return event.insertedAt
        case .earn(_, let event):
            return event.date.insertedAt
        case .swap(let swap):
            return swap.date
        case .simpleTransactional(let transaction):
            return transaction.creationDate
        case .transactional(let transaction):
            return transaction.creationDate
        case .fiat(let model):
            return model.date
        case .crypto(let model):
            return model.date
        }
    }
}

extension ActivityItemEvent: Comparable {
    public static func < (lhs: ActivityItemEvent, rhs: ActivityItemEvent) -> Bool {
        lhs.creationDate < rhs.creationDate
    }
}

extension ActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .buySell(let event):
            hasher.combine("buySell")
            hasher.combine(event.identifier)
        case .interest(let event):
            hasher.combine("interest")
            hasher.combine(event.identifier)
        case .earn(_, let event):
            hasher.combine("staking")
            hasher.combine(event.id)
        case .swap(let event):
            hasher.combine("swap")
            hasher.combine(event.identifier)
        case .simpleTransactional(let event):
            hasher.combine("simpleTransactional")
            hasher.combine(event.identifier)
        case .transactional(let event):
            hasher.combine("transactional")
            hasher.combine(event.identifier)
        case .fiat(let event):
            hasher.combine("fiat")
            hasher.combine(event.identifier)
        case .crypto(let event):
            hasher.combine("crypto")
            hasher.combine(event.identifier)
        }
    }
}

extension ActivityItemEvent {

    public var inputAmount: MoneyValue {
        switch self {
        case .buySell(let event):
            return event.inputValue
        case .interest(let event):
            return event.value.moneyValue
        case .earn(_, let event):
            return event.value
        case .swap(let event):
            return event.amounts.deposit
        case .simpleTransactional(let event):
            if event.type == .send {
                return (try? event.amount + event.fee)?.moneyValue ?? event.amount.moneyValue
            } else {
                return event.amount.moneyValue
            }
        case .transactional(let event):
            if event.type == .send {
                return (try? event.amount + event.fee)?.moneyValue ?? event.amount.moneyValue
            } else {
                return event.amount.moneyValue
            }
        case .fiat(let event):
            return event.amount.moneyValue
        case .crypto(let event):
            return (try? event.amount + event.fee)?.moneyValue ?? event.amount.moneyValue
        }
    }

    public var outputAmount: MoneyValue? {
        switch self {
        case .buySell(let event):
            return event.outputValue
        case .swap(let event):
            return event.amounts.withdrawal
        default:
            return nil
        }
    }

    public var identifier: String {
        switch self {
        case .buySell(let event):
            return event.identifier
        case .interest(let event):
            return event.identifier
        case .earn(_, let event):
            return event.id
        case .swap(let event):
            return event.identifier
        case .simpleTransactional(let event):
            return event.identifier
        case .transactional(let event):
            return event.identifier
        case .fiat(let event):
            return event.identifier
        case .crypto(let event):
            return event.identifier
        }
    }

    public var status: EventStatus {
        switch self {
        case .buySell(let event):
            return .product(.buySell(event.status))
        case .interest(let event):
            return .product(.interest(event.state))
        case .earn(_, let event):
            return .product(.earn(event.state))
        case .swap(let event):
            return .product(.swap(event.status))
        case .simpleTransactional(let event):
            switch event.status {
            case .complete:
                return .complete
            case .pending(confirmations: let confirmations):
                return .pending(confirmations: .init(
                    current: confirmations.current,
                    total: confirmations.total
                )
                )
            }
        case .transactional(let event):
            switch event.status {
            case .complete:
                return .complete
            case .pending(confirmations: let confirmations):
                return .pending(confirmations: .init(
                    current: confirmations.current,
                    total: confirmations.total
                )
                )
            }
        case .fiat(let event):
            return .product(.custodial(event.state))
        case .crypto(let event):
            return .product(.custodial(event.state))
        }
    }
}
