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
    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError>
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

    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        let publishers: [AnyPublisher<Result<Void, ERC20CryptoAssetServiceError>, Never>] = enabledCurrenciesService
            .allEnabledEVMNetworks
            .map(initializeNetwork)
            .map { $0.result() }
        return publishers
            .zip()
            .flatMap { results -> AnyPublisher<Void, ERC20CryptoAssetServiceError> in
                guard let error: ERC20CryptoAssetServiceError = results.map(\.failure).compacted().first else {
                    return .just(())
                }
                return .failure(error)
            }
            .eraseToAnyPublisher()
    }

    private func initializeNetwork(_ evmNetwork: EVMNetwork) -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        guard enabledCurrenciesService.allEnabledCryptoCurrencies.contains(evmNetwork.nativeAsset) else {
            return .just(())
        }
        return Deferred { [coincore] in
            Just(coincore[evmNetwork.nativeAsset])
        }
        .flatMap { asset in
            asset?
                .defaultAccount
                .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
                .flatMap { account -> AnyPublisher<Void, ERC20CryptoAssetServiceError> in
                    self.initialize(account: account, network: evmNetwork.networkConfig).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher() ?? .just(())
        }
        .eraseToAnyPublisher()
    }

    private func initialize(
        account: SingleAccount,
        network: EVMNetworkConfig
    ) -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        account.receiveAddress
            .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadReceiveAddress)
            .flatMap { [accountsRepository] receiveAddress in
                accountsRepository
                    .tokens(for: receiveAddress.address, network: network, forceFetch: false)
                    .replaceError(with: ERC20CryptoAssetServiceError.failedToFetchTokens)
            }
            .handleEvents(
                receiveOutput: { [coincore] response -> Void in
                    // For each ERC20 token present in the response.
                    response.keys.forEach { currency in
                        // Gets its CryptoAsset from CoinCore to allow it to be preloaded.
                        _ = coincore[currency]
                    }
                }
            )
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
