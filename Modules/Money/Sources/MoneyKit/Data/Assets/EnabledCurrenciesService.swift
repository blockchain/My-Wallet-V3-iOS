// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainNamespace
import Combine
import DIKit
import Extensions
import Foundation

public final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    public static let `default`: EnabledCurrenciesServiceAPI = {
        let app: AppProtocol = runningApp
        return EnabledCurrenciesService(
            networkConfigRepository: NetworkConfigRepository.default,
            app: runningApp,
            repository: AssetsRepository.default
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

    private var nonCustodialCryptoCurrencies: [CryptoCurrency] {
        var base: [CryptoCurrency] = [
            .bitcoin,
            .ethereum,
            .bitcoinCash,
            .stellar
        ]

        // Add 'coin' items for which EVM networks are enabled. (eg Polygon/Avalanche native assets)
        let enabledEVMs = networkConfigRepository.evmConfigs.map(\.nativeAsset)
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
        let enabledEVMs = networkConfigRepository.evmConfigs.map(\.nativeAsset)
        return repository.otherERC20Assets
            .filter { model in
                model.kind.erc20ParentChain.flatMap(enabledEVMs.contains) ?? false
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

    private lazy var allEnabledEVMNetworksLazy: [EVMNetwork] = networkConfigRepository.evmConfigs.compactMap { network -> EVMNetwork? in
        guard let nativeAsset = allEnabledCryptoCurrencies.first(where: { $0.code == network.nativeAsset }) else {
            return nil
        }
        return EVMNetwork(networkConfig: network, nativeAsset: nativeAsset)
    }


    private let allEnabledCryptoCurrenciesLock = NSLock()
    private let allEnabledCurrenciesLock = NSLock()
    private let allEnabledEVMNetworksLock = NSLock()

    private let app: AppProtocol
    private let networkConfigRepository: NetworkConfigRepositoryAPI
    private let repository: AssetsRepositoryAPI

    // MARK: Init

    init(
        networkConfigRepository: NetworkConfigRepositoryAPI,
        app: AppProtocol,
        repository: AssetsRepositoryAPI
    ) {
        self.networkConfigRepository = networkConfigRepository
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

public struct UnifiedBalanceMockConfig: Codable, Hashable {
    public let contract_address, name, code, logo_url: String
}

public func unifiedBalanceMock(app: AppProtocol) -> UnifiedBalanceMockConfig? {
    let isEnabled: Bool = app.state.get(
        blockchain.app.configuration.unified.balances.mock.is.enabled,
        as: Bool.self,
        or: false
    )
    guard isEnabled, BuildFlag.isInternal else {
        return nil
    }
    let config = try? app.remoteConfiguration.get(
        blockchain.app.configuration.unified.balances.mock.config,
        as: UnifiedBalanceMockConfig.self
    )
    return config
}

public func unifiedBalanceMockPublisher(app: AppProtocol) -> AnyPublisher<UnifiedBalanceMockConfig?, Never> {
    var isEnabled: AnyPublisher<Bool, Never> {
        app.publisher(
            for: blockchain.app.configuration.unified.balances.mock.is.enabled,
            as: Bool.self
        )
        .map(\.value)
        .replaceNil(with: false)
        .prefix(1)
        .eraseToAnyPublisher()
    }
    var config: AnyPublisher<UnifiedBalanceMockConfig?, Never> {
        app.publisher(
            for: blockchain.app.configuration.unified.balances.mock.config,
            as: UnifiedBalanceMockConfig.self
        )
        .map(\.value)
        .prefix(1)
        .eraseToAnyPublisher()
    }
    guard BuildFlag.isInternal else {
        return .just(nil)
    }
    return isEnabled.flatMapIf(then: config, else: .just(nil))
}
