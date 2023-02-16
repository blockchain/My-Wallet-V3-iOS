// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import MetadataKit
import PlatformKit
import ToolKit
import WalletCore
import WalletPayloadKit

public enum WalletAccountRepositoryError: Error {
    case missingWallet
    case failedToFetchAccount(Error)
}

public protocol EthereumWalletAccountRepositoryAPI {

    var defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError> { get }
}

protocol EthereumWalletRepositoryAPI {

    var ethereumEntry: AnyPublisher<EthereumEntryPayload?, WalletAccountRepositoryError> { get }

    func invalidateCache()

    func updateLabel(label: String) -> AnyPublisher<Void, Never>

    func updateLabels(on accounts: [EVMCryptoAccount]) -> AnyPublisher<Void, Never>
}

final class EthereumWalletAccountRepository: EthereumWalletAccountRepositoryAPI, EthereumWalletRepositoryAPI {

    // MARK: - Types

    private struct Key: Hashable {}

    // MARK: - EthereumWalletAccountRepositoryAPI

    let defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError>
    let ethereumEntry: AnyPublisher<EthereumEntryPayload?, WalletAccountRepositoryError>

    // MARK: - Private Properties

    private let cachedValue: CachedValueNew<
        Key,
        EthereumWallet,
        WalletAccountRepositoryError
    >
    private let walletMetadataEntryService: WalletMetadataEntryServiceAPI
    private let walletCoreHDWalletProvider: WalletCoreHDWalletProvider

    // MARK: - Init

    init(
        walletMetadataEntryService: WalletMetadataEntryServiceAPI = resolve(),
        walletCoreHDWalletProvider: @escaping WalletCoreHDWalletProvider = resolve()
    ) {
        self.walletMetadataEntryService = walletMetadataEntryService
        self.walletCoreHDWalletProvider = walletCoreHDWalletProvider

        let cache: AnyCache<Key, EthereumWallet> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ -> AnyPublisher<EthereumWallet, WalletAccountRepositoryError> in
                fetchOrCreateEthereumNatively(
                    metadataService: walletMetadataEntryService,
                    hdWalletProvider: walletCoreHDWalletProvider,
                    label: LocalizationConstants.Account.myWallet
                )
                .flatMap { entry -> AnyPublisher<EthereumWallet, WalletAssetFetchError> in
                    guard let ethereum = entry.ethereum else {
                        return .failure(.notInitialized)
                    }

                    let accounts = ethereum.accounts.enumerated().map { index, account in
                        EthereumWalletAccount(
                            index: index,
                            publicKey: account.address,
                            label: account.label,
                            archived: account.archived
                        )
                    }
                    return .just(EthereumWallet(entry: entry, accounts: accounts))
                }
                .mapError(WalletAccountRepositoryError.failedToFetchAccount)
                .eraseToAnyPublisher()
            }
        )

        self.defaultAccount = cachedValue.get(key: Key())
            .map(\.accounts)
            .compactMap(\.first)
            .eraseToAnyPublisher()

        self.ethereumEntry = cachedValue.get(key: Key())
            .map(\.entry)
            .eraseToAnyPublisher()
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }

    func updateLabel(label: String) -> AnyPublisher<Void, Never> {
        ethereumEntry
            .catch { _ -> AnyPublisher<EthereumEntryPayload?, Never> in
                .just(nil)
            }
            .flatMap { [walletMetadataEntryService] payload -> AnyPublisher<Void, Never> in
                guard let ethereumEntry = payload?.ethereum else {
                    return .just(())
                }
                let account: EthereumEntryPayload.Ethereum.Account? = ethereumEntry.accounts.first
                if let account {
                    let updatedAccount = EthereumEntryPayload.Ethereum.Account(
                        address: account.address,
                        archived: account.archived,
                        correct: account.correct,
                        label: label
                    )
                    let updatedEntry = EthereumEntryPayload.Ethereum(
                        accounts: [updatedAccount],
                        defaultAccountIndex: ethereumEntry.defaultAccountIndex,
                        erc20: ethereumEntry.erc20,
                        hasSeen: ethereumEntry.hasSeen,
                        lastTxTimestamp: ethereumEntry.lastTxTimestamp,
                        transactionNotes: ethereumEntry.transactionNotes
                    )
                    let updatedPayload = EthereumEntryPayload(ethereum: updatedEntry)
                    return walletMetadataEntryService.save(node: updatedPayload)
                        .first()
                        .catch { _ in .noValue }
                        .mapError(to: Never.self)
                        .mapToVoid()
                        .eraseToAnyPublisher()
                }
                return .just(())
            }
            .handleEvents(
                receiveCompletion: { [cachedValue] _ in
                    cachedValue.invalidateCache()
                }
            )
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func updateLabels(on accounts: [EVMCryptoAccount]) -> AnyPublisher<Void, Never> {
        ethereumEntry
            .catch { _ -> AnyPublisher<EthereumEntryPayload?, Never> in
                .just(nil)
            }
            .flatMap { [walletMetadataEntryService] payload -> AnyPublisher<Void, Never> in
                guard let ethereumEntry = payload?.ethereum else {
                    return .just(())
                }
                // though accounts are defined as an array we never have more that one
                let updatedAccounts = ethereumEntry.accounts.map { account in
                    if let label = accounts.first(where: { $0.publicKey == account.address })?.newForcedUpdateLabel {
                        return account.updateLabel(label)
                    } else {
                        return account
                    }
                }
                let updatedEntry = EthereumEntryPayload.Ethereum(
                    accounts: updatedAccounts,
                    defaultAccountIndex: ethereumEntry.defaultAccountIndex,
                    erc20: ethereumEntry.erc20,
                    hasSeen: ethereumEntry.hasSeen,
                    lastTxTimestamp: ethereumEntry.lastTxTimestamp,
                    transactionNotes: ethereumEntry.transactionNotes
                )
                let updatedPayload = EthereumEntryPayload(ethereum: updatedEntry)
                return walletMetadataEntryService.save(node: updatedPayload)
                    .first()
                    .catch { _ in .noValue }
                    .mapError(to: Never.self)
                    .mapToVoid()
                    .eraseToAnyPublisher()
            }
            .mapToVoid()
            .handleEvents(
                receiveOutput: { [cachedValue] _ in
                    cachedValue.invalidateCache()
                }
            )
            .eraseToAnyPublisher()
    }
}
