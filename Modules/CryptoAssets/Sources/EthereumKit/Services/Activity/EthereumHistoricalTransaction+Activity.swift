// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension EthereumHistoricalTransaction {
    var activityItemEvent: TransactionalActivityItemEvent {
        var status: TransactionalActivityItemEvent.EventStatus
        switch state {
        case .confirmed,
             .replaced:
            status = .complete
        case .pending:
            status = .pending(
                confirmations: .init(
                    current: confirmations,
                    total: EthereumHistoricalTransaction.requiredConfirmations
                )
            )
        }
        return .init(
            identifier: identifier,
            transactionHash: transactionHash,
            creationDate: createdAt,
            status: status,
            type: direction == .receive ? .receive : .send,
            amount: amount,
            fee: fee
        )
    }
}
