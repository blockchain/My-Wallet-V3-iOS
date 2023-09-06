// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import ToolKit
import WalletPayloadKit

public struct WalletCreatedContext: Equatable {
    public let guid: String
    public let sharedKey: String
    public let password: String
}

public typealias CreateWalletMethod = (
    _ email: String,
    _ password: String,
    _ accountName: String,
    _ recaptchaToken: String?
) -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError>

public typealias ImportWalletMethod = (
    _ email: String,
    _ password: String,
    _ accountName: String,
    _ mnemonic: String
) -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError>

public typealias SetResidentialInfoMethod = (
    _ country: String,
    _ state: String?
) -> AnyPublisher<Void, Error>

public typealias UpdateCurrencyForNewWallets = (
    _ country: String,
    _ guid: String,
    _ sharedKey: String
) -> AnyPublisher<Void, Never>

public struct WalletCreationService {
    /// Creates a new wallet using the given details
    public var createWallet: CreateWalletMethod
    /// Imports and creates a new wallet using the given details
    public var importWallet: ImportWalletMethod
    /// Sets the residential info as part of account creation
    public var setResidentialInfo: SetResidentialInfoMethod
    /// Sets the default currency for a new wallet account
    public var updateCurrencyForNewWallets: UpdateCurrencyForNewWallets
}

extension WalletCreationService {

    public static func live(
        walletCreator: WalletCreatorAPI,
        nabuRepository: NabuRepositoryAPI,
        updateCurrencyService: @escaping UpdateCurrencyForNewWallets
    ) -> Self {
        Self(
            createWallet: { email, password, accountName, token -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                let siteKey = AuthenticationKeys.googleRecaptchaSiteKey
                return walletCreator.createWallet(
                    email: email,
                    password: password,
                    accountName: accountName,
                    recaptchaToken: token,
                    siteKey: siteKey,
                    language: "en"
                )
                .mapError(WalletCreationServiceError.creationFailure)
                .map(WalletCreatedContext.from(model:))
                .eraseToAnyPublisher()
            },
            importWallet: { email, password, accountName, mnemonic -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError> in
                walletCreator.importWallet(
                    mnemonic: mnemonic,
                    email: email,
                    password: password,
                    accountName: accountName,
                    language: "en"
                )
                .mapError(WalletCreationServiceError.creationFailure)
                .map { model -> Either<WalletCreatedContext, EmptyValue> in
                    .left(WalletCreatedContext.from(model: model))
                }
                .eraseToAnyPublisher()
            },
            setResidentialInfo: { country, state -> AnyPublisher<Void, Error> in
                var rng = SystemRandomNumberGenerator()
                // we fire the request but we ignore the error,
                // even if this fails the user will still have to submit their details
                // as part of the KYC flow
                return Deferred {
                    nabuRepository.setInitialResidentialInfo(
                        country: country,
                        state: state
                    )
                }
                .retry(max: 30, delay: .exponential(using: &rng), scheduler: DispatchQueue.main)
                .eraseError()
                .eraseToAnyPublisher()
            },
            updateCurrencyForNewWallets: { country, guid, sharedKey -> AnyPublisher<Void, Never> in
                // we ignore the failure since this is kind of a side effect for new wallets :(
                updateCurrencyService(country, guid, sharedKey)
                    .ignoreFailure(setFailureType: Never.self)
                    .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(
            createWallet: { _, _, _, _ -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                .empty()
            },
            importWallet: { _, _, _, _ -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError> in
                .empty()
            },
            setResidentialInfo: { _, _ -> AnyPublisher<Void, Error> in
                .empty()
            },
            updateCurrencyForNewWallets: { _, _, _ -> AnyPublisher<Void, Never> in
                .empty()
            }
        )
    }
}

extension WalletCreatedContext {
    static func from(model: WalletCreation) -> Self {
        WalletCreatedContext(
            guid: model.guid,
            sharedKey: model.sharedKey,
            password: model.password
        )
    }
}
