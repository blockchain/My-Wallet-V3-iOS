// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import NetworkKit
import ToolKit

public final class ViewWaitlistRegistrationRepository: ViewWaitlistRegistrationRepositoryAPI {

    private let client: FeatureNFTClientAPI
    private let emailAddressPublisher: AnyPublisher<String, Error>

    public init(
        client: FeatureNFTClientAPI,
        emailAddressPublisher: AnyPublisher<String, Error>
    ) {
        self.client = client
        self.emailAddressPublisher = emailAddressPublisher
    }

    // MARK: - ViewWaitlistRegistrationRepositoryAPI

    public func registerEmailForNFTViewWaitlist()
        -> AnyPublisher<Void, ViewWalletRegistrationServiceError>
    {
        emailAddressPublisher
            .replaceError(with: ViewWalletRegistrationServiceError.emailUnavailable)
            .flatMap { [client] email in
                client
                    .registerEmailForNFTViewWaitlist(email)
                    .mapError(ViewWalletRegistrationServiceError.network)
            }
            .eraseToAnyPublisher()
    }
}
