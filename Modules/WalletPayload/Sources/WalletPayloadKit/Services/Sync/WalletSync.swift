// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import ObservabilityKit
import ToolKit

protocol WalletSyncAPI {
    /// Syncs the given `Wrapper` of a `Wallet` with the backend.
    /// - Parameters:
    ///   - wrapper: An updated `Wrapper` object to be sent to the server
    ///   - password: A `String` to be used as a password for the encryption
    /// - Returns: `AnyPublisher<EmptyValue, WalletSyncError>`
    func sync(
        wrapper: Wrapper,
        password: String
    ) -> AnyPublisher<EmptyValue, WalletSyncError>
}

/// Responsible for syncing the latest changes of `Wallet` to backend
final class WalletSync: WalletSyncAPI {

    private let walletHolder: WalletHolderAPI
    private let walletRepo: WalletRepoAPI
    private let payloadCrypto: PayloadCryptoAPI
    private let walletEncoder: WalletEncodingAPI
    private let operationQueue: DispatchQueue
    private let saveWalletRepository: SaveWalletRepositoryAPI
    private let syncPubKeysAddressesProvider: SyncPubKeysAddressesProviderAPI
    private let tracer: LogMessageServiceAPI
    private let logger: NativeWalletLoggerAPI
    private let checksumProvider: (Data) -> String

    init(
        walletHolder: WalletHolderAPI,
        walletRepo: WalletRepoAPI,
        payloadCrypto: PayloadCryptoAPI,
        walletEncoder: WalletEncodingAPI,
        saveWalletRepository: SaveWalletRepositoryAPI,
        syncPubKeysAddressesProvider: SyncPubKeysAddressesProviderAPI,
        tracer: LogMessageServiceAPI,
        logger: NativeWalletLoggerAPI,
        operationQueue: DispatchQueue,
        checksumProvider: @escaping (Data) -> String
    ) {
        self.walletHolder = walletHolder
        self.walletRepo = walletRepo
        self.payloadCrypto = payloadCrypto
        self.walletEncoder = walletEncoder
        self.saveWalletRepository = saveWalletRepository
        self.syncPubKeysAddressesProvider = syncPubKeysAddressesProvider
        self.operationQueue = operationQueue
        self.checksumProvider = checksumProvider
        self.tracer = tracer
        self.logger = logger
    }

    /// Syncs the given `Wrapper` of a `Wallet` with the backend.
    /// - Parameters:
    ///   - wrapper: An updated `Wrapper` object to be sent to the server
    ///   - password: A `String` to be used as a password for the encryption
    /// - Returns: `AnyPublisher<EmptyValue, WalletSyncError>`
    func sync(
        wrapper: Wrapper,
        password: String
    ) -> AnyPublisher<EmptyValue, WalletSyncError> {
        let saveOperations = saveOperations(
            walletEncoder: walletEncoder,
            payloadCrypto: payloadCrypto,
            logger: logger,
            checksumProvider: checksumProvider,
            saveWalletRepository: saveWalletRepository,
            syncPubKeysAddressesProvider: syncPubKeysAddressesProvider
        )
        return Just(wrapper)
            .receive(on: operationQueue)
            .logMessageOnOutput(logger: logger, message: { wrapper in
                "Wrapper to be synced: \(wrapper)"
            })
            .flatMap { wrapper -> AnyPublisher<WalletCreationPayload, WalletSyncError> in
                saveOperations(wrapper, password)
                    .eraseToAnyPublisher()
            }
            .logError(tracer: tracer)
            .flatMap { [walletRepo] payload -> AnyPublisher<WalletCreationPayload, Never> in
                walletRepo.set(keyPath: \.credentials.password, value: password)
                    .get()
                    .map { _ in payload }
                    .eraseToAnyPublisher()
            }
            .flatMap { [walletRepo] payload -> AnyPublisher<WalletCreationPayload, Never> in
                updateCachedWalletPayload(
                    encodedPayload: payload,
                    walletRepo: walletRepo,
                    wrapper: wrapper
                )
                .map { _ in payload }
                .eraseToAnyPublisher()
            }
            .map { [walletHolder] payload -> WalletState in
                // update the wrapper with the new checksum
                let wrapper = updateWrapper(checksum: payload.checksum, using: wrapper)
                // check the current state of the walletState and update appropriately
                guard let state = walletHolder.provideWalletState() else {
                    return .partially(loaded: .justWrapper(wrapper))
                }
                guard let metadata = state.metadata else {
                    return .partially(loaded: .justWrapper(wrapper))
                }
                return .loaded(wrapper: wrapper, metadata: metadata)
            }
            .flatMap { [walletHolder] walletState -> AnyPublisher<Void, WalletSyncError> in
                walletHolder.hold(walletState: walletState)
                    .mapToVoid()
                    .mapError(to: WalletSyncError.self)
                    .eraseToAnyPublisher()
            }
            .map { _ in EmptyValue.noValue }
            .eraseToAnyPublisher()
    }
}

