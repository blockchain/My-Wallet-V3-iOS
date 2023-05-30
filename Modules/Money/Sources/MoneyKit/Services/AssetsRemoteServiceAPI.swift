// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol AssetsRemoteServiceAPI {
    var refreshCache: AnyPublisher<Void, Never> { get }
}
