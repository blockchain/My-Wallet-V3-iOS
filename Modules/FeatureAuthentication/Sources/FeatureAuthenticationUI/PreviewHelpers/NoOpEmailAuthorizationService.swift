// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit

final class NoOpEmailAuthorizationService: EmailAuthorizationServiceAPI {
    func cancel() {}

    func authorizeEmailPublisher() -> AnyPublisher<Void, FeatureAuthenticationDomain.EmailAuthorizationServiceError> {
        .just(())
    }
}
