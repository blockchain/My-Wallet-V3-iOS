// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import EthereumKit
import MoneyKit
import ToolKit
import UnifiedActivityDomain

final class PendingTransactionRepository: PendingTransactionRepositoryAPI {

    private let repository: UnifiedActivityRepositoryAPI

    init(
        repository: UnifiedActivityRepositoryAPI
    ) {
        self.repository = repository
    }

    func isWaitingOnTransaction(
        network: EVMNetworkConfig
    ) -> AnyPublisher<Bool, Never> {
        repository
            .pendingActivity
            .map { (activity: [ActivityEntry]) -> Bool in
                activity.contains(where: { entry in
                    let hourDiff = Calendar.current.dateComponents([.hour], from: entry.date, to: Date()).hour ?? 0
                    return entry.network == network.networkTicker && hourDiff <= 2
                })
            }
            .first()
            .eraseToAnyPublisher()
    }
}
