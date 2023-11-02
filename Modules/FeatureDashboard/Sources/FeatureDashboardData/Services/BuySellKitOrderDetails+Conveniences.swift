// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension BuySellActivityItemEvent {
    init(with orderDetails: OrderDetails) {

        let paymentMethod: PaymentMethod = switch orderDetails.paymentMethod {
        case .bankAccount:
            .bankAccount
        case .bankTransfer:
            .bankTransfer
        case .card:
            .card(paymentMethodId: orderDetails.paymentMethodId)
        case .applePay:
            .applePay
        case .funds:
            .funds
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
            .pending
        case .pendingConfirmation:
            .pendingConfirmation
        case .cancelled:
            .cancelled
        case .expired:
            .expired
        case .failed:
            .failed
        case .finished:
            .finished
        }
    }
}
