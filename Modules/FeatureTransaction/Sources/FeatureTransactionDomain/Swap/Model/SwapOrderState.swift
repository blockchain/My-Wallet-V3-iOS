// Copyright © Blockchain Luxembourg S.A. All rights reserved.

enum SwapOrderState {
    case pendingExecution
    case pendingDeposit
    case finishDeposit
    case pendingWithdrawal
    case pendingRefund
    case refunded
    case delayed
    case expired
    case finished
    case failed
    case unknown
    case none

    var isPending: Bool {
        switch self {
        case .pendingDeposit,
             .pendingExecution,
             .pendingWithdrawal,
             .pendingRefund,
             .finishDeposit:
            true
        case .expired,
             .finished,
             .failed,
             .refunded,
             .delayed,
             .none,
             .unknown:
            false
        }
    }

    init(value: String) {
        switch value {
        case "NONE":
            self = .none
        case "PENDING_EXECUTION":
            self = .pendingExecution
        case "PENDING_DEPOSIT":
            self = .pendingDeposit
        case "FINISHED_DEPOSIT":
            self = .finishDeposit
        case "PENDING_WITHDRAWAL":
            self = .pendingWithdrawal
        case "PENDING_REFUND":
            self = .pendingRefund
        case "REFUNDED":
            self = .refunded
        case "FINISHED":
            self = .finished
        case "FAILED":
            self = .failed
        case "EXPIRED":
            self = .expired
        case "DELAYED":
            self = .delayed
        default:
            self = .none
        }
    }
}
