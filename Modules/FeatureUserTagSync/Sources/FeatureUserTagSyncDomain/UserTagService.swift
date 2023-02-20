// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol UserTagServiceAPI {
    func updateSuperAppTags(
        isSuperAppMvpEnabled: Bool,
        isSuperAppV1Enabled: Bool
    ) -> AnyPublisher<Void, NetworkError>
}
