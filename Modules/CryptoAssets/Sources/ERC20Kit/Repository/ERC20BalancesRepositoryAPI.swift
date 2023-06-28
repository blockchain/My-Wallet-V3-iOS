// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

/// A repository in charge of getting ERC-20 token accounts associated with a given ethereum account address.
public protocol ERC20BalancesRepositoryAPI {

    /// Gets the ERC-20 token accounts associated with the given ethereum account address, optionally ignoring cached values.
    ///
    /// - Parameters:
    ///   - address:    The ethereum account address to get the ERC-20 token accounts for.
    ///   - forceFetch: Whether the cached values should be ignored.
    ///
    /// - Returns: A publisher that emits a `ERC20TokenAccounts` on success, or a `ERC20TokenAccountsError` on failure.
    func tokens(
        for address: String,
        network: EVMNetworkConfig,
        forceFetch: Bool
    ) -> AnyPublisher<ERC20TokenAccounts, Error>
}
