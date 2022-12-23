// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension BuySellActivityItemEvent {
    init(with orderDetails: OrderDetails) {

        let paymentMethod: PaymentMethod
        switch orderDetails.paymentMethod {
        case .bankAccount:
            paymentMethod = .bankAccount
        case .bankTransfer:
            paymentMethod = .bankTransfer
        case .card:
            paymentMethod = .card(paymentMethodId: orderDetails.paymentMethodId)
        case .applePay:
            paymentMethod = .applePay
        case .funds:
            paymentMethod = .funds
        }

        self.init(
            identifier: orderDetails.identifier,
            creationDate: orderDetails.creationDate ?? .distantPast,
            status: orderDetails.eventStatus,
            price: orderDetails.price?.fiatValue,
            inputValue: orderDetails.inputValue,
            outputValue: orderDetails.outputValue,
            fee: orderDetails.fee ?? .zero(currency: orderDetails.inputValue.currency),
            isBuy: orderDetails.isBuy,
            isCancellable: orderDetails.isCancellable,
            paymentMethod: paymentMethod,
            recurringBuyId: orderDetails.recurringBuyId,
            paymentProcessorErrorOccurred: orderDetails.paymentProccessorErrorOccurred
        )
    }
}

extension OrderDetails {
    fileprivate var eventStatus: BuySellActivityItemEvent.EventStatus {
        switch state {
        case .pendingDeposit,
             .depositMatched:
            return .pending
        case .pendingConfirmation:
            return .pendingConfirmation
        case .cancelled:
            return .cancelled
        case .expired:
            return .expired
        case .failed:
            return .failed
        case .finished:
            return .finished
        }
    }
}
