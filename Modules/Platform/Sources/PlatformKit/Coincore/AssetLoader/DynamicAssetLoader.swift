// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Foundation
import MoneyKit
import ToolKit

protocol AssetLoader {
    func initAndPreload() -> AnyPublisher<Void, Never>

    var loadedAssets: [CryptoAsset] { get }

    var pkw: PassthroughSubject<[CryptoAsset], Never> { get }
    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset? { get }
}

/// An AssetLoader that loads some CryptoAssets straight away, and lazy load others.
final class DynamicAssetLoader: AssetLoader {

    // MARK: Properties

    var loadedAssets: [CryptoAsset] {
        storage.value
            .sorted { lhs, rhs in
                lhs.key < rhs.key
            }
            .map(\.value)
    }

    // MARK: Private Properties

    private let app: AppProtocol
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let evmAssetFactory: EVMAssetFactoryAPI
    private let erc20AssetFactory: ERC20AssetFactoryAPI
    private let storage: Atomic<[CryptoCurrency: CryptoAsset]> = Atomic([:])
    private let evmNetworksStorage: Atomic<[String: EVMNetwork]> = Atomic([:])

    let pkw = PassthroughSubject<[CryptoAsset], Never>()
    private var subscription: AnyCancellable?

    // MARK: Init

    init(
        app: AppProtocol,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        evmAssetFactory: EVMAssetFactoryAPI,
        erc20AssetFactory: ERC20AssetFactoryAPI
    ) {
        self.app = app
        self.enabledCurrenciesService = enabledCurrenciesService
        self.evmAssetFactory = evmAssetFactory
        self.erc20AssetFactory = erc20AssetFactory
        self.subscription = app.on(blockchain.app.coin.core.load.pkw.assets)
            .prefix(1)
            .mapToVoid()
            .map { [enabledCurrenciesService, evmAssetFactory, storage] () -> [CryptoAsset] in

                let allEnabledCryptoCurrencies = enabledCurrenciesService.allEnabledCryptoCurrencies
                let allEnabledEVMNetworks = enabledCurrenciesService.allEnabledEVMNetworks

                let nonCustodialCoinCodes = NonCustodialCoinCode.allCases
                    .filter { $0 != .ethereum }
                    .map(\.rawValue)

                // Crypto Assets for coins with Non Custodial support (BTC, BCH, ETH, XLM)
                let nonCustodialAssets: [CryptoAsset] = allEnabledCryptoCurrencies
                    .filter(\.isCoin)
                    .filter { nonCustodialCoinCodes.contains($0.code) }
                    .map { cryptoCurrency -> CryptoAsset in
                        DIKit.resolve(tag: cryptoCurrency)
                    }
                // Load EVM CryptoAsset

                let evmAssets: [CryptoAsset] = allEnabledEVMNetworks.map(evmAssetFactory.evmAsset(network:))

                storage.mutate { storage in
                    nonCustodialAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                    evmAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                }

                return nonCustodialAssets + evmAssets
            }
            .sink(receiveValue: pkw.send)
    }

    // MARK: Methods

    /// Pre loads into Coincore (in memory) all Coin non-custodial assets and any other asset that has Custodial support.
    func initAndPreload() -> AnyPublisher<Void, Never> {
        Deferred { [storage, enabledCurrenciesService, erc20AssetFactory, evmNetworksStorage] in
            Future { fulfill in
                let allEnabledCryptoCurrencies = enabledCurrenciesService.allEnabledCryptoCurrencies
                let allEnabledEVMNetworks = enabledCurrenciesService.allEnabledEVMNetworks
                let evmNetworksHashMap = allEnabledEVMNetworks.reduce(into: [:]) { partialResult, network in
                    partialResult[network.networkConfig.networkTicker] = network
                }

                evmNetworksStorage.mutate { storage in storage = evmNetworksHashMap }
                storage.mutate { storage in storage.removeAll() }

                let custodialCryptoCurrencies: [CryptoCurrency] = allEnabledCryptoCurrencies
                    .filter { cryptoCurrency in
                        cryptoCurrency.supports(product: .custodialWalletBalance)
                    }

                // Crypto Assets for any currency with Custodial support.
                let custodialAssets: [CryptoAsset] = custodialCryptoCurrencies
                    .compactMap { [erc20AssetFactory] cryptoCurrency -> CryptoAsset? in
                        createCryptoAsset(
                            cryptoCurrency: cryptoCurrency,
                            erc20AssetFactory: erc20AssetFactory,
                            evmNetworks: evmNetworksHashMap
                        )
                    }

                storage.mutate { storage in
                    for asset in custodialAssets {
                        storage[asset.asset] = asset
                    }
                }
                fulfill(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Subscript

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset? {
        let evmNetworksHashMap = evmNetworksStorage.value
        return storage.mutateAndReturn { [erc20AssetFactory] storage in
            guard let cryptoAsset = storage[cryptoCurrency] else {
                if let cryptoAsset: CryptoAsset = createCryptoAsset(
                    cryptoCurrency: cryptoCurrency,
                    erc20AssetFactory: erc20AssetFactory,
                    evmNetworks: evmNetworksHashMap
                ) {
                    storage[cryptoCurrency] = cryptoAsset
                    return cryptoAsset
                }
                return nil
            }
            return cryptoAsset
        }
    }
}

private func createCryptoAsset(
    cryptoCurrency: CryptoCurrency,
    erc20AssetFactory: ERC20AssetFactoryAPI,
    evmNetworks: [String: EVMNetwork]
) -> CryptoAsset? {
    switch cryptoCurrency.assetModel.kind {
    case .coin, .celoToken:
        return CustodialCryptoAsset(asset: cryptoCurrency)
    case .erc20(_, let parentChain):
        guard let network = evmNetworks[parentChain] else {
            return nil
        }
        return erc20AssetFactory.erc20Asset(network: network, erc20Token: cryptoCurrency.assetModel)
    case .fiat:
        impossible()
    }
}
