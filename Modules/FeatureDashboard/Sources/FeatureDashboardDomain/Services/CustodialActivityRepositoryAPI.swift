// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit
import UnifiedActivityDomain

public protocol CustodialActivityRepositoryAPI {
    func activity() -> StreamOf<[ActivityEntry], Never>
}
