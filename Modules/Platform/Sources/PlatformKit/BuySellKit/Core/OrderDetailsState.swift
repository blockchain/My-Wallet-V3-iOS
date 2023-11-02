// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum OrderDetailsState: String, CaseIterable {

    typealias LocalizedString = LocalizationConstants.SimpleBuy.OrderState

    /// Waiting for deposit to be matched
    case pendingDeposit = "PENDING_DEPOSIT"

    /// Orders created in this state if pending parameter passed
    case pendingConfirmation = "PENDING_CONFIRMATION"

    /// Order canceled no longer eligible to be matched or executed
    case cancelled = "CANCELED"

    /// Order matched waiting to execute order
    case depositMatched = "DEPOSIT_MATCHED"

    /// Order could not execute
    case failed = "FAILED"

    /// Order did not receive deposit or execute in time (default expiration 14 days)
    case expired = "EXPIRED"

    /// Order executed and done
    case finished = "FINISHED"

    public var localizedDescription: String {
        switch self {
        case .pendingDeposit:
            LocalizedString.waitingOnFunds
        case .cancelled:
            LocalizedString.cancelled
        case .depositMatched:
            LocalizedString.pending
        case .expired:
            LocalizedString.expired
        case .failed:
            LocalizedString.failed
        case .finished:
            LocalizedString.completed
        case .pendingConfirmation:
            LocalizedString.pending
        }
    }
}
