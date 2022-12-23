// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UnifiedActivityDomain

public protocol CustodialActivityDetailsServiceAPI {
    func getActivityDetails(for activityEntry: ActivityEntry) async throws -> ActivityDetail.GroupedItems?
}
