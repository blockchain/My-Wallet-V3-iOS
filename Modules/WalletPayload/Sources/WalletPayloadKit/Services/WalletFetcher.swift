// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ObservabilityKit
import ToolKit

public struct WalletFetchedContext: Equatable {
    public let guid: String
    public let sharedKey: String
    public let passwordPartHash: String
}

// Types adopting `WalletFetcherAPI` should provide a way to load and initialize a Blockchain Wallet
public protocol WalletFetcherAPI {

    /// Fetches a wallet payload with the given parameters
    /// - Parameters:
    ///   - guid: A `String` as the `guid` for the wallet
    ///   - sharedKey: A `String` as the `sharedKey` for the wallet
    ///   - password: A `String` to decrypt the wallet
    /// - Returns: `AnyPublisher<WalletFetchedContext, WalletError>`
    func fetch(guid: String, sharedKey: String, password: String) -> AnyPublisher<WalletFetchedContext, WalletError>

    /// Fetches and initializes a wallet using the given password
    /// - Parameter password: A `String` to be used as the password for fetching the wallet
    func fetch(using password: String) -> AnyPublisher<WalletFetchedContext, WalletError>
}

typealias LoadAndInitializePayload = (
    _ payload: WalletPayload,
    _ password: String
) -> AnyPublisher<WalletFetchedContext, WalletError>

final class WalletFetcher: WalletFetcherAPI {

    private let walletRepo: WalletRepoAPI
    private let payloadCrypto: PayloadCryptoAPI
    private let walletLogic: WalletLogic
    private let walletPayloadRepository: WalletPayloadRepositoryAPI
    private let operationsQueue: DispatchQueue
    private let tracer: LogMessageServiceAPI
    private let logger: NativeWalletLoggerAPI

    private let doLoadPayload: LoadAndInitializePayload

    init(
        walletRepo: WalletRepoAPI,
        payloadCrypto: PayloadCryptoAPI,
        walletLogic: WalletLogic,
        walletPayloadRepository: WalletPayloadRepositoryAPI,
        operationsQueue: DispatchQueue,
        tracer: LogMessageServiceAPI,
        logger: NativeWalletLoggerAPI
    ) {
        self.walletRepo = walletRepo
        self.payloadCrypto = payloadCrypto
        self.walletLogic = walletLogic
        self.walletPayloadRepository = walletPayloadRepository
        self.operationsQueue = operationsQueue
        self.tracer = tracer
        self.logger = logger

        self.doLoadPayload = loadPayload(
            payloadCrypto: payloadCrypto,
            walletLogic: walletLogic,
            walletRepo: walletRepo,
            queue: operationsQueue,
            tracer: tracer,
            logger: logger
        )
    }

    func fetch(using password: String) -> AnyPublisher<WalletFetchedContext, WalletError> {
        walletRepo
            .walletPayload
            .first()
            .receive(on: operationsQueue)
            .flatMap { [doLoadPayload] payload -> AnyPublisher<WalletFetchedContext, WalletError> in
                doLoadPayload(payload, password)
            }
            .eraseToAnyPublisher()
    }

    func fetch(
        guid: String,
        sharedKey: String,
        password: String
    ) -> AnyPublisher<WalletFetchedContext, WalletError> {
        walletPayloadRepository.payload(
            guid: guid,
            identifier: .sharedKey(sharedKey)
        )
        .mapError { _ in WalletError.payloadNotFound }
        .flatMap { [doLoadPayload] payload -> AnyPublisher<WalletFetchedContext, WalletError> in
            doLoadPayload(payload, password)
        }
        .eraseToAnyPublisher()
    }
}

// swiftlint:disable:next function_parameter_count
/// Decrypts and initializes a wallet payload
/// - Parameters:
///   - payloadCrypto: A `PayloadCryptoAPI` for decrypting the payload
///   - walletLogic: A `WalletLogic` for initialization of the payload
///   - walletRepo: A `WalletRepo` for related storage
/// - Returns: A closure of type `(WalletPayload, String) -> AnyPublisher<WalletFetchedContext, WalletError>`
private func loadPayload(
    payloadCrypto: PayloadCryptoAPI,
    walletLogic: WalletLogic,
    walletRepo: WalletRepoAPI,
    queue: DispatchQueue,
    tracer: LogMessageServiceAPI,
    logger: NativeWalletLoggerAPI
) -> LoadAndInitializePayload {
    { [payloadCrypto, walletLogic, walletRepo, tracer] payload, password
        -> AnyPublisher<WalletFetchedContext, WalletError> in
        guard let payloadWrapper = payload.payloadWrapper, !payloadWrapper.payload.isEmpty else {
            return .failure(WalletError.payloadNotFound)
        }
        return payloadCrypto.decryptWallet(
            walletWrapper: payloadWrapper,
            password: password
        )
        .publisher
        .map { (payload, $0) }
        .mapError { _ in WalletError.decryption(.decryptionError) }
        .eraseToAnyPublisher()
        .logMessageOnOutput(
            logger: logger,
            message: { _, decrypted in
                "Decrypted payload: \(decrypted)"
            }
        )
        .flatMap { [walletLogic] walletPayload, decryptedPayload -> AnyPublisher<WalletState, WalletError> in
            guard let data = decryptedPayload.data(using: .utf8) else {
                return .failure(.decryption(.decryptionError))
            }
            return walletLogic
                .initialize(with: password, payload: walletPayload, decryptedWallet: data)
        }
        .logError(tracer: tracer)
        .receive(on: queue)
        .flatMap { walletState -> AnyPublisher<NativeWallet, WalletError> in
            guard let wallet = walletState.wallet else {
                return .failure(.initialization(.missingWallet))
            }
            // the way Pin screen is currently created we need to store the password
            // for Pin creation...
            return walletRepo
                .set(keyPath: \.credentials.sharedKey, value: wallet.sharedKey)
                .set(keyPath: \.credentials.password, value: password)
                .get()
                .mapError()
                .map { _ in wallet }
                .eraseToAnyPublisher()
        }
        .map { value -> WalletFetchedContext in
            WalletFetchedContext(
                guid: value.guid,
                sharedKey: value.sharedKey,
                passwordPartHash: hashPassword(password)
            )
        }
        .eraseToAnyPublisher()
    }
}

/// Stores the sharedKey to the given WalletRepo
/// - Parameters:
///   - walletState: A `WalletState` that contains a decrypted wallet to get the shared key from
///   - walletRepo: A `WalletRepo` which the sharedKey will be stored
/// - Returns: An `AnyPublisher<Wallet, WalletError>`
func storeSharedKey(
    from walletState: WalletState,
    on walletRepo: WalletRepoAPI
) -> AnyPublisher<NativeWallet, WalletError> {
    guard let wallet = walletState.wallet else {
        return .failure(.initialization(.missingWallet))
    }
    return walletRepo
        .set(keyPath: \.credentials.sharedKey, value: wallet.sharedKey)
        .get()
        .mapError()
        .map { _ in wallet }
        .eraseToAnyPublisher()
}
