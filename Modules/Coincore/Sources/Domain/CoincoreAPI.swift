// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit

/// Types adopting the `CoincoreAPI` should provide a way to retrieve fiat and crypto accounts
public protocol CoincoreAPI {

    /// Provides access to fiat and crypto custodial and non custodial assets.
    func allAccounts(filter: AssetFilter) -> AnyPublisher<AccountGroup, CoincoreError>

    func accounts(
        filter: AssetFilter,
        where isIncluded: @escaping (BlockchainAccount) -> Bool
    ) -> AnyPublisher<[BlockchainAccount], Error>

    func accounts(
        where isIncluded: @escaping (BlockchainAccount) -> Bool
    ) -> AnyPublisher<[BlockchainAccount], Error>

    var allAssets: [Asset] { get }
    var fiatAsset: Asset { get }
    var cryptoAssets: [CryptoAsset] { get }

    /// Initialize any assets prior being available
    func initialize() -> AnyPublisher<Void, CoincoreError>

    /// Provides an array of `SingleAccount` instances for the specified source account and the given action.
    /// - Parameters:
    ///   - sourceAccount: A `BlockchainAccount` to be used as the source account
    ///   - action: An `AssetAction` to determine the transaction targets.
    func getTransactionTargets(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], CoincoreError>

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset? { get }

    func account(_ identifier: String) -> AnyPublisher<BlockchainAccount?, Never>
}

extension CoincoreAPI {

    public func fiatAccount(
        for currency: FiatCurrency,
        fiatCustodialAccountFactory: FiatCustodialAccountFactoryAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) -> FiatAccount? {
        let accounts = enabledCurrenciesService.allEnabledFiatCurrencies.set
        guard accounts.contains(currency) else { return nil }
        return fiatCustodialAccountFactory.fiatCustodialAccount(fiatCurrency: currency)
    }

    public func cryptoTradingAccount(
        for currency: CryptoCurrency,
        cryptoTradingAccountFactory: CryptoTradingAccountFactoryAPI = resolve()
    ) -> CryptoAccount? {
        guard currency.supports(product: .custodialWalletBalance), let asset = self[currency] else { return nil }
        return cryptoTradingAccountFactory.cryptoTradingAccount(
            cryptoCurrency: currency,
            addressFactory: asset.addressFactory
        )
    }
}
