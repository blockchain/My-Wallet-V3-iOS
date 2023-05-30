// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol BlockchainAccountActivity {
    var activity: AnyPublisher<[ActivityItemEvent], Error> { get }
}
