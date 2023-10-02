// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import EthereumKit
import MoneyKit
import PlatformKit

public enum ERC20CryptoAssetServiceError: LocalizedError, Equatable {
    case failedToLoadDefaultAccount
    case failedToLoadReceiveAddress
    case failedToFetchTokens

    public var errorDescription: String? {
        switch self {
        case .failedToLoadDefaultAccount:
            return "Failed to load default account."
        case .failedToLoadReceiveAddress:
            return "Failed to load receive address."
        case .failedToFetchTokens:
            return "Failed to load ERC20 Assets."
        }
    }
}

/// Service to initialise required ERC20 CryptoAsset.
public protocol ERC20CryptoAssetServiceAPI {

    func setupCoincore()
}

final class ERC20CryptoAssetService: ERC20CryptoAssetServiceAPI {

    private let accountsRepository: ERC20BalancesRepositoryAPI
    private let app: AppProtocol
    private let coincore: CoincoreAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    init(
        accountsRepository: ERC20BalancesRepositoryAPI,
        app: AppProtocol,
        coincore: CoincoreAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.accountsRepository = accountsRepository
        self.app = app
        self.coincore = coincore
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    func setupCoincore() {
        coincore.registerNonCustodialAssetLoader(handler: { [initialize] in
            initialize()
        })
    }

    private func initialize() -> AnyPublisher<[CryptoCurrency], Never> {
        let networks = enabledCurrenciesService.allEnabledEVMNetworks
        let publishers = networks
            .map(initializeNetwork)
            .map { $0.replaceError(with: []) }
        return publishers
            .zip()
            .map { values -> [CryptoCurrency] in
                values.flatMap { $0 }
            }
            .eraseToAnyPublisher()
    }

    private func initializeNetwork(_ evmNetwork: EVMNetwork) -> AnyPublisher<[CryptoCurrency], ERC20CryptoAssetServiceError> {
        guard enabledCurrenciesService.allEnabledCryptoCurrencies.contains(evmNetwork.nativeAsset) else {
            return .just([])
        }
        return Deferred { [coincore] in
            Just(coincore[evmNetwork.nativeAsset])
        }
        .flatMap { [initializeAsset] asset -> AnyPublisher<[CryptoCurrency], ERC20CryptoAssetServiceError> in
            guard let asset else { return .just([]) }
            return asset
                .defaultAccount
                .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
                .flatMap { account -> AnyPublisher<[CryptoCurrency], ERC20CryptoAssetServiceError> in
                    initializeAsset(account, evmNetwork.networkConfig)
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func initializeAsset(
        account: SingleAccount,
        network: EVMNetworkConfig
    ) -> AnyPublisher<[CryptoCurrency], ERC20CryptoAssetServiceError> {
        account.receiveAddress
            .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadReceiveAddress)
            .flatMap { [accountsRepository] receiveAddress in
                accountsRepository
                    .tokens(for: receiveAddress.address, network: network, forceFetch: false)
                    .replaceError(with: ERC20CryptoAssetServiceError.failedToFetchTokens)
            }
            .map(\.keys.array)
            .eraseToAnyPublisher()
    }
}
