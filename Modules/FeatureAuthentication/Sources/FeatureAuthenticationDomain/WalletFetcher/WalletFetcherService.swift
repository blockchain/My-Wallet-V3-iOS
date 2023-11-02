// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import ToolKit
import WalletPayloadKit

public enum WalletFetcherServiceError: LocalizedError, Equatable {
    case walletError(WalletError)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .walletError(let error):
            error.errorDescription
        case .unknown:
            LocalizationConstants.Errors.genericError
        }
    }
}

public struct WalletFetcherService {
    /// Fetches a wallet using the given details
    public var fetchWallet: (
        _ guid: String,
        _ sharedKey: String,
        _ password: String
    ) -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError>

    /// Fetches a wallet using guid/sharedKey and then stores the given `NabuOfflineToken`
    public var fetchWalletAfterAccountRecovery: (
        _ guid: String,
        _ sharedKey: String,
        _ password: String,
        _ offlineToken: NabuOfflineToken
    ) -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError>
}

extension WalletFetcherService {

    public static func live(
        accountRecoveryService: AccountRecoveryServiceAPI,
        walletFetcher: WalletFetcherAPI
    ) -> Self {
        Self(
            fetchWallet: { guid, sharedKey, password
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                nativeLoadWallet(
                    walletFetcher: walletFetcher,
                    guid: guid,
                    sharedKey: sharedKey,
                    password: password
                )
                .map { value -> Either<EmptyValue, WalletFetchedContext> in
                        .right(value)
                }
                .eraseToAnyPublisher()
            },
            fetchWalletAfterAccountRecovery: { guid, sharedKey, password, offlineToken
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                nativeLoadWallet(
                    walletFetcher: walletFetcher,
                    guid: guid,
                    sharedKey: sharedKey,
                    password: password
                )
                .map { value -> Either<EmptyValue, WalletFetchedContext> in
                    .right(value)
                }
                .flatMap { value
                    -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                    accountRecoveryService
                        .store(offlineToken: offlineToken)
                        .map { _ in value }
                        .mapError { _ in WalletFetcherServiceError.unknown }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(
            fetchWallet: { _, _, _
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                .empty()
            },
            fetchWalletAfterAccountRecovery: { _, _, _, _
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                .empty()
            }
        )
    }
}

func nativeLoadWallet(
    walletFetcher: WalletFetcherAPI,
    guid: String,
    sharedKey: String,
    password: String
) -> AnyPublisher<WalletFetchedContext, WalletFetcherServiceError> {
    walletFetcher.fetch(guid: guid, sharedKey: sharedKey, password: password)
        .mapError(WalletFetcherServiceError.walletError)
        .eraseToAnyPublisher()
}