// swiftlint:disable function_parameter_count
/// Performs operations needed for saving the `Wallet` to the backend
///  1) Encrypts and verify payload
///  2) Encodes the encrypted payload
///  3) Syncs the wallet with the backend
/// - Parameters:
///   - walletEncoder: A `WalletEncoderAPI` for encoding the payload
///   - payloadCrypto: A `PayloadCryptoAPI` for encrypting/decrypting the payload
///   - checksumProvider: A `(Data) -> String` closure that applies a checksum
///   - saveWalletRepository: A `SaveWalletRepositoryAPI` for saving the wallet to the backend
///  - Returns: A closure `(Wrapper, Password) -> AnyPublisher<WalletCreationPayload, WalletSyncError>`
private func saveOperations(
    walletEncoder: WalletEncodingAPI,
    payloadCrypto: PayloadCryptoAPI,
    logger: NativeWalletLoggerAPI,
    checksumProvider: @escaping (Data) -> String,
    saveWalletRepository: SaveWalletRepositoryAPI,
    syncPubKeysAddressesProvider: SyncPubKeysAddressesProviderAPI
) -> (_ wrapper: Wrapper, _ password: String) -> AnyPublisher<WalletCreationPayload, WalletSyncError> {
    { wrapper, password -> AnyPublisher<WalletCreationPayload, WalletSyncError> in
        // encrypt and then decrypt the wrapper for verification
        encryptAndVerifyWrapper(
            walletEncoder: walletEncoder,
            encryptor: payloadCrypto,
            logger: logger,
            password: password,
            wrapper: wrapper
        )
        .mapError(WalletSyncError.verificationFailure)
        .flatMap { [walletEncoder, checksumProvider] payload -> AnyPublisher<WalletCreationPayload, WalletSyncError> in
            walletEncoder.encode(payload: payload, applyChecksum: checksumProvider)
                .mapError(WalletSyncError.encodingError)
                .eraseToAnyPublisher()
        }
        .flatMap { [syncPubKeysAddressesProvider, logger] payload
            -> AnyPublisher<(WalletCreationPayload, String?), WalletSyncError> in
            guard wrapper.syncPubKeys else {
                logger.log(message: "syncPubKeys not required", metadata: nil)
                return .just((payload, nil))
            }
            guard let mnemonic = getMnemonic(from: wrapper.wallet).success else {
                logger.log(message: "syncPubKeys failed, couldn't retrieve mnemonic", metadata: nil)
                return .failure(.mnemonicFailure)
            }
            // To get notifications working we need to pass a list of lookahead addresses
            logger.log(message: "syncPubKeys required", metadata: nil)
            let accounts = wrapper.wallet.defaultHDWallet?.accounts ?? []
            return syncPubKeysAddressesProvider.provideAddresses(
                mnemonic: mnemonic,
                active: wrapper.wallet.spendableActiveAddresses,
                accounts: accounts
            )
            .mapError(WalletSyncError.syncPubKeysFailure)
            .map { addresses in (payload, addresses) }
            .logMessageOnOutput(logger: logger, message: { _, addresses in
                let addresses = addresses ?? ""
                return "[Sync] Addresses to sync:\n \(addresses)"
            })
            .eraseToAnyPublisher()
        }
        .logMessageOnOutput(logger: logger, message: { payload, _ in
            "[Sync] !!! About to sync \(payload)"
        })
        .flatMap { [saveWalletRepository] payload, addresses -> AnyPublisher<WalletCreationPayload, WalletSyncError> in
            saveWalletRepository.saveWallet(
                payload: payload,
                addresses: addresses
            )
            .mapError(WalletSyncError.networkFailure)
            .map { _ in payload }
            .eraseToAnyPublisher()
        }
        .logMessageOnOutput(logger: logger, message: { _ in
            "Wallet synced successfully"
        })
        .eraseToAnyPublisher()
    }
}

/// Creates a new `Wrapper` with an updated checksum
/// - Parameters:
///   - checksum: A `String` value
///   - wrapper: A `Wrapper` to be recreated
/// - Returns: `Wrapper`
private func updateWrapper(
    checksum: String,
    using wrapper: Wrapper
) -> Wrapper {
    Wrapper(
        pbkdf2Iterations: Int(wrapper.pbkdf2Iterations),
        version: wrapper.version,
        payloadChecksum: checksum,
        language: wrapper.language,
        syncPubKeys: wrapper.syncPubKeys,
        wallet: wrapper.wallet
    )
}

/// Updates the cached version of `WalletPayload` on `WalletRepo`
/// - Returns: `AnyPublisher<Void, Never>`
private func updateCachedWalletPayload(
    encodedPayload: WalletCreationPayload,
    walletRepo: WalletRepoAPI,
    wrapper: Wrapper
) -> AnyPublisher<Void, Never> {
    let currentWalletPayload: WalletPayload = walletRepo.walletPayload
    let updatedPayload = WalletPayload(
        guid: encodedPayload.guid,
        authType: currentWalletPayload.authType,
        language: encodedPayload.language,
        shouldSyncPubKeys: wrapper.syncPubKeys,
        time: Date(),
        payloadChecksum: encodedPayload.checksum,
        payload: try? JSONDecoder().decode(WalletPayloadWrapper.self, from: encodedPayload.innerPayload)
    )
    return walletRepo.set(keyPath: \.walletPayload, value: updatedPayload)
        .get()
        .mapToVoid()
        .eraseToAnyPublisher()
}
