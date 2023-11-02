// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureKYCDomain
import PlatformKit // sadly, Settings service is stored here
import ToolKit

// NOTE: This should really be reversed, meaning the API Client implementation should be in the KYC module and adapted for Settings, not the way around like it is now!
// TICKET: IOS-4733
public final class EmailVerificationAdapter {

    // MARK: - Properties

    private let settingsService: CompleteSettingsServiceAPI

    // MARK: - Init

    public init(settingsService: CompleteSettingsServiceAPI) {
        self.settingsService = settingsService
    }

    // MARK: - Public Interface

    public func fetchEmailVerificationStatus(
        force: Bool
    ) -> AnyPublisher<EmailVerificationStatusResponse, EmailVerificationError> {
        settingsService.fetchPublisher(force: force)
            .map { response in
                EmailVerificationStatusResponse(
                    email: response.email,
                    isEmailVerified: response.isEmailVerified
                )
            }
            .mapError { error in
                switch error {
                case .timedOut:
                    .unknown(error)
                case .fetchFailed(let error):
                    .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }

    public func update(email: String) -> AnyPublisher<Void, EmailVerificationError> {
        settingsService.update(email: email)
            .mapToVoid()
            .mapError { error in
                switch error {
                case .credentialsError:
                    .unauthenticated
                case .networkError(let error):
                    .networkError(error)
                case .unknown(let error):
                    .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - FeatureKYCDomain.EmailVerificationAPI

extension EmailVerificationAdapter: FeatureKYCDomain.EmailVerificationAPI {}
