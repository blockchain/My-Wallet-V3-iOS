// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import ToolKit

public protocol PendingTransactionRepositoryAPI {
    func isWaitingOnTransaction(
        network: EVMNetworkConfig
    ) -> AnyPublisher<Bool, Never>
}
