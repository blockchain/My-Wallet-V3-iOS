// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import StellarKit

final class StellarWalletAccountRepositoryMock: StellarWalletAccountRepositoryAPI {
    var defaultAccount: AnyPublisher<StellarWalletAccount?, Never> {
        .just(nil)
    }

    func initializeMetadata() -> AnyPublisher<Void, StellarWalletAccountRepositoryError> {
        .just(())
    }

    func loadKeyPair() -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
        .failure(.saveFailure)
    }

    func updateLabel(_ label: String) -> AnyPublisher<Void, Never> {
        .just(())
    }

    func updateLabels(on accounts: [StellarCryptoAccount]) -> AnyPublisher<Void, Never> {
        .just(())
    }
}
