// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import ToolKit

public protocol AssetLoaderAPI {
    func initAndPreload() -> AnyPublisher<Void, Never>

    var loadedAssets: [CryptoAsset] { get }

    var pkw: PassthroughSubject<[CryptoAsset], Never> { get }
    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset? { get }
}

/// An AssetLoaderAPI that loads some CryptoAssets straight away, and lazy load others.
final class AssetLoader: AssetLoaderAPI {

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
    private let currenciesService: EnabledCurrenciesServiceAPI
    private let custodialCryptoAssetFactory: CustodialCryptoAssetFactoryAPI
    private let evmAssetFactory: EVMAssetFactoryAPI
    private let erc20AssetFactory: ERC20AssetFactoryAPI
    private let storage: Atomic<[CryptoCurrency: CryptoAsset]> = Atomic([:])
    private var subscription: AnyCancellable?

    let pkw = PassthroughSubject<[CryptoAsset], Never>()

    // MARK: Init

    init(
        app: AppProtocol,
        currenciesService: EnabledCurrenciesServiceAPI,
        evmAssetFactory: EVMAssetFactoryAPI,
        erc20AssetFactory: ERC20AssetFactoryAPI,
        custodialCryptoAssetFactory: CustodialCryptoAssetFactoryAPI
    ) {
        self.app = app
        self.currenciesService = currenciesService
        self.evmAssetFactory = evmAssetFactory
        self.erc20AssetFactory = erc20AssetFactory
        self.custodialCryptoAssetFactory = custodialCryptoAssetFactory
        self.subscription = firstPKWSwitch(app: app)
            .flatMap { [loadNonCustodial] in
                loadNonCustodial()
            }
            .sink(receiveValue: pkw.send)
    }

    // MARK: Methods

    func initAndPreload() -> AnyPublisher<Void, Never> {
        preloadCustodial()
    }

