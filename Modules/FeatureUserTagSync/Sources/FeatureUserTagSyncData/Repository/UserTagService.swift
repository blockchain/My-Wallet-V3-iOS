// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureUserTagSyncDomain
import Foundation

public class UserTagService: UserTagServiceAPI {

    private let client: UserTagClientAPI

    public init(with client: UserTagClientAPI) {
        self.client = client
    }

    public func updateSuperAppTags(isSuperAppMvpEnabled: Bool,
                                   isSuperAppV1Enabled: Bool) -> AnyPublisher<Void, NetworkError> {
        client.updateSuperAppTags(isSuperAppMvpEnabled: isSuperAppMvpEnabled,
                                  isSuperAppV1Enabled: isSuperAppV1Enabled)
    }
}
