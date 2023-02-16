// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

public struct BuySellActivityItemEvent {

    public enum EventStatus {
        case pending
        case pendingConfirmation
        case cancelled
        case failed
        case expired
        case finished
    }

    public enum PaymentMethod {
        case card(paymentMethodId: String?)
        case applePay
        case bankTransfer
        case bankAccount
        case funds
    }

    public var currencyType: CurrencyType {
        outputValue.currency
    }

    public let isBuy: Bool
    public let isCancellable: Bool
    public let paymentProcessorErrorOccurred: Bool
    public let status: EventStatus
    public let paymentMethod: PaymentMethod
    public let recurringBuyId: String?

    public let identifier: String

    public let creationDate: Date
    public let price: FiatValue?
    public let inputValue: MoneyValue
    public let outputValue: MoneyValue
    public var fee: MoneyValue

    public init(
        identifier: String,
        creationDate: Date,
        status: EventStatus,
        price: FiatValue?,
        inputValue: MoneyValue,
        outputValue: MoneyValue,
        fee: MoneyValue,
        isBuy: Bool,
        isCancellable: Bool,
        paymentMethod: PaymentMethod,
        recurringBuyId: String? = nil,
        paymentProcessorErrorOccurred: Bool = false
    ) {
        self.isBuy = isBuy
        self.isCancellable = isCancellable
        self.creationDate = creationDate
        self.identifier = identifier
        self.status = status
        self.inputValue = inputValue
        self.outputValue = outputValue
        self.fee = fee
        self.paymentMethod = paymentMethod
        self.paymentProcessorErrorOccurred = paymentProcessorErrorOccurred
        self.recurringBuyId = recurringBuyId
        self.price = price
    }
}

extension BuySellActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension BuySellActivityItemEvent: Equatable {
    public static func == (lhs: BuySellActivityItemEvent, rhs: BuySellActivityItemEvent) -> Bool {
        lhs.identifier == rhs.identifier &&
            lhs.status == rhs.status
    }
}

extension BuySellActivityItemEvent {

    /// Creates a buy sell activity item event.
    ///
    /// Some sell activities are retrieved as swaps from a crypto currency to a fiat currency, and they should be mapped using this initializer.
    ///
    /// - Parameter swapActivityItemEvent: A swap activity item event.
    public init(swapActivityItemEvent: SwapActivityItemEvent) {
        self.isBuy = false
        self.isCancellable = false
        self.creationDate = swapActivityItemEvent.date
        self.identifier = swapActivityItemEvent.identifier
        self.inputValue = swapActivityItemEvent.amounts.withdrawal
        self.outputValue = swapActivityItemEvent.amounts.deposit
        self.fee = swapActivityItemEvent.amounts.withdrawalFee
        self.paymentMethod = .funds
        self.paymentProcessorErrorOccurred = false
        self.recurringBuyId = nil
        self.price = nil

        switch swapActivityItemEvent.status {
        case .complete:
            self.status = .finished
        case .delayed:
            self.status = .pending
        case .expired:
            self.status = .expired
        case .failed:
            self.status = .failed
        case .inProgress:
            self.status = .pending
        case .none:
            self.status = .pending
        case .pendingRefund:
            self.status = .pending
        case .refunded:
            self.status = .cancelled
        }
    }
}
