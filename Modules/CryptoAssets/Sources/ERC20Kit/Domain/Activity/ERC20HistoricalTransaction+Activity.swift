// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension ERC20HistoricalTransaction {
    var activityItemEvent: TransactionalActivityItemEvent {
        // TODO: Confirmation Status
        .init(
            identifier: identifier,
            transactionHash: transactionHash,
            creationDate: createdAt,
            status: .complete,
            type: direction == .debit ? .receive : .send,
            amount: amount,
            fee: fee
        )
    }
}
