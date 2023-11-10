// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

public enum HotWalletProduct: String {
    case swap
    case exchange
    case trading = "simplebuy"
    case rewards
    case staking
}

/// HotWalletAddressService responsible for fetching the hot wallet receive addresses
/// for different products and crypto currencies.
public protocol HotWalletAddressServiceAPI {
    /// Provides hot wallet receive addresses for different products and crypto currencies
    /// - Parameter cryptoCurrency: A Crypto Currency.
    /// - Parameter product: One of the hot-wallets supported products.
    /// - Returns: Non-failable Publisher that emits the receive address String for the requested
    /// product x crypto currency. If it is not available, emits nil.
    func hotWalletAddress(
        for cryptoCurrency: CryptoCurrency,
        product: HotWalletProduct
    ) -> AnyPublisher<String?, Never>
}

final class HotWalletAddressService: HotWalletAddressServiceAPI {

    private let app: AppProtocol
    private let accountRepository: NabuAccountsRepositoryProtocol

    init(
        app: AppProtocol = resolve(),
        accountRepository: NabuAccountsRepositoryProtocol = resolve()
    ) {
        self.app = app
        self.accountRepository = accountRepository
    }

    func hotWalletAddress(
        for cryptoCurrency: CryptoCurrency,
        product: HotWalletProduct
    ) -> AnyPublisher<String?, Never> {
        app.publisher(for: blockchain.app.configuration.hot.wallet.address.is.dynamic, as: Bool.self).replaceError(with: false)
            .flatMap { [accountRepository] isDynamic -> AnyPublisher<String?, Never> in
                guard isDynamic else {
                    return .just(nil)
                }
                return accountRepository.account(product: product, currency: networkNativeAsset(for: cryptoCurrency) ?? cryptoCurrency)
                    .map { account in account.agent?.address }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()           
            }
            .eraseToAnyPublisher()
    }
}

private func networkNativeAsset(
    for cryptoCurrency: CryptoCurrency,
    enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
) -> CryptoCurrency? {
    guard let network = enabledCurrenciesService.network(for: cryptoCurrency) else { return nil }
    return network.nativeAsset
}
