// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ERC20Kit
import EthereumKit
import MoneyKit
import PlatformKit
import ToolKit

final class ERC20BalanceServiceMock: ERC20BalanceServiceAPI {

    // MARK: - Private Properties

    var underlyingBalance: CryptoValue!

    // MARK: - Setup

    /// Creates a mock ERC-20 balance service.
    ///
    /// - Parameter cryptoCurrency: An ERC-20 crypto currency.
    init() {}

    // MARK: - Internal Methods

    func balance(
        for address: EthereumAddress,
        cryptoCurrency: CryptoCurrency,
        network: EVMNetworkConfig
    ) -> AnyPublisher<CryptoValue, ERC20TokenAccountsError> {
        .just(underlyingBalance)
    }

    func balanceStream(
        for address: EthereumAddress,
        cryptoCurrency: CryptoCurrency,
        network: EVMNetworkConfig
    ) -> StreamOf<CryptoValue, ERC20TokenAccountsError> {
        .just(.success(underlyingBalance))
    }
}
