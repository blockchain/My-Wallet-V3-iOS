// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol UnifiedActivityDetailsServiceAPI {
    func getActivityDetails(activity: ActivityEntry) async throws -> ActivityDetail.GroupedItems
}
