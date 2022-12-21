// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import UnifiedActivityDomain

public protocol CustodialActivityServiceAPI {
    func activity() -> AnyPublisher<[ActivityEntry], Never>
}
