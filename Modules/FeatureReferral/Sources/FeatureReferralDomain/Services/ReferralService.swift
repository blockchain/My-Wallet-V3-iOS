// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Errors
import Foundation
import MoneyKit

public protocol ReferralServiceAPI {
    func fetchReferralCampaign() -> AnyPublisher<Referral?, Never>
    func createReferral(with code: String) -> AnyPublisher<Void, NetworkError>
}

public class ReferralService: ReferralServiceAPI {
    private let repository: ReferralRepositoryAPI
    private let app: AppProtocol

    public init(
        app: AppProtocol,
        repository: ReferralRepositoryAPI
    ) {
        self.app = app
        self.repository = repository
    }

    func isEnabled() -> AnyPublisher<Bool, Never> {
        app.publisher(for: blockchain.app.configuration.referral.is.enabled, as: Bool.self)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    public func createReferral(with code: String) -> AnyPublisher<Void, NetworkError> {
        isEnabled().flatMap { [repository] isEnabled in
            if isEnabled {
                return repository.createReferral(with: code).eraseToAnyPublisher()
            } else {
                return .just(())
            }
        }
        .eraseToAnyPublisher()
    }

    public func fetchReferralCampaign() -> AnyPublisher<Referral?, Never> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .replaceError(with: .USD)
            .combineLatest(isEnabled())
            .flatMap { [repository] currency, isEnabled -> AnyPublisher<Referral?, NetworkError> in
                if isEnabled {
                    return repository.fetchReferralCampaign(for: currency.code).optional()
                } else {
                    return .just(nil)
                }
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
