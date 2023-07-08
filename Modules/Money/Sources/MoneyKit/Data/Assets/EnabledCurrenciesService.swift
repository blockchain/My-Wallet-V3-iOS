// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainNamespace
import DIKit
import Foundation

public final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    public static let `default`: EnabledCurrenciesServiceAPI = {
        let app: AppProtocol = runningApp
        let evmSupport = EVMSupport(app: app)
        return EnabledCurrenciesService(
            evmSupport: evmSupport,
            app: app,
            repository: AssetsRepository(
                fileLoader: FileLoader(
                    filePathProvider: FilePathProvider(
                        fileManager: .default
                    ),
                    jsonDecoder: .init()
                ),
                evmSupport: evmSupport
            )
        )
    }()

    // MARK: EnabledCurrenciesServiceAPI

    public let allEnabledFiatCurrencies: [FiatCurrency] = FiatCurrency.allEnabledFiatCurrencies

    public let bankTransferEligibleFiatCurrencies: [FiatCurrency] = [.USD, .ARS]

    public var allEnabledCurrencies: [CurrencyType] {
        defer { allEnabledCurrenciesLock.unlock() }
        allEnabledCurrenciesLock.lock()
        return allEnabledCurrenciesLazy
    }

    public var allEnabledCryptoCurrencies: [CryptoCurrency] {
        defer { allEnabledCryptoCurrenciesLock.unlock() }
        allEnabledCryptoCurrenciesLock.lock()
        return allEnabledCryptoCurrenciesLazy
    }

    public var allEnabledEVMNetworks: [EVMNetwork] {
        defer { allEnabledEVMNetworksLock.unlock() }
        allEnabledEVMNetworksLock.lock()
        return allEnabledEVMNetworksLazy
    }

    // MARK: Private Properties

    private var allEnabledEVMNetworkConfig: [EVMNetworkConfig] {
        defer { allEnabledEVMNetworkConfigLock.unlock() }
        allEnabledEVMNetworkConfigLock.lock()
        return allEnabledEVMNetworkConfigLazy
    }

    private var nonCustodialCryptoCurrencies: [CryptoCurrency] {
        var base: [CryptoCurrency] = [
            .bitcoin,
            .ethereum,
            .bitcoinCash,
            .stellar
        ]

        // Add 'coin' items for which EVM networks are enabled. (eg Polygon/Avalanche native assets)
        let enabledEVMs = allEnabledEVMNetworkConfig.map(\.nativeAsset)
        let evms: [CryptoCurrency] = repository.coinAssets
            .filter { item in !NonCustodialCoinCode.allCases.map(\.rawValue).contains(item.code) }
            .filter { item in enabledEVMs.contains(item.code) }
            .compactMap(\.cryptoCurrency)
            .sorted()
        base.append(contentsOf: evms)

        if let mock = unifiedBalanceMock(app: app) {
            let mockModel = AssetModel(
                code: mock.code,
                displayCode: mock.code,
                kind: .erc20(contractAddress: mock.contract_address, parentChain: "ETH"),
                name: "Mock \(mock.name)",
                precision: 18,
                products: [.privateKey],
                logoPngUrl: URL(string: mock.logo_url),
                spotColor: nil,
                sortIndex: 1
            )
            if let currency = mockModel.cryptoCurrency {
                base.append(currency)
            }
        }

        return base
    }

    private var custodialCurrencies: [CryptoCurrency] {
        repository.custodialAssets
            .filter { !NonCustodialCoinCode.allCases.map(\.rawValue).contains($0.code) }
            .compactMap(\.cryptoCurrency)
    }

    private var ethereumERC20Currencies: [CryptoCurrency] {
        repository.ethereumERC20Assets
            .compactMap(\.cryptoCurrency)
    }

    private var otherERC20Currencies: [CryptoCurrency] {
        repository.otherERC20Assets
            .filter { model in
                model.kind.erc20ParentChain
                    .flatMap(evmSupport.isEnabled(network:)) ?? false
            }
            .compactMap(\.cryptoCurrency)
    }

    private lazy var allEnabledCryptoCurrenciesLazy: [CryptoCurrency] = (
        nonCustodialCryptoCurrencies
            + custodialCurrencies
            + ethereumERC20Currencies
            + otherERC20Currencies
    )
    .unique
    .sorted()

    private lazy var allEnabledCurrenciesLazy: [CurrencyType] = allEnabledCryptoCurrencies.map(CurrencyType.crypto)
    + allEnabledFiatCurrencies.map(CurrencyType.fiat)

    private lazy var allEnabledEVMNetworkConfigLazy: [EVMNetworkConfig] = [EVMNetworkConfig.ethereum] + repositoryEnabledEVMs
    private lazy var allEnabledEVMNetworksLazy: [EVMNetwork] = allEnabledEVMNetworkConfig.compactMap { network -> EVMNetwork? in
        guard let nativeAsset = allEnabledCryptoCurrencies.first(where: { $0.code == network.nativeAsset }) else {
            return nil
        }
        return EVMNetwork(networkConfig: network, nativeAsset: nativeAsset)
    }

    private var repositoryEnabledEVMs: [EVMNetworkConfig] {
        repository.enabledEVMs
            .filter { $0.networkTicker != "ETH" }
            .filter { evmSupport.isEnabled(network: $0.networkTicker) }
    }

    private let allEnabledCryptoCurrenciesLock = NSLock()
    private let allEnabledCurrenciesLock = NSLock()
    private let allEnabledEVMNetworkConfigLock = NSLock()
    private let allEnabledEVMNetworksLock = NSLock()

    private let app: AppProtocol
    private let evmSupport: EVMSupportAPI
    private let repository: AssetsRepositoryAPI

    // MARK: Init

    init(
        evmSupport: EVMSupportAPI,
        app: AppProtocol,
        repository: AssetsRepositoryAPI
    ) {
        self.evmSupport = evmSupport
        self.app = app
        self.repository = repository
    }

    public func network(for cryptoCurrency: CryptoCurrency) -> EVMNetwork? {
        guard let erc20ParentChain = cryptoCurrency.assetModel.kind.erc20ParentChain else {
            return allEnabledEVMNetworks
                .first(where: { $0.nativeAsset.code == cryptoCurrency.code })
        }
        return allEnabledEVMNetworks
            .first(where: { $0.networkConfig.networkTicker == erc20ParentChain })
    }

    public func network(for chainId: String) -> EVMNetwork? {
        allEnabledEVMNetworks
            .first(where: { network in
                network.networkConfig.chainID == BigUInt(chainId)
            })
    }
}

extension [AssetModelProduct] {

    /// Whether the list of supported products causes its owner currency to be enabled in the wallet app.
    var enablesCurrency: Bool {
        contains { product in
            product.enablesCurrency
        }
    }
}

extension AssetModelProduct {

    /// Whether the current `AssetModelProduct` causes its owner currency to be enabled in the wallet app.
    fileprivate var enablesCurrency: Bool {
        switch self {
        case .custodialWalletBalance:
            return true
        default:
            return false
        }
    }
}

struct UnifiedBalanceMockConfig: Codable, Hashable {
    let contract_address, name, code, logo_url: String
}

private func unifiedBalanceMock(app: AppProtocol) -> UnifiedBalanceMockConfig? {
    let isEnabled: Bool = app.state.get(
        blockchain.app.configuration.unified.balances.mock.is.enabled,
        as: Bool.self,
        or: false
    )
    guard isEnabled else {
        return nil
    }
    let config = try? app.remoteConfiguration.get(
        blockchain.app.configuration.unified.balances.mock.config,
        as: UnifiedBalanceMockConfig.self
    )
    return config
}
