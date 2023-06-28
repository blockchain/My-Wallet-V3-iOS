// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol DelegatedCustodyBalanceRepositoryAPI {
    var balances: AnyPublisher<DelegatedCustodyBalances, Error> { get }
    var balancesStream: AnyPublisher<Result<DelegatedCustodyBalances, Error>, Never> { get }
}
