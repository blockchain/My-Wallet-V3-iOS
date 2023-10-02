// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

extension WalletCreationService {
    public static func mock() -> Self {
        WalletCreationService(
            createWallet: { _, _, _, _ -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                .just(
                    WalletCreatedContext(
                        guid: "guid",
                        sharedKey: "sharedKey",
                        password: "password"
                    )
                )
            },
            importWallet: { _, _, _, _ -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError> in
                .failure(.creationFailure(.genericFailure))
            },
            setResidentialInfo: { _, _ -> AnyPublisher<Void, Error> in
                .just(())
            },
            updateCurrencyForNewWallets: { _, _, _ -> AnyPublisher<Void, Never> in
                .just(())
            }
        )
    }

    public static func failing() -> Self {
        WalletCreationService(
            createWallet: { _, _, _, _ -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                .failure(.creationFailure(.genericFailure))
            },
            importWallet: { _, _, _, _ -> AnyPublisher<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError> in
                .failure(.creationFailure(.genericFailure))
            },
            setResidentialInfo: { _, _ -> AnyPublisher<Void, Error> in
                .failure(WalletCreationServiceError.creationFailure(.genericFailure))
            },
            updateCurrencyForNewWallets: { _, _, _ -> AnyPublisher<Void, Never> in
                .just(())
            }
        )
    }
}
