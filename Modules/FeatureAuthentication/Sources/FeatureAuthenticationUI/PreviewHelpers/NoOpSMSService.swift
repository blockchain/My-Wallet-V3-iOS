// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit

final class NoOpSMSService: SMSServiceAPI {
    func request() -> AnyPublisher<Void, FeatureAuthenticationDomain.SMSServiceError> {
        .just(())
    }
}