    /// Load a Custodial CryptoAsset for any currency with CustodialWalletBalance product.
    private func preloadCustodial() -> AnyPublisher<Void, Never> {
        Deferred { [storage, currenciesService, custodialCryptoAssetFactory] in
            Future { fulfill in
                let currencies: [CryptoCurrency] = currenciesService
                    .allEnabledCryptoCurrencies
                    .filter(\.hasCustodialWalletBalanceProduct)
                let assets: [CryptoAsset] = currencies
                    .map { cryptoCurrency in
                        custodialCryptoAssetFactory.custodialCryptoAsset(
                            cryptoCurrency: cryptoCurrency
                        )
                    }
                let assetsPrint = currencies.map(\.code).joined(separator: " ")
                print("🫂 AssetLoader: custodial: \(assetsPrint)")
                storage.mutate { storage in
                    // Do not replace an existing asset with new values.
                    // This cover a scenarion where a NC CryptoAsset is already loaded for a given currency.
                    storage.merge(
                        assets.dictionary(keyedBy: \.asset),
                        uniquingKeysWith: { lhs, _ in lhs }
                    )
                }
                fulfill(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    private func loadNonCustodial() -> AnyPublisher<[CryptoAsset], Never> {
        Deferred { [currenciesService, evmAssetFactory, storage, erc20AssetFactory] in
            Future { fulfill in
                let loadedERC20: [CryptoCurrency] = storage.value.keys.filter(\.isERC20)
                let evmNetworks: [String: EVMNetwork] = currenciesService
                    .allEnabledEVMNetworks
                    .filter(\.hasNonCustodialSupport)
                    .dictionary(keyedBy: \.networkConfig.networkTicker)

                // Crypto Assets for coins with Non Custodial support (BTC, BCH, XLM)
                // They are inject through DIKit.
                let knownCoins: [CryptoCurrency] = [.bitcoin, .bitcoinCash, .stellar]
                let nonCustodialAssets: [CryptoAsset] = knownCoins
                    .map { cryptoCurrency -> CryptoAsset in
                        DIKit.resolve(tag: cryptoCurrency)
                    }

                // Crypto Assets for EVM networks (native token) with Non Custodial support
                let evmAssets: [CryptoAsset] = evmNetworks
                    .values
                    .map(evmAssetFactory.evmAsset(network:))

                // Crypto Assets for any ERC20 currency that has alraedy been loaded to storage.
                let erc20Assets: [CryptoAsset] = loadedERC20
                    .compactMap { erc20 -> CryptoAsset? in
                        guard
                            let parentChain = erc20.assetModel.kind.erc20ParentChain,
                            let network = evmNetworks[parentChain]
                        else {
                            return nil
                        }
                        return erc20AssetFactory.erc20Asset(network: network, erc20Token: erc20.assetModel)
                    }

                let coinsPrint = nonCustodialAssets.map(\.asset.code).joined(separator: " ")
                print("🫂 AssetLoader: noncustodial: coins: \(coinsPrint)")
                let evmPrint = evmAssets.map(\.asset.code).joined(separator: " ")
                print("🫂 AssetLoader: noncustodial: evms: \(evmPrint)")
                let erc20Print = erc20Assets.map(\.asset.code).joined(separator: " ")
                print("🫂 AssetLoader: noncustodial: erc20: \(erc20Print)")

                storage.mutate { storage in
                    storage.merge(
                        nonCustodialAssets.dictionary(keyedBy: \.asset),
                        uniquingKeysWith: { _, rhs in rhs }
                    )
                    storage.merge(
                        evmAssets.dictionary(keyedBy: \.asset),
                        uniquingKeysWith: { _, rhs in rhs }
                    )
                    storage.merge(
                        erc20Assets.dictionary(keyedBy: \.asset),
                        uniquingKeysWith: { _, rhs in rhs }
                    )
                }
                fulfill(.success(nonCustodialAssets + evmAssets))
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Subscript

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset? {
        storage.mutateAndReturn { [erc20AssetFactory, custodialCryptoAssetFactory, currenciesService] storage in
            guard let cryptoAsset = storage[cryptoCurrency] else {
                if let cryptoAsset: CryptoAsset = createCryptoAsset(
                    cryptoCurrency: cryptoCurrency,
                    erc20AssetFactory: erc20AssetFactory,
                    custodialCryptoAssetFactory: custodialCryptoAssetFactory,
                    currenciesService: currenciesService
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
    custodialCryptoAssetFactory: CustodialCryptoAssetFactoryAPI,
    currenciesService: EnabledCurrenciesServiceAPI
) -> CryptoAsset? {
    switch cryptoCurrency.assetModel.kind {
    case .coin, .celoToken:
        print("🫂 AssetLoader: load: custodial: \(cryptoCurrency.code)")
        return custodialCryptoAssetFactory.custodialCryptoAsset(
            cryptoCurrency: cryptoCurrency
        )
    case .erc20:
        if
            let network = currenciesService.network(for: cryptoCurrency),
            network.hasNonCustodialSupport
        {
            print("🫂 AssetLoader: load: erc20 noncustodial: \(cryptoCurrency.code)")
            return erc20AssetFactory.erc20Asset(network: network, erc20Token: cryptoCurrency.assetModel)
        } else {
            print("🫂 AssetLoader: load: erc20 custodial: \(cryptoCurrency.code)")
            return custodialCryptoAssetFactory.custodialCryptoAsset(
                cryptoCurrency: cryptoCurrency
            )
        }
    case .fiat:
        fatalError("impossible")
    }
}

extension CryptoCurrency {
    fileprivate var hasCustodialWalletBalanceProduct: Bool {
        supports(product: .custodialWalletBalance)
    }
}

extension EVMNetwork {
    fileprivate var hasNonCustodialSupport: Bool {
        networkConfig.nodeURL != nil
    }
}

/// Emits a Void when app mode is first switched to PKW.
private func firstPKWSwitch(app: AppProtocol) -> AnyPublisher<Void, Never> {
    app.on(blockchain.app.coin.core.load.pkw.assets)
        .mapToVoid()
        .merge(
            with: app
                .publisher(for: blockchain.app.mode, as: AppMode.self)
                .filter(\.value == .pkw)
                .mapToVoid()
        )
        .prefix(1)
        .eraseToAnyPublisher()
}
