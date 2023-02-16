// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MetadataKit
import MoneyKit
import PlatformKit
import ToolKit
import WalletPayloadKit

enum StellarWalletAccountRepositoryError: Error {
    case saveFailure
    case mnemonicFailure(MnemonicAccessError)
    case metadataFetchError(WalletAssetFetchError)
    case failedToDeriveInput(Error)
}

protocol StellarWalletAccountRepositoryAPI {
    var defaultAccount: AnyPublisher<StellarWalletAccount?, Never> { get }
    func initializeMetadata() -> AnyPublisher<Void, StellarWalletAccountRepositoryError>
    func loadKeyPair() -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError>
    func updateLabel(_ label: String) -> AnyPublisher<Void, Never>
    func updateLabels(on accounts: [StellarCryptoAccount]) -> AnyPublisher<Void, Never>
}

final class StellarWalletAccountRepository: StellarWalletAccountRepositoryAPI {

    private struct Key: Hashable {}

    /// The default `StellarWallet`, will be nil if it has not yet been initialized
    var defaultAccount: AnyPublisher<StellarWalletAccount?, Never> {
        cachedValue.get(key: Key())
            .map(\.accounts.first)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    var entry: AnyPublisher<StellarEntryPayload?, Never> {
        cachedValue.get(key: Key())
            .map(\.entry)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private let keyPairDeriver: StellarKeyPairDeriver
    private let metadataEntryService: WalletMetadataEntryServiceAPI
    private let mnemonicAccessAPI: MnemonicAccessAPI
    private let cachedValue: CachedValueNew<
        Key,
        StellarWallet,
        StellarWalletAccountRepositoryError
    >

    init(
        keyPairDeriver: StellarKeyPairDeriver = .init(),
        metadataEntryService: WalletMetadataEntryServiceAPI,
        mnemonicAccessAPI: MnemonicAccessAPI
    ) {
        self.keyPairDeriver = keyPairDeriver
        self.metadataEntryService = metadataEntryService
        self.mnemonicAccessAPI = mnemonicAccessAPI

        let cache: AnyCache<Key, StellarWallet> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ -> AnyPublisher<StellarWallet, StellarWalletAccountRepositoryError> in
                metadataEntryService.fetchEntry(type: StellarEntryPayload.self)
                    .map { payload -> StellarWallet in
                        let accounts = payload.accounts
                            .enumerated()
                            .map { index, account in
                                StellarWalletAccount(
                                    index: index,
                                    publicKey: account.publicKey,
                                    label: account.label,
                                    archived: account.archived
                                )
                            }
                        return StellarWallet(entry: payload, accounts: accounts)
                    }
                    .mapError(StellarWalletAccountRepositoryError.metadataFetchError)
                    .eraseToAnyPublisher()
            }
        )
    }

    func initializeMetadata() -> AnyPublisher<Void, StellarWalletAccountRepositoryError> {
        metadataEntryService
            .fetchEntry(type: StellarEntryPayload.self)
            .mapToVoid()
            .catch { [createAndSaveStellarAccount] error -> AnyPublisher<Void, StellarWalletAccountRepositoryError> in
                guard case .fetchFailed(.loadMetadataError(.notYetCreated)) = error else {
                    return .failure(.metadataFetchError(error))
                }
                return createAndSaveStellarAccount()
            }
            .eraseToAnyPublisher()
    }

    func loadKeyPair() -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
        mnemonicAccessAPI
            .mnemonic
            .mapError(StellarWalletAccountRepositoryError.mnemonicFailure)
            .map(StellarKeyDerivationInput.init(mnemonic:))
            .flatMap { [keyPairDeriver] input in
                derive(input: input, deriver: keyPairDeriver)
            }
            .eraseToAnyPublisher()
    }

    func updateLabel(_ label: String) -> AnyPublisher<Void, Never> {
        entry
            .flatMap { [metadataEntryService] accountEntry -> AnyPublisher<Void, Never> in
                guard let payload = accountEntry else {
                    return .just(())
                }
                let account = payload.accounts.first
                if let account {
                    let updatedAccount = StellarEntryPayload.Account(
                        archived: account.archived,
                        label: label,
                        publicKey: account.publicKey
                    )
                    let updatedEntry = StellarEntryPayload(
                        accounts: [updatedAccount],
                        defaultAccountIndex: payload.defaultAccountIndex,
                        txNotes: payload.txNotes
                    )
                    return metadataEntryService.save(node: updatedEntry)
                        .first()
                        .catch { _ in .noValue }
                        .mapError(to: Never.self)
                        .mapToVoid()
                        .eraseToAnyPublisher()
                }

                return .just(())
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func updateLabels(on accounts: [StellarCryptoAccount]) -> AnyPublisher<Void, Never> {
        entry
            .flatMap { [metadataEntryService] payload -> AnyPublisher<Void, Never> in
                guard let stellarEntryPayload = payload else {
                    return .just(())
                }
                // though accounts are defined as an array we never have more that one
                let updatedAccounts = stellarEntryPayload.accounts.map { account in
                    if let label = accounts.first(where: { $0.publicKey == account.publicKey })?.newForcedUpdateLabel {
                        return account.updateLabel(label)
                    } else {
                        return account
                    }
                }
                let updatedEntry = StellarEntryPayload(
                    accounts: updatedAccounts,
                    defaultAccountIndex: stellarEntryPayload.defaultAccountIndex,
                    txNotes: stellarEntryPayload.txNotes
                )
                return metadataEntryService.save(node: updatedEntry)
                    .first()
                    .catch { _ in .noValue }
                    .mapError(to: Never.self)
                    .mapToVoid()
                    .eraseToAnyPublisher()
            }
            .handleEvents(
                receiveOutput: { [cachedValue] _ in
                    cachedValue.invalidateCache()
                }
            )
            .eraseToAnyPublisher()
    }

    // MARK: Private

    private func createAndSaveStellarAccount() -> AnyPublisher<Void, StellarWalletAccountRepositoryError> {
        loadKeyPair()
            .flatMap { [metadataEntryService] keyPair in
                saveNatively(
                    metadataEntryService: metadataEntryService,
                    keyPair: keyPair
                )
                .mapError { _ in StellarWalletAccountRepositoryError.saveFailure }
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

private func saveNatively(
    metadataEntryService: WalletMetadataEntryServiceAPI,
    keyPair: StellarKeyPair
) -> AnyPublisher<StellarKeyPair, StellarAccountError> {
    let account = StellarEntryPayload.Account(
        archived: false,
        label: CryptoCurrency.stellar.defaultWalletName,
        publicKey: keyPair.accountID
    )
    let payload = StellarEntryPayload(
        accounts: [account],
        defaultAccountIndex: 0,
        txNotes: [:]
    )
    return metadataEntryService.save(node: payload)
        .mapError { _ in StellarAccountError.unableToSaveNewAccount }
        .map { _ in keyPair }
        .eraseToAnyPublisher()
}

private func derive(
    input: StellarKeyDerivationInput,
    deriver: StellarKeyPairDeriver
) -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
    Deferred {
        Future { promise in
            switch deriver.derive(input: input) {
            case .success(let success):
                promise(.success(success))
            case .failure(let error):
                promise(.failure(.failedToDeriveInput(error)))
            }
        }
    }
    .eraseToAnyPublisher()
}
