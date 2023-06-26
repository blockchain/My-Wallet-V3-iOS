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
    private let walletOptions: WalletOptionsAPI
    private let accountRepository: NabuAccountsRepositoryProtocol

    init(
        app: AppProtocol = resolve(),
        walletOptions: WalletOptionsAPI = resolve(),
        accountRepository: NabuAccountsRepositoryProtocol = resolve()
    ) {
        self.app = app
        self.walletOptions = walletOptions
        self.accountRepository = accountRepository
    }

    func hotWalletAddress(
        for cryptoCurrency: CryptoCurrency,
        product: HotWalletProduct
    ) -> AnyPublisher<String?, Never> {
        isWalletOptionsEnabled(cryptoCurrency: cryptoCurrency)
            .zip(app.publisher(for: blockchain.app.configuration.hot.wallet.address.is.dynamic, as: Bool.self).replaceError(with: false))
            .flatMap { [accountRepository, walletOptions] isWalletOptions, isDynamic -> AnyPublisher<String?, Never> in
                if isDynamic {
                    return accountRepository.account(product: product, currency: networkNativeAsset(for: cryptoCurrency) ?? cryptoCurrency)
                        .map { account in account.agent?.address }
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                } else if isWalletOptions {
                    return walletOptions.walletOptions
                        .asPublisher()
                        .map(\.hotWalletAddresses?[product.rawValue])
                        .map { addresses -> String? in
                            guard let main = mainChainCode(for: cryptoCurrency) else { return nil }
                            return addresses?[main]
                        }
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                } else {
                    return .just(nil)
                }
            }
            .eraseToAnyPublisher()
    }

    private func isWalletOptionsEnabled(cryptoCurrency: CryptoCurrency) -> AnyPublisher<Bool, Never> {
        guard mainChainCode(for: cryptoCurrency) != nil else {
            // No App support.
            return .just(false)
        }
        return app.remoteConfiguration.publisher(for: "ios_ff_hot_wallet_custodial").map(\.isYes).eraseToAnyPublisher()
    }
}

private func networkNativeAsset(for cryptoCurrency: CryptoCurrency, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) -> CryptoCurrency? {
    guard let network = enabledCurrenciesService.network(for: cryptoCurrency) else { return nil }
    return network.nativeAsset
}

private func mainChainCode(for cryptoCurrency: CryptoCurrency) -> String? {
    switch cryptoCurrency {
    case .ethereum:
        return Constants.ethKey
    case let model where model.assetModel.kind.erc20ParentChain == Constants.ethParentChain:
        return Constants.ethKey
    default:
        return nil
    }
}

private enum Constants {
    static let ethParentChain = "ETH"
    static let ethKey = "eth"
}
