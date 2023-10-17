// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import ToolKit

public enum AssetProviderServiceError: Error, Equatable {
    case failedToFetchEthereumWallet
    case network(NabuNetworkError)
}

public struct NFTAssetPage: Equatable {
    public let assets: [Asset]
    public let cursor: String?

    init(_ response: AssetPageResponse) {
        self.assets = response.assets
        self.cursor = response.next
    }
}

public struct NFTAssets: Equatable {
    public struct Asset: Equatable, Identifiable {
        public let value: Asset_v2
        public let network: EVMNetwork

        public var id: String {
            "\(value.id).\(network.networkConfig.networkTicker)"
        }

        public var assetUrl: URL {
            let network = network.networkConfig.shortName.lowercased()
            var components = URLComponents()
            components.scheme = "https"
            components.host = "opensea.io"
            components.path = "/assets/\(network)/\(value.tokenAddress)/\(value.tokenId)"
            return components.url ?? "https://www.opensea.io"
        }

        public var creatorDisplayValue: String? {
            if let creator = value.creator, creator.contains("0x") {
                return value.creator?
                    .dropFirst(2)
                    .prefix(6)
                    .uppercased()
            } else {
                return value.creator
            }
        }
    }

    public let assets: [Asset]
}

public protocol AssetProviderServiceAPI {
    var address: AnyPublisher<String, AssetProviderServiceError> { get }
    func fetchAssets() -> AnyPublisher<NFTAssets, AssetProviderServiceError>
    func fetchAssetsFromEthereumAddress() -> AnyPublisher<NFTAssetPage, AssetProviderServiceError>
    func fetchAssetsFromEthereumAddressWithCursor(_ cursor: String) -> AnyPublisher<NFTAssetPage, AssetProviderServiceError>
}

public final class AssetProviderService: AssetProviderServiceAPI {

    private let repository: AssetProviderRepositoryAPI
    private let enabledCurrencies: EnabledCurrenciesServiceAPI
    private let ethereumWalletAddressPublisher: AnyPublisher<String, Error>

    public var address: AnyPublisher<String, AssetProviderServiceError> {
        ethereumWalletAddressPublisher
            .replaceError(
                with: AssetProviderServiceError.failedToFetchEthereumWallet
            )
            .eraseToAnyPublisher()
    }

    public init(
        repository: AssetProviderRepositoryAPI,
        enabledCurrencies: EnabledCurrenciesServiceAPI,
        ethereumWalletAddressPublisher: AnyPublisher<String, Error>
    ) {
        self.repository = repository
        self.enabledCurrencies = enabledCurrencies
        self.ethereumWalletAddressPublisher = ethereumWalletAddressPublisher
    }

    /// At the time of writing this, backend does not have a way to send network information per NFT
    /// so we fetch each network separately and combine the results
    public func fetchAssets() -> AnyPublisher<NFTAssets, AssetProviderServiceError> {
        ethereumWalletAddressPublisher
            .replaceError(
                with: AssetProviderServiceError.failedToFetchEthereumWallet
            )
            .flatMap { [repository, enabledCurrencies] address in
                enabledCurrencies.allEnabledEVMNetworks
                    .publisher
                    .flatMap { network in
                        repository.fetchAssets(address: address, network: network.networkConfig.networkTicker)
                            .mapError(AssetProviderServiceError.network)
                            .map { assets -> [NFTAssets.Asset] in
                                assets.nfts
                                    .filter(\.media.isNotNil)
                                    .map { asset in
                                        NFTAssets.Asset(value: asset, network: network)
                                    }
                            }
                            .replaceError(with: [])
                    }
                    .collect()
                    .map { value -> NFTAssets in
                        let assets = value.flatMap { $0 }
                        return NFTAssets(assets: assets)
                    }
            }
            .eraseToAnyPublisher()
    }

    public func fetchAssetsFromEthereumAddress()
        -> AnyPublisher<NFTAssetPage, AssetProviderServiceError>
    {
        ethereumWalletAddressPublisher
            .replaceError(
                with: AssetProviderServiceError.failedToFetchEthereumWallet
            )
            .flatMap { [repository] address in
                repository
                    .fetchAssetsFromEthereumAddress(address)
                    .map(NFTAssetPage.init)
                    .mapError(AssetProviderServiceError.network)
            }
            .eraseToAnyPublisher()
    }

    public func fetchAssetsFromEthereumAddressWithCursor(
        _ cursor: String
    ) -> AnyPublisher<NFTAssetPage, AssetProviderServiceError> {
        ethereumWalletAddressPublisher
            .replaceError(
                with: AssetProviderServiceError.failedToFetchEthereumWallet
            )
            .flatMap { [repository] address in
                repository
                    .fetchAssetsFromEthereumAddress(address, pageKey: cursor)
                    .map(NFTAssetPage.init)
                    .mapError(AssetProviderServiceError.network)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Preview Helper

extension AssetProviderService {

    public static var previewEmpty: AssetProviderService {
        AssetProviderService(
            repository: PreviewAssetProviderRepository(),
            enabledCurrencies: PreviewEnabledCurrenciesService(),
            ethereumWalletAddressPublisher: .empty()
        )
    }
}
