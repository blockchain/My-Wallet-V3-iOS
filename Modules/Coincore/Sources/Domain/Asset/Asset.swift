// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol Asset: AnyObject {

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never>

    func transactionTargets(
        account: SingleAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], Never>

    /// Validates the given address
    /// - Parameter address: A `String` value of the address to be parse
    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never>
}
